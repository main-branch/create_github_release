# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Assertions::RemoteReleaseBranchDoesNotExist do
  let(:assertion) { described_class.new(project) }
  let(:options) { CreateGithubRelease::CommandLine::Options.new { |o| o.release_type = 'major' } }
  let(:project) { CreateGithubRelease::Project.new(options) { |p| p.release_branch = 'current-branch' } }

  before do
    allow(assertion).to receive(:`).with(String) { |command| execute_mocked_command(mocked_commands, command) }
  end

  describe '#assert' do
    subject do
      @stdout, @stderr, exception = capture_output { assertion.assert }
      raise exception if exception
    end
    let(:stdout) { @stdout }
    let(:stderr) { @stderr }

    before do
      allow(File).to receive(:exist?).and_call_original
    end

    let(:git_command) { 'git branch --show-current' }

    context 'when the remote release branch does not exist' do
      let(:mocked_commands) do
        [
          MockedCommand.new(
            "git ls-remote --heads --exit-code 'origin' 'current-branch' >/dev/null 2>&1", exitstatus: 2
          )
        ]
      end

      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when the remote release branches exists' do
      let(:mocked_commands) do
        [
          MockedCommand.new(
            "git ls-remote --heads --exit-code 'origin' 'current-branch' >/dev/null 2>&1", exitstatus: 0
          )
        ]
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to start_with("ERROR: 'current-branch' already exists")
      end
    end

    context 'when the git command fails' do
      let(:mocked_commands) do
        [
          MockedCommand.new(
            "git ls-remote --heads --exit-code 'origin' 'current-branch' >/dev/null 2>&1", exitstatus: 1
          )
        ]
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to start_with('ERROR: Could not list branches')
      end
    end
  end
end
