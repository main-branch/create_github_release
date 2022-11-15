# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Tasks::UpdateChangelog do
  let(:task) { described_class.new(options) }
  let(:options) do
    CreateGithubRelease::Options.new do |o|
      o.release_type = 'major'
      o.current_version = '0.1.1'
    end
  end

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

    before do
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:write) do |path, content|
        # :nocov:
        raise "Unexpected file write to #{path} with #{content}"
        # :nocov:
      end
      allow(FileUtils).to receive(:pwd).and_return('/my_worktree')
    end

    let(:mocked_commands) do
      [
        MockedCommand.new(
          'git show --format=format:%aI --quiet "v1.0.0"',
          stdout: new_tag_date,
          exitstatus: git_show_exitstatus
        ),
        MockedCommand.new(
          "docker run --rm --volume '/my_worktree:/worktree' changelog-rs 'v0.1.1' 'v1.0.0'",
          stdout: new_changes,
          exitstatus: docker_exitstatus
        ),
        MockedCommand.new('git add CHANGELOG.md', exitstatus: git_add_exitstatus)
      ]
    end

    let(:git_show_exitstatus) { 0 }
    let(:docker_exitstatus) { 0 }
    let(:git_add_exitstatus) { 0 }

    let(:new_tag_date) { '2022-11-10' }

    let(:existing_changelog) { <<~CHANGELOG }
      # Changelog

      ## v0.1.0 (2022-10-31)

      * 123456 Change 1 (#1)
    CHANGELOG

    let(:new_changes) { <<~CHANGES.chomp }
      ## v1.0.0
      * 123457 Change 2 (#2)
    CHANGES

    let(:expected_new_changelog) { <<~CHANGELOG }
      # Changelog

      ## v1.0.0 (2022-11-10)

      * 123457 Change 2 (#2)

      ## v0.1.0 (2022-10-31)

      * 123456 Change 1 (#1)
    CHANGELOG

    context 'when a changelog file and new release exists' do
      before do
        expect(File).to receive(:read).with('CHANGELOG.md').and_return(existing_changelog)
        expect(File).to(
          receive(:write)
            .with('CHANGELOG.md', expected_new_changelog)
            .and_return(expected_new_changelog.size)
        )
      end

      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when a changelog file does not exist' do
      before do
        expect(File).to receive(:read).with('CHANGELOG.md').and_raise(Errno::ENOENT)
        expect(File).to(
          receive(:write)
            .with('CHANGELOG.md', expected_new_changelog)
            .and_return(expected_new_changelog.size)
        )
      end

      let(:expected_new_changelog) { <<~CHANGELOG }
        ## v1.0.0 (2022-11-10)

        * 123457 Change 2 (#2)
      CHANGELOG

      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when the release date could not be determined' do
      let(:git_show_exitstatus) { 1 }

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to match(/^ERROR: Could not stage changes to CHANGELOG.md/)
      end
    end

    context 'when the new changes could not be determined' do
      let(:docker_exitstatus) { 1 }

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to match(/^ERROR: Could not generate the release notes/)
      end
    end

    context 'when the changelog file could not be written' do
      before do
        expect(File).to receive(:read).with('CHANGELOG.md').and_return(existing_changelog)
        expect(File).to receive(:write).with('CHANGELOG.md', expected_new_changelog).and_raise(Errno::EACCES)
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to match(/^ERROR: Could not write to CHANGELOG.md: Permission denied/)
      end
    end

    context 'when the changelog file could not be staged' do
      before do
        expect(File).to receive(:read).with('CHANGELOG.md').and_return(existing_changelog)
        expect(File).to(
          receive(:write)
            .with('CHANGELOG.md', expected_new_changelog)
            .and_return(expected_new_changelog.size)
        )
      end

      let(:git_add_exitstatus) { 1 }

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to match(/^ERROR: Could not stage changes to CHANGELOG.md/)
      end
    end
  end
end
