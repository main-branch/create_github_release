# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Tasks::CreateReleasePullRequest do
  let(:task) { described_class.new(project) }

  let(:options) { CreateGithubRelease::CommandLine::Options.new(release_type: 'major') }

  let(:default_branch) { 'main' }
  let(:next_release_tag) { 'v1.0.0' }
  let(:next_release_description) { '<imagine release description here>' }

  let(:project) do
    CreateGithubRelease::Project.new(options) do |p|
      p.default_branch = default_branch
      p.next_release_tag = next_release_tag
      p.next_release_description = next_release_description
    end
  end

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

    let(:pr_body_file) { Object.new }

    let(:tmp_file) { '/tmp/pr_body' }

    let(:expected_pr_body) { <<~PR_BODY.chomp }
      # Release PR

      #{next_release_description}
    PR_BODY

    before do
      allow(Tempfile).to receive(:create).and_return(pr_body_file)
      allow(pr_body_file).to receive(:path).and_return(tmp_file)
      allow(File).to receive(:unlink).with(tmp_file)
    end

    let(:mocked_commands) do
      [
        MockedCommand.new(
          "gh pr create --title 'Release #{next_release_tag}' --body-file '#{tmp_file}' --base '#{default_branch}'",
          stdout: '',
          exitstatus: gh_exitstatus
        )
      ]
    end

    context 'when the release pull request is created' do
      before do
        expect(pr_body_file).to receive(:write).with(expected_pr_body)
        expect(pr_body_file).to receive(:close)
      end

      let(:gh_exitstatus) { 0 }

      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when the pr body file could not be generated' do
      let(:gh_exitstatus) { 1 }

      before do
        expect(pr_body_file).to receive(:write).with(expected_pr_body)
        expect(pr_body_file).to receive(:close)
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to start_with('ERROR: Could not create release pull request')
      end
    end

    context 'when the pr body file could not be created' do
      before do
        allow(Tempfile).to receive(:create).and_raise(Errno::EACCES, 'Permission denied')
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to start_with('ERROR: Could not create a temporary file')
      end
    end

    context 'when the pull request could not be created' do
      let(:docker_exitstatus) { 0 }
      let(:gh_exitstatus) { 1 }
      before do
        expect(pr_body_file).to receive(:write).with(expected_pr_body)
        expect(pr_body_file).to receive(:close)
        expect(File).to receive(:unlink).with('/tmp/pr_body')
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to start_with('ERROR: Could not create release pull request')
      end
    end
  end
end
