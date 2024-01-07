# frozen_string_literal: true

require 'tmpdir'

RSpec.describe CreateGithubRelease::CommandLine::Parser do
  let(:parser) { described_class.new }

  describe '#initialize' do
    subject { parser }
    it { is_expected.to be_a described_class }
  end

  describe '#parse' do
    subject { parser.parse(*args) }

    context 'when a release type is not given' do
      let(:args) { [] }
      it 'should exit and report the expected error' do
        expect { subject }.to raise_error(SystemExit).and output(/^ERROR: RELEASE_TYPE must be given/).to_stderr
      end
    end

    #########################################
    # for a pre release
    #########################################

    context 'for a pre release' do
      context "when given 'pre' for RELEASE_TYPE and no other args" do
        let(:args) { ['pre'] }
        it "should return release_type == 'pre' and the rest of the options set to defaults" do
          expect(subject).to(
            have_attributes(
              release_type: 'pre',
              pre: false,
              pre_type: nil,
              default_branch: nil,
              release_branch: nil,
              remote: nil,
              last_release_version: nil,
              next_release_version: nil,
              changelog_path: nil,
              quiet: false,
              verbose: false
            )
          )
        end

        it 'should be valid and have no errors' do
          expect(subject).to(have_attributes(valid?: true, errors: []))
        end
      end

      context 'when the --pre option is given' do
        let(:args) { ['pre', '--pre'] }
        it 'should exit and report an error' do
          expect { subject }.to raise_error(SystemExit).and output(/^ERROR: --pre can only be given with/).to_stderr
        end
      end

      context 'when --pre-type=alpha is given' do
        let(:args) { ['pre', '--pre-type=alpha'] }
        it 'should set the pre-type option to the given value' do
          expect(subject).to(have_attributes(pre_type: 'alpha', errors: []))
        end
      end
    end

    #########################################
    # for a release of a pre release
    #########################################

    context 'for a release of a pre release' do
      context "when given 'release' for RELEASE_TYPE and no other args" do
        let(:args) { ['release'] }
        it "should return release_type == 'release' and the rest of the options set to defaults" do
          expect(subject).to(
            have_attributes(
              release_type: 'release',
              pre: false,
              pre_type: nil,
              default_branch: nil,
              release_branch: nil,
              remote: nil,
              last_release_version: nil,
              next_release_version: nil,
              changelog_path: nil,
              quiet: false,
              verbose: false
            )
          )
        end

        it 'should be valid and have no errors' do
          expect(subject).to(have_attributes(valid?: true, errors: []))
        end
      end

      context 'when the --pre option is given' do
        let(:args) { ['release', '--pre'] }
        it 'should exit and report an error' do
          expect { subject }.to raise_error(SystemExit).and output(/^ERROR: --pre can only be given with/).to_stderr
        end
      end

      context 'when the --pre-type option is given' do
        let(:args) { ['release', '--pre-type=alpha'] }
        it 'should exit and report an error' do
          expect { subject }.to raise_error(SystemExit).and output(/^ERROR: --pre-type can only be given/).to_stderr
        end
      end
    end

    #########################################
    # for a patch release
    #########################################

    context 'for a patch release' do
      context "when given 'patch' for RELEASE_TYPE and no other args" do
        let(:args) { ['patch'] }
        it "should return release_type == 'patch' and the rest of the options set to defaults" do
          expect(subject).to(
            have_attributes(
              release_type: 'patch',
              pre: false,
              pre_type: nil,
              default_branch: nil,
              release_branch: nil,
              remote: nil,
              last_release_version: nil,
              next_release_version: nil,
              changelog_path: nil,
              quiet: false,
              verbose: false
            )
          )
        end

        it 'should be valid and have no errors' do
          expect(subject).to(have_attributes(valid?: true, errors: []))
        end
      end

      context 'when the --quiet option is given' do
        let(:args) { ['patch', '--quiet'] }
        it { is_expected.to have_attributes(release_type: 'patch', quiet: true) }
      end

      context 'when the --help options is given' do
        let(:args) { ['--help'] }
        it 'should exit and display the command usage' do
          expect { subject }.to raise_error(SystemExit).and output(/^Usage:/).to_stdout
        end
      end

      context 'when the --default-branch option is given' do
        let(:args) { ['patch', '--default-branch=main'] }
        it 'should set default_branch to the given value' do
          expect(subject).to(have_attributes(default_branch: 'main'))
        end
      end

      context 'when the --release-branch option is given' do
        let(:args) { ['patch', '--release-branch=release-v1.0.1'] }
        it 'should set release_branch to the given value' do
          expect(subject).to(have_attributes(release_branch: 'release-v1.0.1'))
        end
      end

      context 'when the --remote option is given' do
        let(:args) { ['patch', '--remote=origin'] }
        it 'should set remote to the given value' do
          expect(subject).to(have_attributes(remote: 'origin'))
        end
      end

      context 'when the --last-release-version option is given' do
        let(:args) { ['patch', '--last-release-version=1.0.0'] }
        it 'should set last_release_version to the given value' do
          expect(subject).to(have_attributes(last_release_version: '1.0.0'))
        end
      end

      context 'when the --next-release-version option is given' do
        let(:args) { ['patch', '--next-release-version=1.0.1'] }
        it 'should set next_release_version to the given value' do
          expect(subject).to(have_attributes(next_release_version: '1.0.1'))
        end
      end

      context 'when the --changelog-path option is given' do
        let(:args) { ['patch', '--changelog-path=CHANGELOG.md'] }
        it 'should set changelog_path to the given value' do
          expect(subject).to(have_attributes(changelog_path: 'CHANGELOG.md'))
        end
      end

      context 'when the --pre option is given without --pre-type' do
        let(:args) { ['patch', '--pre'] }
        it 'should set the pre flag and pre_type should be nil' do
          expect(subject).to(have_attributes(pre: true, pre_type: nil))
        end
      end

      context 'when the --pre option is given with --pre-type=alpha' do
        let(:args) { ['patch', '--pre', '--pre-type=alpha'] }
        it 'should set the pre flag to true and set pre-type to the given value' do
          expect(subject).to(have_attributes(pre: true, pre_type: 'alpha'))
        end
      end

      context 'when --pre-type=alpha is given without --pre' do
        let(:args) { ['patch', '--pre-type=alpha'] }
        it 'should exit and report an error' do
          expect { subject }.to(
            raise_error(SystemExit).and(
              output(/^ERROR: --pre must be given when --pre-type is given/).to_stderr
            )
          )
        end
      end

      context 'when the --quiet option is given' do
        let(:args) { ['patch', '--quiet'] }
        it 'should set the quiet option to true' do
          expect(subject).to(have_attributes(quiet: true))
        end
      end

      context 'when the --verbose option is given' do
        let(:args) { ['patch', '--verbose'] }
        it 'should set the verbose option to true' do
          expect(subject).to(have_attributes(verbose: true))
        end
      end

      context 'when too many args are given' do
        let(:args) { %w[major minor] }
        it 'should exit' do
          expect { subject }.to raise_error(SystemExit).and output(/^ERROR: Too many args/).to_stderr
        end
      end

      context 'when a value is not given to an option that requires a value' do
        let(:args) { ['patch', '--default-branch'] }
        it 'should exit and report the expected error' do
          expect { subject }.to(
            raise_error(SystemExit).and(output(/^ERROR: missing argument: --default-branch/).to_stderr)
          )
        end
      end

      context 'when an option is given an invalid value' do
        let(:args) { ['patch', '--remote=/bogus'] }
        it 'should exit and report the expected error' do
          expect { subject }.to raise_error(SystemExit).and output(%r{^ERROR: --remote='/bogus' is not valid}).to_stderr
        end
      end

      context 'when more than one invalid option value is given' do
        let(:args) { ['patch', '--remote=/bogus', '--default-branch=/bogus'] }
        it 'should exit and report the remote error' do
          expect { subject }.to raise_error(SystemExit).and output(%r{ERROR: --remote='/bogus' is not valid}).to_stderr
        end
        it 'should also report the default-branch error' do
          expect do
            subject
          end.to raise_error(SystemExit).and output(%r{ERROR: --default-branch='/bogus' is not valid}).to_stderr
        end
      end

      context 'when an invalid release type is given' do
        let(:args) { ['bogus'] }
        it 'should exit and report the expected error' do
          expect { subject }.to(
            raise_error(SystemExit).and(output(/^ERROR: RELEASE_TYPE 'bogus' is not valid/).to_stderr)
          )
        end
      end

      context 'when an unexpected option is given' do
        let(:args) { ['--bogus'] }
        it 'should exit and report the expected error' do
          expect { subject }.to raise_error(SystemExit).and output(/^ERROR: invalid option: --bogus/).to_stderr
        end
      end
    end
  end
end
