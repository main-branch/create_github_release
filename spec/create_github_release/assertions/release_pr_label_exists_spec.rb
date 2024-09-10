# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Assertions::ReleasePrLabelExists do
  let(:assertion) { described_class.new(project) }
  let(:options) { CreateGithubRelease::CommandLine::Options.new { |o| o.release_type = 'major' } }
  let(:project) { CreateGithubRelease::Project.new(options) { |p| p.release_pr_label = release_pr_label } }
  let(:release_pr_label) { nil }

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

    context 'when release pr label is nil' do
      let(:mocked_commands) { [] }
      it 'should not raise an error' do
        expect { assertion.assert }.not_to raise_error
      end
    end

    context 'when release pr label is "release"' do
      let(:release_pr_label) { 'release' }

      context 'when the label exists' do
        let(:mocked_commands) do
          [
            MockedCommand.new('gh label list', stdout: <<~LABELS)
              bug\tSomething isn't working\t#d73a4a
              release\tThe PR represents a release\t#0075ca
              duplicate\tThis issue or pull request already exists\t#cfd3d7
            LABELS
          ]
        end

        it 'should not raise an error' do
          expect { assertion.assert }.not_to raise_error
        end
      end

      context 'when the label does not exist' do
        let(:mocked_commands) do
          [
            MockedCommand.new('gh label list', stdout: <<~LABELS)
              bug\tSomething isn't working\t#d73a4a
              duplicate\tThis issue or pull request already exists\t#cfd3d7
            LABELS
          ]
        end

        it 'should fail' do
          expect { subject }.to raise_error(SystemExit)
          expect(stderr).to start_with("ERROR: Release pr label 'release' does not exist\n")
        end
      end
    end

    context 'when the gh command fails' do
      let(:release_pr_label) { 'release' }

      let(:mocked_commands) do
        [
          MockedCommand.new('gh label list', exitstatus: 1)
        ]
      end

      it 'should fail' do
        expect { subject }.to raise_error(SystemExit)
        expect(stderr).to start_with('ERROR: Could not list pr labels')
      end
    end
  end
end

#     context 'when this is the first release' do
#       let(:release_type) { 'first' }
#       let(:mocked_commands) { [] }
#       it 'should not raise an error' do
#         expect { assertion.assert }.not_to raise_error
#       end
#     end

#     context 'when this is NOT the first release' do
#       context 'when the last release tag does not exist' do
#         let(:mocked_commands) do
#           [
#             MockedCommand.new('git tag --list "v0.0.0"', stdout: "\n")
#           ]
#         end

#         it 'should fail' do
#           expect { subject }.to raise_error(SystemExit)
#           expect(stderr).to start_with("ERROR: Last release tag 'v0.0.0' does not exist")
#         end
#       end

#       context 'when the last release tag exists' do
#         let(:mocked_commands) do
#           [
#             MockedCommand.new('git tag --list "v0.0.0"', stdout: "v0.0.0\n")
#           ]
#         end

#         it 'should succeed' do
#           expect { subject }.not_to raise_error
#         end
#       end

#       context 'when the git command fails' do
#         let(:mocked_commands) do
#           [
#             MockedCommand.new('git tag --list "v0.0.0"', exitstatus: 1)
#           ]
#         end

#         it 'should fail' do
#           expect { subject }.to raise_error(SystemExit)
#           expect(stderr).to start_with('ERROR: Could not list tags')
#         end
#       end
#     end
#   end
# end
