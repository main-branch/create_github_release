# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Assertions::InGitRepo do
  let(:assertion) { described_class.new(options) }
  let(:options) { CreateGithubRelease::Options.new { |o| o.release_type = 'major' } }

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

    let(:mocked_commands) do
      [
        MockedCommand.new('git rev-parse --is-inside-work-tree --quiet > /dev/null 2>&1', exitstatus: exitstatus)
      ]
    end

    context 'when in a git repo' do
      let(:exitstatus) { 0 }
      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when not in a git repo' do
      let(:exitstatus) { 1 }
      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to start_with('ERROR: You are not in a git repo')
      end
    end
  end
end
