# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Tasks::UpdateChangelog do
  let(:task) { described_class.new(project) }

  let(:changelog_path) { 'CHANGES.txt' }
  let(:next_release_changelog) { '<imagine a changelog here>' }

  let(:project) do
    CreateGithubRelease::Project.new(options) do |p|
      p.changelog_path = changelog_path
      p.next_release_changelog = next_release_changelog
    end
  end

  let(:options) { CreateGithubRelease::CommandLine::Options.new { |o| o.release_type = 'major' } }

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

    before do
      allow(File).to receive(:read).and_call_original
      # allow(File).to receive(:write) do |path, content|
      #   # :nocov:
      #   File.open('debug.txt', 'w') { |f| f.write(content) }
      #   raise "Unexpected file write to #{path} with #{content}"
      #   # :nocov:
      # end
    end

    let(:mocked_commands) do
      [
        MockedCommand.new("git add #{changelog_path}", exitstatus: git_add_exitstatus)
      ]
    end

    let(:git_show_exitstatus) { 0 }
    let(:git_log_exitstatus) { 0 }
    let(:git_add_exitstatus) { 0 }

    context 'when the changelog is updated and staged' do
      before do
        expect(File).to(
          receive(:write)
            .with(changelog_path, next_release_changelog)
            .and_return(next_release_changelog.size)
        )
      end

      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when a changelog file does not already exist' do
      before do
        expect(File).to(
          receive(:write)
            .with(changelog_path, next_release_changelog)
            .and_return(next_release_changelog.size)
        )
      end

      it 'a new changelog file should be created and the task should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when the changelog file could not be written' do
      before do
        expect(File).to receive(:write).with(changelog_path, next_release_changelog).and_raise(Errno::EACCES)
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to start_with("ERROR: Could not update #{changelog_path}: Permission denied")
      end
    end

    context 'when the changelog file could not be staged' do
      before do
        expect(File).to(
          receive(:write)
            .with(changelog_path, next_release_changelog)
            .and_return(next_release_changelog.size)
        )
      end

      let(:git_add_exitstatus) { 1 }

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to start_with("ERROR: Could not stage changes to #{changelog_path}")
      end
    end
  end
end
