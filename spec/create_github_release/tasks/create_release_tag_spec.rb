# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Tasks::CreateReleaseTag do
  let(:task) { described_class.new(options) }
  let(:options) { CreateGithubRelease::Options.new { |o| o.release_type = 'major' } }

  before do
    allow(task).to receive(:`).with(String) { |command| execute_mocked_command(mocked_commands, command) }
  end

  describe '#run' do
    subject { @stdout, @stderr = capture_output { task.run } }
    let(:stdout) { @stdout }
    let(:stderr) { @stderr }

    let(:mocked_commands) do
      [
        MockedCommand.new("git tag 'v1.0.0'", exitstatus: git_exitstatus)
      ]
    end

    context 'when the release tag is created' do
      let(:git_exitstatus) { 0 }
      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when the release tag is not created' do
      let(:git_exitstatus) { 1 }
      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
      end
    end
  end
end
