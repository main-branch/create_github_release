# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Assertions::LocalAndRemoteOnSameCommit do
  let(:assertion) { described_class.new(project) }
  let(:options) do
    CreateGithubRelease::CommandLineOptions.new do |o|
      o.release_type = 'major'
      o.default_branch = 'default-branch'
    end
  end
  let(:project) { CreateGithubRelease::Project.new(options) }

  before do
    allow(assertion).to receive(:`).with(String) { |command| execute_mocked_command(mocked_commands, command) }
    allow(project).to receive(:`).with(String) { |command| execute_mocked_command(mocked_commands, command) }
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
        MockedCommand.new(
          'git rev-parse HEAD',
          stdout: "#{local_commit}\n",
          exitstatus: exitstatus
        ),
        MockedCommand.new(
          "git ls-remote 'origin' 'default-branch' | cut -f 1",
          stdout: "#{remote_commit}\n",
          exitstatus: exitstatus
        )
      ]
    end

    context 'when the local and remote commits are the same' do
      let(:exitstatus) { 0 }
      let(:local_commit) { '976b79' }
      let(:remote_commit) { '976b79' }
      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when the local and remote commits are different' do
      let(:exitstatus) { 0 }
      let(:local_commit) { '976b79' }
      let(:remote_commit) { '9535c0' }
      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to start_with('ERROR: Local and remote are not on the same commit')
      end
    end
  end
end
