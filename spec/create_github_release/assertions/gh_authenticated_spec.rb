# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Assertions::GhAuthenticated do
  let(:assertion) { described_class.new(project) }
  let(:options) { CreateGithubRelease::CommandLine::Options.new { |o| o.release_type = 'major' } }
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
      # allow(File).to receive(:exist?).and_call_original
    end

    let(:mocked_commands) do
      [
        MockedCommand.new('gh auth status 2>&1', stdout: stdout, exitstatus: exitstatus)
      ]
    end

    context 'when gh command is authenticated' do
      let(:stdout) { '' }
      let(:exitstatus) { 0 }
      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when gh command is NOT authenticated' do
      let(:stdout) { 'XXXERRORXXX' }
      let(:exitstatus) { 1 }
      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to start_with("ERROR: gh not authenticated:\nXXXERRORXXX")
      end
    end
  end
end
