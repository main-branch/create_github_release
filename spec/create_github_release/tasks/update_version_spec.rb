# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Tasks::UpdateVersion do
  let(:release_type) { 'major' }
  let(:pre) { false }
  let(:pre_type) { nil }
  let(:task) { described_class.new(project) }
  let(:project) { CreateGithubRelease::Project.new(options) }
  let(:options) do
    CreateGithubRelease::CommandLine::Options.new do |o|
      o.release_type = release_type
      o.pre = pre
      o.pre_type = pre_type
    end
  end

  let(:version_file) { 'lib/my_gem/version.rb' }

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

    context 'when this is the first release' do
      let(:release_type) { 'first' }
      it 'should not increment the version' do
        expect(task).not_to receive(:increment_version)
        subject
      end
    end

    context 'when this is a pre-release when default pre-release type' do
      let(:pre) { true }

      let(:mocked_commands) do
        [
          MockedCommand.new('gem-version-boss next-major --pre', exitstatus: next_exitstatus),
          MockedCommand.new('gem-version-boss file', stdout: "#{version_file}\n", exitstatus: file_exitstatus),
          MockedCommand.new("git add \"#{version_file}\"", exitstatus: git_exitstatus)
        ]
      end

      let(:next_exitstatus) { 0 }
      let(:file_exitstatus) { 0 }
      let(:git_exitstatus) { 0 }

      it 'should increment the version with the --pre flag' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when this is an alpha pre-release' do
      let(:pre) { true }
      let(:pre_type) { 'alpha' }

      let(:mocked_commands) do
        [
          MockedCommand.new('gem-version-boss next-major --pre --pre-type=alpha', exitstatus: next_exitstatus),
          MockedCommand.new('gem-version-boss file', stdout: "#{version_file}\n", exitstatus: file_exitstatus),
          MockedCommand.new("git add \"#{version_file}\"", exitstatus: git_exitstatus)
        ]
      end

      let(:next_exitstatus) { 0 }
      let(:file_exitstatus) { 0 }
      let(:git_exitstatus) { 0 }

      it 'should increment the version with the --pre and --pre-type=alpha args' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when changing the pre-release type to beta' do
      let(:release_type) { 'pre' }
      let(:pre_type) { 'beta' }

      let(:mocked_commands) do
        [
          MockedCommand.new('gem-version-boss next-pre --pre-type=beta', exitstatus: next_exitstatus),
          MockedCommand.new('gem-version-boss file', stdout: "#{version_file}\n", exitstatus: file_exitstatus),
          MockedCommand.new("git add \"#{version_file}\"", exitstatus: git_exitstatus)
        ]
      end

      let(:next_exitstatus) { 0 }
      let(:file_exitstatus) { 0 }
      let(:git_exitstatus) { 0 }

      it 'should increment the version with the pre release type and --pre-type=alpha arg' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when this is NOT the first release' do
      let(:mocked_commands) do
        [
          MockedCommand.new('gem-version-boss next-major', exitstatus: next_exitstatus),
          MockedCommand.new('gem-version-boss file', stdout: "#{version_file}\n", exitstatus: file_exitstatus),
          MockedCommand.new("git add \"#{version_file}\"", exitstatus: git_exitstatus)
        ]
      end

      let(:next_exitstatus) { 0 }
      let(:file_exitstatus) { 0 }
      let(:git_exitstatus) { 0 }

      context 'when gem-version-boss and git add succeed' do
        it 'should succeed' do
          expect { subject }.not_to raise_error
        end
      end

      context 'when gem-version-boss fails to increment the version' do
        let(:next_exitstatus) { 1 }
        it 'should fail' do
          expect { subject }.to raise_error(SystemExit)
          expect(stderr).to start_with('ERROR: Could not increment version')
        end
      end

      context 'when `gem-version-boss file` fails' do
        let(:file_exitstatus) { 1 }
        it 'should fail' do
          expect { subject }.to raise_error(SystemExit)
          expect(stderr).to start_with('ERROR: Could determine the version file')
        end
      end

      context 'when git add fails' do
        let(:git_exitstatus) { 1 }
        it 'should fail' do
          expect { subject }.to raise_error(SystemExit)
          expect(stderr).to start_with("ERROR: Could not stage changes to #{version_file}")
        end
      end
    end
  end
end
