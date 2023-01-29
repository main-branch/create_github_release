# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Assertions::LocalReleaseBranchDoesNotExist do
  let(:assertion) { described_class.new(project) }
  let(:options) do
    CreateGithubRelease::CommandLineOptions.new do |o|
      o.release_type = 'major'
      o.release_branch = 'release-branch'
    end
  end
  let(:project) { CreateGithubRelease::Project.new(options) }

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

    context 'when the local release branch does not exist' do
      let(:mocked_commands) do
        [
          MockedCommand.new('git branch --list "release-branch"', stdout: "\n")
        ]
      end

      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when the local release branch exists' do
      let(:mocked_commands) do
        [
          MockedCommand.new('git branch --list "release-branch"', stdout: "  release-branch\n")
        ]
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to start_with("ERROR: Local branch 'release-branch' already exists")
      end
    end

    context 'when the git command fails' do
      let(:mocked_commands) do
        [
          MockedCommand.new('git branch --list "release-branch"', stdout: "0\n", exitstatus: 1)
        ]
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to start_with('ERROR: Could not list branches')
      end
    end
  end
end
