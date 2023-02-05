# frozen_string_literal: true

require 'tmpdir'

RSpec.describe CreateGithubRelease::CommandLineOptions do
  let(:current_version) { '0.1.0' }
  let(:release_type) { 'major' }

  let(:options) { described_class.new }

  describe '#initialize' do
    context 'without a block or keyword args (default values)' do
      subject { described_class.new }
      it do
        is_expected.to have_attributes(
          release_type: nil,
          default_branch: nil,
          release_branch: nil,
          remote: nil,
          last_release_version: nil,
          next_release_version: nil,
          changelog_path: nil,
          quiet: false,
          verbose: false
        )
      end

      it do
        is_expected.to have_attributes(valid?: false)
        is_expected.to have_attributes(errors: [/^RELEASE_TYPE must be given/])
      end
    end

    context 'with a block' do
      subject do
        described_class.new do |o|
          o.release_type = 'major'
          o.default_branch = 'main'
          o.release_branch = 'release-v5.0.0'
          o.remote = 'origin'
          o.last_release_version = '5.0.0'
          o.next_release_version = '6.0.0'
          o.changelog_path = 'CHANGELOG.md'
          o.quiet = true
          o.verbose = false
        end
      end

      it do
        is_expected.to have_attributes(
          release_type: 'major',
          default_branch: 'main',
          release_branch: 'release-v5.0.0',
          remote: 'origin',
          last_release_version: '5.0.0',
          next_release_version: '6.0.0',
          changelog_path: 'CHANGELOG.md',
          quiet: true,
          verbose: false
        )
      end

      it { is_expected.to have_attributes(valid?: true) }
    end

    context 'with keyword arguments' do
      subject do
        described_class.new(
          release_type: 'major',
          default_branch: 'main',
          release_branch: 'release-v5.0.0',
          remote: 'origin',
          last_release_version: '5.0.0',
          next_release_version: '6.0.0',
          changelog_path: 'CHANGELOG.md',
          quiet: true,
          verbose: false
        )
      end

      it do
        is_expected.to have_attributes(
          release_type: 'major',
          default_branch: 'main',
          release_branch: 'release-v5.0.0',
          remote: 'origin',
          last_release_version: '5.0.0',
          next_release_version: '6.0.0',
          changelog_path: 'CHANGELOG.md',
          quiet: true,
          verbose: false
        )
      end

      it { is_expected.to have_attributes(valid?: true) }
    end
  end

  describe '#valid? and #errors' do
    before { options.release_type = 'major' }

    subject { options }

    context 'when both quiet and verbose are true' do
      before do
        options.quiet = true
        options.verbose = true
      end

      it do
        is_expected.to(
          have_attributes(
            valid?: false,
            errors: [/^Both --quiet and --verbose cannot both be used/]
          )
        )
      end
    end

    context 'when quiet is neither true nor false' do
      before do
        options.quiet = 'bogus'
      end

      it do
        is_expected.to(
          have_attributes(
            valid?: false,
            errors: [/^quiet must be either true or false/]
          )
        )
      end
    end

    context 'when verbose is neither true nor false' do
      before do
        options.verbose = 'bogus'
      end

      it do
        is_expected.to(
          have_attributes(
            valid?: false,
            errors: [/^verbose must be either true or false/]
          )
        )
      end
    end

    context "when release_type is 'first'" do
      before do
        options.release_type = 'first'
      end

      it { is_expected.to have_attributes(valid?: true, errors: []) }
    end

    context 'when release_type is nil' do
      before do
        options.release_type = nil
      end

      it do
        is_expected.to(
          have_attributes(
            valid?: false,
            errors: [/^RELEASE_TYPE must be given/]
          )
        )
      end
    end

    context 'when release_type is not valid' do
      before do
        options.release_type = 'bogus'
      end

      it do
        is_expected.to(
          have_attributes(
            valid?: false,
            errors: [/^RELEASE_TYPE 'bogus' is not valid/]
          )
        )
      end
    end

    context 'when default_branch is not a valid branch name' do
      before do
        options.default_branch = '/bogus'
      end

      it do
        is_expected.to(
          have_attributes(
            valid?: false,
            errors: ["--default-branch='/bogus' is not valid"]
          )
        )
      end
    end

    context 'when release_branch is not a valid branch name' do
      before do
        options.release_branch = '/bogus'
      end

      it do
        is_expected.to(
          have_attributes(
            valid?: false,
            errors: ["--release-branch='/bogus' is not valid"]
          )
        )
      end
    end

    context 'when remote is not a valid remote name' do
      before do
        options.remote = '/bogus'
      end

      it do
        is_expected.to(
          have_attributes(
            valid?: false,
            errors: ["--remote='/bogus' is not valid"]
          )
        )
      end
    end

    context 'when last_release_version is not a valid gem version' do
      before do
        options.last_release_version = 'A.B.C'
      end

      it do
        is_expected.to(
          have_attributes(
            valid?: false,
            errors: ["--last-release-version='A.B.C' is not valid"]
          )
        )
      end
    end

    context 'when next_release_version is not a valid gem version' do
      before do
        options.next_release_version = 'A.B.C'
      end

      it do
        is_expected.to(
          have_attributes(
            valid?: false,
            errors: ["--next-release-version='A.B.C' is not valid"]
          )
        )
      end
    end

    context 'when the changelog_path is not a valid path' do
      before do
        options.changelog_path = "A\u0000B"
      end

      it do
        is_expected.to(
          have_attributes(
            valid?: false,
            errors: ["--changelog-path='A\u0000B' is not valid"]
          )
        )
      end
    end

    context 'when changelog_path is not a path to a normal file' do
      before do
        options.changelog_path = 'CHANGELOG.md'
        allow(File).to receive(:exist?).with('CHANGELOG.md').and_return(true)
        allow(File).to receive(:file?).with('CHANGELOG.md').and_return(false)
      end

      it do
        is_expected.to(
          have_attributes(
            valid?: false,
            errors: ["--changelog-path='CHANGELOG.md' must be a regular file"]
          )
        )
      end
    end

    context 'when there are multiple errors' do
      before do
        options.release_type = nil
        options.default_branch = '/bogus'
        options.quiet = 'bogus'
      end

      it 'is expected to report all errors' do
        expect(subject.errors).to(
          include('quiet must be either true or false').and(
            include(/^RELEASE_TYPE must be given/).and(
              include("--default-branch='/bogus' is not valid")
            )
          )
        )
      end
    end
  end
end
