# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Tasks::CreateGithubRelease do
  let(:task) { described_class.new(options) }
  let(:options) { CreateGithubRelease::Options.new { |o| o.release_type = 'major' } }

  before do
    allow(task).to receive(:`).with(String) { |command| execute_mocked_command(mocked_commands, command) }
  end

  describe '#run' do
    subject do
      @stdout, @stderr, exception = capture_output { task.run }
      raise exception if exception
    end
    let(:stdout) { @stdout }
    let(:stderr) { @stderr }

    let(:changelog_file) { Object.new }

    let(:expected_changelog) { <<~CHANGELOG.chomp }
      [Full Changelog](https://github.com/user/repo/compare/v0.1.0...v1.0.0)

      * 07a1167 Release v1.0.0 (#10)
      * 8fe479b Fix worktree test when git dir includes symlinks (#7)
    CHANGELOG

    before do
      # allow(Bump::Bump).to receive(:run).with('major', commit: false).and_return(['next.version', bump_result])
      allow(FileUtils).to receive(:pwd).and_return('/my_worktree')
      allow(Tempfile).to receive(:create).and_return(changelog_file)
      allow(changelog_file).to receive(:path).and_return('/tmp/changelog')
      allow(File).to receive(:unlink).with('/tmp/changelog')
    end

    let(:mocked_commands) do
      [
        MockedCommand.new(
          "docker run --rm --volume '/my_worktree:/worktree' changelog-rs 'v0.1.0' 'v1.0.0'",
          stdout: new_changes,
          exitstatus: docker_exitstatus
        ),
        MockedCommand.new(
          "gh release create 'v1.0.0' " \
          "--title 'Release v1.0.0' " \
          "--notes-file '/tmp/changelog' " \
          "--target 'main'",
          stdout: '',
          exitstatus: gh_exitstatus
        )
      ]
    end

    let(:new_changes) { <<~NEW_CHANGES }
      ## v1.0.0
      [Full Changelog](https://github.com/user/repo/compare/v0.1.0...v1.0.0)

      * 07a1167 Release v1.0.0 (#10)
      * 8fe479b Fix worktree test when git dir includes symlinks (#7)
    NEW_CHANGES

    context 'when creating the Github release succeeds' do
      let(:docker_exitstatus) { 0 }
      before do
        expect(changelog_file).to receive(:write).with(expected_changelog)
        expect(changelog_file).to receive(:close)
        expect(File).to receive(:unlink).with('/tmp/changelog')
      end
      let(:gh_exitstatus) { 0 }

      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when the changelog could not be generated' do
      let(:docker_exitstatus) { 1 }
      let(:gh_exitstatus) { 0 }

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to match(/^ERROR: Could not generate the changelog/)
      end
    end

    context 'when the changelog file could not be created' do
      let(:docker_exitstatus) { 0 }
      before do
        allow(Tempfile).to receive(:create).and_raise(StandardError.new('Permission denied'))
      end
      let(:gh_exitstatus) { 0 }

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to match(/^ERROR: Could not create a temporary file/)
      end
    end

    context 'when the github release could not be created' do
      let(:docker_exitstatus) { 0 }
      let(:gh_exitstatus) { 1 }
      before do
        expect(changelog_file).to receive(:write).with(expected_changelog)
        expect(changelog_file).to receive(:close)
        expect(File).to receive(:unlink).with('/tmp/changelog')
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to match(/^ERROR: Could not create release/)
      end
    end
  end
end
