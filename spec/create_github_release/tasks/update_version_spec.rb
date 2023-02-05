# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Tasks::UpdateVersion do
  let(:release_type) { 'major' }
  let(:task) { described_class.new(project) }
  let(:project) { CreateGithubRelease::Project.new(options) }
  let(:options) { CreateGithubRelease::CommandLineOptions.new { |o| o.release_type = release_type } }

  let(:version_file) { 'lib/my_gem/version.rb' }

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

    context 'when this is the first release' do
      let(:release_type) { 'first' }
      it 'should not bump the version' do
        expect(task).not_to receive(:bump_version)
        subject
      end
    end

    context 'when this is NOT the first release' do
      let(:mocked_commands) do
        [
          MockedCommand.new('bump major --no-commit', exitstatus: bump_exitstatus),
          MockedCommand.new('bump file', stdout: "#{version_file}\n", exitstatus: bump_file_exitstatus),
          MockedCommand.new("git add \"#{version_file}\"", exitstatus: git_exitstatus)
        ]
      end

      let(:bump_exitstatus) { 0 }
      let(:bump_file_exitstatus) { 0 }
      let(:git_exitstatus) { 0 }

      context 'when bump and git add succeed' do
        it 'should succeed' do
          expect { subject }.not_to raise_error
        end
      end

      context 'when bump fails to increment the version' do
        let(:bump_exitstatus) { 1 }
        it 'should fail' do
          expect { subject }.to raise_error(SystemExit)
          expect(stderr).to start_with('ERROR: Could not bump version')
        end
      end

      context 'when bump file fails' do
        let(:bump_file_exitstatus) { 1 }
        it 'should fail' do
          expect { subject }.to raise_error(SystemExit)
          expect(stderr).to start_with('ERROR: Bump could determine the version file')
        end
      end

      context 'when git add fails' do
        let(:git_exitstatus) { 1 }
        it 'should fail' do
          expect { subject }.to raise_error(SystemExit)
          expect(stderr).to start_with("ERROR: Could not stage changes to #{version_file}")
        end
      end
    end
  end
end
