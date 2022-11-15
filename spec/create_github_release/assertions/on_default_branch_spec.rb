# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Assertions::OnDefaultBranch do
  let(:assertion) { described_class.new(options) }
  let(:options) do
    CreateGithubRelease::Options.new do |o|
      o.release_type = 'major'
      o.default_branch = 'default-branch'
    end
  end

  before do
    allow(assertion).to receive(:`).with(String) { |command| execute_mocked_command(mocked_commands, command) }
    allow(options).to receive(:`).with(String) { |command| execute_mocked_command(mocked_commands, command) }
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

    context 'when on the default branch' do
      let(:mocked_commands) { [MockedCommand.new(git_command, stdout: "default-branch\n")] }
      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when not on the default branch' do
      let(:mocked_commands) { [MockedCommand.new(git_command, stdout: "other-branch\n")] }
      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to start_with("ERROR: You are not on the default branch 'default-branch'")
      end
    end

    context 'when the git command fails' do
      let(:mocked_commands) { [MockedCommand.new(git_command, exitstatus: 1)] }
      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to start_with("ERROR: You are not on the default branch 'default-branch'")
      end
    end
  end
end
