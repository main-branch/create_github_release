# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Tasks::PushRelease do
  let(:task) { described_class.new(project) }

  let(:release_branch) { 'release-v1.0.0' }
  let(:remote) { 'upstream' }

  let(:project) do
    CreateGithubRelease::Project.new(options) do |p|
      p.release_branch = release_branch
      p.remote = remote
    end
  end

  let(:options) { CreateGithubRelease::CommandLine::Options.new { |o| o.release_type = 'major' } }

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
        MockedCommand.new(
          "git push --tags --set-upstream '#{remote}' '#{release_branch}' > /dev/null 2>&1",
          exitstatus: git_exitstatus
        )
      ]
    end

    context 'when the release is pushed' do
      let(:git_exitstatus) { 0 }
      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when the release is not pushed' do
      let(:git_exitstatus) { 1 }
      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to start_with('ERROR: Could not push release commit')
      end
    end
  end
end
