# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Tasks::UpdateVersion do
  let(:task) { described_class.new(options) }
  let(:options) { CreateGithubRelease::Options.new { |o| o.release_type = 'major' } }

  before do
    allow(task).to receive(:`).with(String) { |command| execute_mocked_command(mocked_commands, command) }
  end

  describe '#run' do
    subject { @stdout, @stderr = capture_output { task.run } }
    let(:stdout) { @stdout }
    let(:stderr) { @stderr }

    before do
      allow(Bump::Bump).to receive(:run).with('major', commit: false).and_return(['next.version', bump_result])
    end

    let(:mocked_commands) do
      [
        MockedCommand.new('git add lib/git/version.rb', exitstatus: git_exitstatus)
      ]
    end

    context 'when Bump and git add succeed' do
      let(:bump_result) { 0 }
      let(:git_exitstatus) { 0 }
      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when Bump fails' do
      let(:bump_result) { 1 }
      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
      end
    end

    context 'when git add fails' do
      let(:bump_result) { 0 }
      let(:git_exitstatus) { 1 }
      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
      end
    end
  end
end
