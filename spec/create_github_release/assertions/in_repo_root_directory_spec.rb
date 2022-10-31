# frozen_string_literal: true

require 'fileutils'

RSpec.describe CreateGithubRelease::Assertions::InRepoRootDirectory do
  let(:assertion) { described_class.new(options) }
  let(:options) { CreateGithubRelease::Options.new { |o| o.release_type = 'major' } }

  before do
    allow(assertion).to receive(:`).with(String) { |command| execute_mocked_command(mocked_commands, command) }
  end

  describe '#assert' do
    subject { @stdout, @stderr = capture_output { assertion.assert } }
    let(:stdout) { @stdout }
    let(:stderr) { @stderr }

    let(:current_directory) { '/current/directory' }

    before do
      allow(FileUtils).to receive(:pwd).and_return(current_directory)
    end

    context 'when in the repo root directory' do
      let(:mocked_commands) { [MockedCommand.new('git rev-parse --show-toplevel', stdout: "#{current_directory}\n")] }
      it 'should succeed' do
        expect { subject }.not_to raise_error
      end
    end

    context 'when NOT in the repo root directory' do
      let(:mocked_commands) { [MockedCommand.new('git rev-parse --show-toplevel', stdout: "/other/directory\n")] }
      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
      end
    end

    context 'when the git command fails' do
      let(:mocked_commands) { [MockedCommand.new('git rev-parse --show-toplevel', exitstatus: 1)] }
      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
      end
    end
  end
end
