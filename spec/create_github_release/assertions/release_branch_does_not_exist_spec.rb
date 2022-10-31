# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Assertions::ReleaseBranchDoesNotExist do
  let(:assertion) { described_class.new(options) }
  let(:options) do
    CreateGithubRelease::Options.new do |o|
      o.release_type = 'major'
      o.branch = 'current-branch'
    end
  end

  before do
    allow(assertion).to receive(:`).with(String) { |command| execute_mocked_command(mocked_commands, command) }
    allow(options).to receive(:`).with(String) { |command| execute_mocked_command(mocked_commands, command) }
  end

  describe '#assert' do
    subject { @stdout, @stderr = capture_output { assertion.assert } }
    let(:stdout) { @stdout }
    let(:stderr) { @stderr }

    before do
      allow(File).to receive(:exist?).and_call_original
    end

    let(:git_command) { 'git branch --show-current' }

    context 'when NEITHER local NOR remote release branches exist' do
      let(:mocked_commands) do
        [
          MockedCommand.new('git branch --list "current-branch" | wc -l', stdout: "0\n"),
          MockedCommand.new(
            "git ls-remote --heads --exit-code 'origin' 'current-branch' >/dev/null 2>&1", exitstatus: 1
          )
        ]
      end

      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when the local release branch exists' do
      let(:mocked_commands) do
        [
          MockedCommand.new('git branch --list "current-branch" | wc -l', stdout: "1\n"),
          MockedCommand.new(
            "git ls-remote --heads --exit-code 'origin' 'current-branch' >/dev/null 2>&1", exitstatus: 1
          )
        ]
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
      end
    end

    context 'when the remote release branch exists' do
      let(:mocked_commands) do
        [
          MockedCommand.new('git branch --list "current-branch" | wc -l', stdout: "0\n"),
          MockedCommand.new(
            "git ls-remote --heads --exit-code 'origin' 'current-branch' >/dev/null 2>&1", exitstatus: 0
          )
        ]
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
      end
    end

    context 'when the local AND remote release branches exist' do
      let(:mocked_commands) do
        [
          MockedCommand.new('git branch --list "current-branch" | wc -l', stdout: "1\n"),
          MockedCommand.new(
            "git ls-remote --heads --exit-code 'origin' 'current-branch' >/dev/null 2>&1", exitstatus: 0
          )
        ]
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
      end
    end

    context 'when the git command for the local release branch fails' do
      let(:mocked_commands) do
        [
          MockedCommand.new('git branch --list "current-branch" | wc -l', exitstatus: 1),
          MockedCommand.new(
            "git ls-remote --heads --exit-code 'origin' 'current-branch' >/dev/null 2>&1", exitstatus: 1
          )
        ]
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
      end
    end
  end
end
