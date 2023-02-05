# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Assertions::LastReleaseTagExists do
  let(:release_type) { 'major' }
  let(:assertion) { described_class.new(project) }
  let(:options) { CreateGithubRelease::CommandLineOptions.new { |o| o.release_type = release_type } }
  let(:project) { CreateGithubRelease::Project.new(options) { |p| p.last_release_tag = 'v0.0.0' } }

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

    context 'when this is the first release' do
      let(:release_type) { 'first' }
      let(:mocked_commands) { [] }
      it 'should not raise an error' do
        expect { assertion.assert }.not_to raise_error
      end
    end

    context 'when this is NOT the first release' do
      context 'when the last release tag does not exist' do
        let(:mocked_commands) do
          [
            MockedCommand.new('git tag --list "v0.0.0"', stdout: "\n")
          ]
        end

        it 'should fail' do
          expect { subject }.to raise_error(SystemExit)
          expect(stderr).to start_with("ERROR: Last release tag 'v0.0.0' does not exist")
        end
      end

      context 'when the last release tag exists' do
        let(:mocked_commands) do
          [
            MockedCommand.new('git tag --list "v0.0.0"', stdout: "v0.0.0\n")
          ]
        end

        it 'should succeed' do
          expect { subject }.not_to raise_error
        end
      end

      context 'when the git command fails' do
        let(:mocked_commands) do
          [
            MockedCommand.new('git tag --list "v0.0.0"', exitstatus: 1)
          ]
        end

        it 'should fail' do
          expect { subject }.to raise_error(SystemExit)
          expect(stderr).to start_with('ERROR: Could not list tags')
        end
      end
    end
  end
end
