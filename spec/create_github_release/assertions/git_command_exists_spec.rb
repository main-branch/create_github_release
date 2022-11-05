# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Assertions::GitCommandExists do
  let(:assertion) { described_class.new(options) }
  let(:options) { CreateGithubRelease::Options.new { |o| o.release_type = 'major' } }

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

    let(:mocked_commands) do
      [
        MockedCommand.new('which git > /dev/null 2>&1', exitstatus: exitstatus)
      ]
    end

    context 'when git command exists' do
      let(:exitstatus) { 0 }
      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when git command does not exist' do
      let(:exitstatus) { 1 }
      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
      end
    end
  end
end
