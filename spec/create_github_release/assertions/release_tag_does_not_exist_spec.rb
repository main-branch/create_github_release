# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Assertions::ReleaseTagDoesNotExist do
  let(:assertion) { described_class.new(options) }
  let(:options) do
    CreateGithubRelease::Options.new do |o|
      o.release_type = 'major'
      o.tag = 'v1.0.0'
    end
  end

  before do
    allow(assertion).to receive(:`).with(String) { |command| execute_mocked_command(mocked_commands, command) }
  end

  describe '#assert' do
    subject { @stdout, @stderr = capture_output { assertion.assert } }
    let(:stdout) { @stdout }
    let(:stderr) { @stderr }

    before do
      allow(File).to receive(:exist?).and_call_original
    end

    let(:git_command) { 'git branch --show-current' }

    context 'when NEITHER local NOR remote release tags exist' do
      let(:mocked_commands) do
        [
          MockedCommand.new('git tag --list "v1.0.0"'),
          MockedCommand.new("git ls-remote --tags --exit-code 'origin' v1.0.0 >/dev/null 2>&1", exitstatus: 1)
        ]
      end

      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when the local release tag exists' do
      let(:mocked_commands) do
        [
          MockedCommand.new('git tag --list "v1.0.0"', stdout: "v1.0.0\n"),
          MockedCommand.new("git ls-remote --tags --exit-code 'origin' v1.0.0 >/dev/null 2>&1", exitstatus: 1)
        ]
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
      end
    end

    context 'when the remote release tag exists' do
      let(:mocked_commands) do
        [
          MockedCommand.new('git tag --list "v1.0.0"'),
          MockedCommand.new("git ls-remote --tags --exit-code 'origin' v1.0.0 >/dev/null 2>&1", exitstatus: 0)
        ]
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
      end
    end

    context 'when the local AND remote release tags exist' do
      let(:mocked_commands) do
        [
          MockedCommand.new('git tag --list "v1.0.0"', stdout: "v1.0.0\n"),
          MockedCommand.new("git ls-remote --tags --exit-code 'origin' v1.0.0 >/dev/null 2>&1", exitstatus: 0)
        ]
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
      end
    end

    context 'when the git command for the local release tag fails' do
      let(:mocked_commands) do
        [
          MockedCommand.new('git tag --list "v1.0.0"', exitstatus: 1),
          MockedCommand.new("git ls-remote --tags --exit-code 'origin' v1.0.0 >/dev/null 2>&1", exitstatus: 1)
        ]
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
      end
    end
  end
end
