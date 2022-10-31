# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Assertions::NoStagedChanges do
  let(:assertion) { described_class.new(options) }
  let(:options) { CreateGithubRelease::Options.new { |o| o.release_type = 'major' } }

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

    let(:git_command) { 'git diff --staged --name-only | wc -l' }

    context 'when there are not staged changes' do
      let(:mocked_commands) { [MockedCommand.new(git_command, stdout: "0\n")] }
      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when there are staged changes' do
      let(:mocked_commands) { [MockedCommand.new(git_command, stdout: "99\n")] }
      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
      end
    end

    context 'when the git command fails' do
      let(:mocked_commands) { [MockedCommand.new(git_command, exitstatus: 1)] }
      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
      end
    end
  end
end
