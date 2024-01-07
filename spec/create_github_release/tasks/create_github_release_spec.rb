# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Tasks::CreateGithubRelease do
  let(:task) { described_class.new(project) }

  let(:next_release_description) { 'imagine a release description here' }

  let(:project) do
    CreateGithubRelease::Project.new(options) do |p|
      p.last_release_tag = 'v0.1.0'
      p.next_release_tag = 'v1.0.0'
      p.next_release_description = next_release_description
    end
  end

  let(:options) do
    CreateGithubRelease::CommandLine::Options.new do |o|
      o.release_type = 'major'
      o.default_branch = 'main'
    end
  end

  let(:tmp_changelog_path) { '/tmp/changelog' }

  before do
    allow(task).to receive(:`).with(String) { |command| execute_mocked_command(mocked_commands, command) }
    allow(project).to receive(:`).with(String) { |command| execute_mocked_command(mocked_commands, command) }
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
      [Full Changelog](https://github.com/user/repo/compare/#{last_release_tag}..#{next_release_tag})

      * 07a1167 Release v1.0.0 (#10)
      * 8fe479b Fix worktree test when git dir includes symlinks (#7)
    CHANGELOG

    before do
      allow(Tempfile).to receive(:create).and_return(changelog_file)
      allow(changelog_file).to receive(:path).and_return(tmp_changelog_path)
      allow(File).to receive(:unlink).with(tmp_changelog_path)
    end

    let(:mocked_commands) do
      [
        MockedCommand.new(
          "gh release create 'v1.0.0' " \
          "--title 'Release v1.0.0' " \
          "--notes-file '#{tmp_changelog_path}' " \
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
      before do
        expect(changelog_file).to receive(:write).with(next_release_description)
        expect(changelog_file).to receive(:close)
        expect(File).to receive(:unlink).with(tmp_changelog_path)
      end
      let(:gh_exitstatus) { 0 }

      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when the changelog file could not be created' do
      before do
        allow(Tempfile).to receive(:create).and_raise(StandardError.new('Permission denied'))
      end
      let(:gh_exitstatus) { 0 }

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to start_with('ERROR: Could not create a temporary file')
      end
    end

    context 'when the github release could not be created' do
      let(:gh_exitstatus) { 1 }
      before do
        expect(changelog_file).to receive(:write).with(next_release_description)
        expect(changelog_file).to receive(:close)
        expect(File).to receive(:unlink).with(tmp_changelog_path)
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to start_with('ERROR: Could not create release')
      end
    end
  end
end
