# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Assertions::RemoteReleaseTagDoesNotExist do
  let(:assertion) { described_class.new(project) }
  let(:options) { CreateGithubRelease::CommandLine::Options.new { |o| o.release_type = 'major' } }
  let(:project) { CreateGithubRelease::Project.new(options) { |p| p.next_release_tag = 'v1.0.0' } }

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

    context 'when the remote release tag does not exist' do
      let(:mocked_commands) do
        [
          MockedCommand.new("git ls-remote --tags --exit-code 'origin' v1.0.0 >/dev/null 2>&1", exitstatus: 2)
        ]
      end

      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when the remote release tag exists' do
      let(:mocked_commands) do
        [
          MockedCommand.new("git ls-remote --tags --exit-code 'origin' v1.0.0 >/dev/null 2>&1", exitstatus: 0)
        ]
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to start_with("ERROR: Remote tag 'v1.0.0' already exists")
      end
    end

    context 'when the git command fails' do
      let(:mocked_commands) do
        [
          MockedCommand.new("git ls-remote --tags --exit-code 'origin' v1.0.0 >/dev/null 2>&1", exitstatus: 1)
        ]
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to start_with('ERROR: Could not list tags')
      end
    end
  end
end
