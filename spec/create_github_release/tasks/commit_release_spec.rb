# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Tasks::CommitRelease do
  let(:task) { described_class.new(project) }

  let(:next_release_tag) { 'v1.0.0' }

  let(:project) do
    CreateGithubRelease::Project.new(options) do |p|
      p.next_release_tag = next_release_tag
    end
  end

  let(:options) { CreateGithubRelease::CommandLineOptions.new { |o| o.release_type = 'major' } }

  before do
    allow(task).to receive(:`).with(String) { |command| execute_mocked_command(mocked_commands, command) }
    allow(project).to receive(:`).with(String) { |command| execute_mocked_command(mocked_commands, command) }
  end

  describe '#run' do
    subject do
      @stdout, @stderr, exception = capture_output { task.run }
      raise exception if exception
    end
    let(:stdout) { @stdout }
    let(:stderr) { @stderr }

    let(:mocked_commands) do
      [
        MockedCommand.new("git commit -s -m 'Release #{next_release_tag}'", exitstatus: git_exitstatus)
      ]
    end

    context 'when the commit is successful' do
      let(:git_exitstatus) { 0 }
      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when the commit fails' do
      let(:git_exitstatus) { 1 }
      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to start_with('ERROR: Could not make release commit')
      end
    end
  end
end
