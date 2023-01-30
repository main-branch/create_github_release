# frozen_string_literal: true

require 'tmpdir'
require 'timecop'

RSpec.describe CreateGithubRelease::Project do
  let(:project) { described_class.new(options) }
  let(:options) { CreateGithubRelease::CommandLineOptions.new { |o| o.release_type = 'major' } }

  before do
    allow(project).to receive(:`).with(String) { |command| execute_mocked_command(mocked_commands, command) }
  end

  let(:mocked_commands) { [] }

  describe '#initialize' do
    context '#without a block' do
      it 'should successfully create a project' do
        expect(described_class.new(options)).to be_a(described_class)
      end
      it 'should set the options attribute' do
        expect(described_class.new(options).options).to eq(options)
      end
    end

    context '#with a block' do
      subject do
        described_class.new(options) { |project| project.release_type = 'minor' }
      end

      it 'should call the block with the project as an argument' do
        expect(subject.release_type).to eq('minor')
      end
    end
  end

  describe '#default_branch' do
    subject { project.default_branch }

    context 'when the options.default_branch is not nil' do
      before { options.default_branch = 'production' }
      it 'should return the options.default_branch' do
        expect(subject).to eq('production')
      end
    end

    context 'when the default branch is not explicitly set' do
      context 'when the git command succeeds' do
        let(:mocked_commands) do
          [
            MockedCommand.new(
              "git remote show 'origin'", stdout: "HEAD branch: xxxx\n"
            )
          ]
        end
        it 'should return the HEAD branch from Github' do
          expect(subject).to eq('xxxx')
        end
      end

      context 'when the git command fails' do
        let(:mocked_commands) do
          [
            MockedCommand.new(
              "git remote show 'origin'", stdout: '', exitstatus: 1
            )
          ]
        end
        it 'should raise an RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end

    context 'when default_branch is explicitly set' do
      before { project.default_branch = 'production' }
      it 'should return the explicitly set default_branch' do
        expect(subject).to eq('production')
      end
    end
  end

  describe '#next_release_tag' do
    subject { project.next_release_tag }

    context 'when next_release_tag is explicitly set with next_release_tag=' do
      before { project.next_release_tag = 'v1.2.3' }
      it { is_expected.to eq('v1.2.3') }
    end

    context 'when next_release_tag is not explicitly set' do
      context 'when the next_release_version is 1.0.0' do
        before { project.next_release_version = '1.0.0' }
        it { is_expected.to eq('v1.0.0') }
      end
    end
  end

  describe '#next_release_date' do
    subject { project.next_release_date }
    let(:next_release_date) { Date.parse('2017-01-01') }

    # before { Timecop.freeze(Date.parse(next_release_date)) }

    context 'when next_release_date is explicitly set with next_release_date=' do
      before { project.next_release_date = next_release_date }
      it { is_expected.to eq(next_release_date) }
    end

    context 'when next_release_date is not explicitly set' do
      context 'when next release tag is v1.0.0' do
        let(:next_release_tag) { 'v1.0.0' }
        before { project.next_release_tag = next_release_tag }
        context 'when tag v1.0.0 exists' do
          context 'when the git tag command fails' do
            let(:mocked_commands) do
              [MockedCommand.new('git tag --list "v1.0.0"', exitstatus: 1)]
            end
            it 'should raise an RuntimeError' do
              expect { subject }.to raise_error(RuntimeError)
            end
          end

          context 'when the tag v1.0.0 does not exist' do
            before { Timecop.freeze(next_release_date) }
            let(:mocked_commands) do
              [MockedCommand.new('git tag --list "v1.0.0"', stdout: '')]
            end
            it { is_expected.to eq(next_release_date) }
          end

          context 'when the tag v1.0.0 exists' do
            context 'when the git show command fails' do
              let(:mocked_commands) do
                [
                  MockedCommand.new("git show --format=format:%aI --quiet \"#{next_release_tag}\"", exitstatus: 1)
                ]
              end
              it 'should raise an RuntimeError' do
                expect { subject }.to raise_error(RuntimeError)
              end
            end

            context 'when the git show command succeeds' do
              let(:mocked_commands) do
                [
                  MockedCommand.new('git tag --list "v1.0.0"', stdout: "v1.0.0\n"),
                  MockedCommand.new(
                    "git show --format=format:%aI --quiet \"#{next_release_tag}\"",
                    stdout: "#{next_release_date}T13:16:37-07:00\n"
                  )
                ]
              end
              it { is_expected.to eq(next_release_date) }
            end
          end
        end
      end
    end
  end

  describe '#next_release_version' do
    subject { project.next_release_version }

    context 'when next_release_version is explicitly set with next_release_version=' do
      before { project.next_release_version = '1.2.3' }
      it { is_expected.to eq('1.2.3') }
    end

    context 'when next_release_version is set in options' do
      before { options.next_release_version = '1.2.3' }
      it { is_expected.to eq('1.2.3') }
    end

    context 'when not otherwise specified' do
      context 'when the bump command succeeds' do
        let(:mocked_commands) { [MockedCommand.new('bump show-next major', stdout: "1.0.0\n")] }
        it { is_expected.to eq('1.0.0') }
      end

      context 'when the bump command succeeds with extra output' do
        let(:mocked_commands) do
          [
            MockedCommand.new('bump show-next major', stdout: "Resolving dependencies...\n1.0.0\n")
          ]
        end
        it { is_expected.to eq('1.0.0') }
      end

      context 'when the bump command fails' do
        let(:mocked_commands) { [MockedCommand.new('bump show-next major', exitstatus: 1)] }
        it 'should raise a RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end
  end

  describe '#last_release_tag' do
    subject { project.last_release_tag }

    context 'when last_release_tag is explicitly set with next_release_tag=' do
      before { project.last_release_tag = 'v0.1.0' }
      it { is_expected.to eq('v0.1.0') }
    end

    context 'when last_release_tag is not explicitly set' do
      context 'when the last_release_version is 0.0.1' do
        before { project.last_release_version = '0.0.1' }
        it { is_expected.to eq('v0.0.1') }
      end
    end
  end

  describe '#last_release_version' do
    subject { project.last_release_version }
    context 'when last_release_version is explicitly set with last_release_version=' do
      before { project.last_release_version = '1.2.3' }
      it { is_expected.to eq('1.2.3') }
    end

    context 'when last_release_version is set in options' do
      before { options.last_release_version = '1.2.3' }
      it { is_expected.to eq('1.2.3') }
    end

    context 'when not otherwise specified' do
      context 'when the bump command succeeds' do
        let(:mocked_commands) { [MockedCommand.new('bump current', stdout: "0.0.1\n")] }
        it { is_expected.to eq('0.0.1') }
      end

      context 'when the bump command succeeds with extra output' do
        let(:mocked_commands) do
          [
            MockedCommand.new('bump current', stdout: "Resolving dependencies...\n0.0.1\n")
          ]
        end
        it { is_expected.to eq('0.0.1') }
      end

      context 'when the bump command fails' do
        let(:mocked_commands) { [MockedCommand.new('bump current', exitstatus: '1')] }
        it 'should raise a RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end
  end

  describe '#release_branch' do
    subject { project.release_branch }

    context 'when release_branch is explicitly set with release_branch=' do
      before { project.release_branch = 'release-v1.1.1' }
      it { is_expected.to eq('release-v1.1.1') }
    end

    context 'when release_branch is set in options' do
      before { options.release_branch = 'release-v1.1.1' }
      it { is_expected.to eq('release-v1.1.1') }
    end

    context 'when release_branch is not explicitly set' do
      context 'when the next_release_tag is v1.0.0' do
        before { project.next_release_tag = 'v1.0.0' }
        it { is_expected.to eq('release-v1.0.0') }
      end
    end
  end

  describe '#release_log_url' do
    subject { project.release_log_url }

    context 'when release_log_url is explicitly set with release_log_url=' do
      let(:release_log_url) { 'https://github.com/user/repo/compare/v0.1.0..v0.2.0' }
      before { project.release_log_url = release_log_url }
      it { is_expected.to eq(release_log_url) }
    end

    context 'when release_log_url is not explicitly set' do
      context "when remote_url is 'https://github.com/org/repo'" do
        before { project.remote_url = 'https://github.com/org/repo' }
        context "last_release_tag is 'v0.1.0', and next_release_tag is 'v1.0.0'" do
          before do
            project.last_release_tag = 'v0.1.0'
            project.next_release_tag = 'v1.0.0'
          end
          it { is_expected.to eq(URI.parse('https://github.com/org/repo/compare/v0.1.0..v1.0.0')) }
        end
      end
    end
  end

  describe '#release_type' do
    subject { project.release_type }

    context 'when the release_type is not explicitly set' do
      it 'should return options.release_type' do
        expect(subject).to eq('major')
      end
    end

    context 'when the release_type is not explicitly set' do
      before { project.release_type = 'minor' }
      it 'should return the set release type' do
        expect(subject).to eq('minor')
      end
    end
  end

  describe '#release_url' do
    subject { project.release_url }

    context 'when release_url is explicitly set with release_url=' do
      let(:release_url) { 'https://github.com/user/repo/releases/tag/v1.0.0' }
      before { project.release_url = release_url }
      it { is_expected.to eq(release_url) }
    end

    context 'when release_url is not explicitly set' do
      context "when remote_url is 'https://github.com/user/repo'" do
        before { project.remote_url = 'https://github.com/user/repo' }
        context "when next_release_tag is 'v1.0.0'" do
          before { project.next_release_tag = 'v1.0.0' }
          it { is_expected.to eq(URI.parse('https://github.com/user/repo/releases/tag/v1.0.0')) }
        end
      end
    end
  end

  describe '#remote' do
    subject { project.remote }

    context 'when options.remote not nil' do
      before { options.remote = 'upstream' }
      it 'should return options.remote' do
        expect(subject).to eq('upstream')
      end
    end

    context 'when the remote is not explicitly set' do
      it "should return the default remote 'origin'" do
        expect(subject).to eq('origin')
      end
    end

    context 'when the remote is explicitly set' do
      before { project.remote = 'upstream' }
      it 'should return the set remote' do
        expect(subject).to eq('upstream')
      end
    end
  end

  describe '#remote_base_url' do
    subject { project.remote_base_url }

    context 'when remote_base_url is explicitly set with remote_base_url=' do
      let(:remote_base_url) { URI.parse('https://github.com/') }
      before { project.remote_base_url = remote_base_url }
      it { is_expected.to eq(remote_base_url) }
    end

    context 'when remote_base_url is not explicitly set' do
      context "when remote_url is 'https://github.com/org/repo'" do
        before { project.remote_url = URI.parse('https://github.com/org/repo') }
        it { is_expected.to eq(URI.parse('https://github.com/')) }
      end
    end
  end

  describe '#remote_repository' do
    subject { project.remote_repository }

    context 'when remote_repository is explicitly set with remote_repository=' do
      let(:remote_repository) { 'org/repo' }
      before { project.remote_repository = remote_repository }
      it { is_expected.to eq(remote_repository) }
    end

    context 'when remote_repository is not explicitly set' do
      context "when remote_url is 'https://github.com/org/repo'" do
        before { project.remote_url = URI.parse('https://github.com/org/repo') }
        it { is_expected.to eq('org/repo') }
      end
    end
  end

  describe '#remote_url' do
    subject { project.remote_url }

    context 'when the remote_url is explicity set with #remote_url=' do
      let(:remote_url) { URI.parse('https://github.com/org2/repo2') }
      before { project.remote_url = remote_url }
      it { is_expected.to eq(remote_url) }
    end

    context 'when the remote_url is not explicitly set' do
      let(:remote_url) { URI.parse('https://github.com/org2/repo2') }

      context 'when the git command fails' do
        let(:mocked_commands) { [MockedCommand.new("git remote get-url 'origin'", exitstatus: 1)] }
        it 'should raise a RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end

      context 'when the git command succeeds' do
        let(:mocked_commands) { [MockedCommand.new("git remote get-url 'origin'", stdout: "#{remote_url}.git\n")] }
        it { is_expected.to eq(remote_url) }
      end
    end
  end

  describe '#changelog_path' do
    subject { project.changelog_path }

    context 'when options.changelog_path not nil' do
      before { options.changelog_path = 'docs/CHANGES.txt' }
      it 'should return options.changelog_path' do
        expect(subject).to eq('docs/CHANGES.txt')
      end
    end

    context 'when the changelog_path is not explicitly set' do
      it "should return the default 'CHANGELOG.md'" do
        expect(subject).to eq('CHANGELOG.md')
      end
    end

    context 'when the changelog_path is explicitly set' do
      before { project.changelog_path = 'docs/CHANGES.txt' }
      it 'should return the set changelog_path' do
        expect(subject).to eq('docs/CHANGES.txt')
      end
    end
  end

  describe '#changes' do
    subject { project.changes }

    context 'when changes is not explicitly set' do
      before do
        project.last_release_tag = 'v0.1.0'
      end

      context 'when the git log command succeeds' do
        let(:git_log_command) { "git log 'HEAD' '^v0.1.0' --oneline --format='format:%h\t%s'" }
        let(:git_log_output) { <<~LOG_OUTPUT }
          14b04ec\tFeature 1 (#25)
          025fa29\tFeature 2 (#24)
        LOG_OUTPUT
        let(:mocked_commands) { [MockedCommand.new(git_log_command, stdout: git_log_output)] }

        let(:expected_changes) do
          [
            CreateGithubRelease::Change.new('14b04ec', 'Feature 1 (#25)'),
            CreateGithubRelease::Change.new('025fa29', 'Feature 2 (#24)')
          ]
        end

        it { is_expected.to eq(expected_changes) }
      end

      context 'when the git log command fails' do
        let(:git_log_command) { "git log 'HEAD' '^v0.1.0' --oneline --format='format:%h\t%s'" }
        let(:mocked_commands) { [MockedCommand.new(git_log_command, exitstatus: 1)] }

        it 'should raise a RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end

    context 'when changees is explicitly set' do
      let(:changes) do
        [
          CreateGithubRelease::Change.new('38d20b1', 'Add new feature 2'),
          CreateGithubRelease::Change.new('38d20b1', 'Add new feature 1')
        ]
      end
      before { project.changes = changes }
      it { is_expected.to eq(changes) }
    end
  end

  context '#next_release_description' do
    subject { project.next_release_description }

    context 'when next_release_description is not explicitly set' do
      before do
        project.remote_url = URI.parse('https://github.com/username/repo')
        project.last_release_tag = 'v0.1.0'
        project.next_release_tag = 'v1.0.0'
        project.next_release_date = Date.new(2022, 11, 7)
        project.changes = [
          CreateGithubRelease::Change.new('e718690', 'Release v1.0.0 (#3)'),
          CreateGithubRelease::Change.new('ab598f3', 'Fix Rubocop offenses (#2)')
        ]
      end

      let(:expected_next_release_description) do
        <<~NEXT_RELEASE_DESCRIPTION
          ## v1.0.0 (2022-11-07)

          [Full Changelog](https://github.com/username/repo/compare/v0.1.0..v1.0.0)

          Changes since v0.1.0:

          * e718690 Release v1.0.0 (#3)
          * ab598f3 Fix Rubocop offenses (#2)
        NEXT_RELEASE_DESCRIPTION
      end

      it { is_expected.to eq(expected_next_release_description) }
    end

    context 'when there are no changes' do
      before do
        project.remote_url = URI.parse('https://github.com/username/repo')
        project.last_release_tag = 'v0.1.0'
        project.next_release_tag = 'v1.0.0'
        project.next_release_date = Date.new(2022, 11, 7)
        project.changes = []
      end

      let(:expected_next_release_description) do
        <<~NEXT_RELEASE_DESCRIPTION
          ## v1.0.0 (2022-11-07)

          [Full Changelog](https://github.com/username/repo/compare/v0.1.0..v1.0.0)

          Changes since v0.1.0:

          * No changes
        NEXT_RELEASE_DESCRIPTION
      end

      it { is_expected.to eq(expected_next_release_description) }
    end

    context 'when next_release_description is explicitly set' do
      let(:next_release_description) { 'This is a release description' }
      before { project.next_release_description = next_release_description }
      it { is_expected.to eq(next_release_description) }
    end
  end

  describe '#last_release_changelog' do
    subject { project.last_release_changelog }

    let(:changelog_path) { 'CHANGES.txt' }
    let(:last_release_changelog) { <<~CHANGELOG }
      # Project Changelog

      ## v0.1.0 (2021-11-07)

      * e718690 Release v0.1.0 (#3)
    CHANGELOG

    context 'when last_release_changelog is not explicitly set' do
      before do
        allow(File).to receive(:read).and_call_original
        allow(File).to receive(:read).with(changelog_path).and_return(last_release_changelog)
        project.changelog_path = changelog_path
      end

      it { is_expected.to eq(last_release_changelog) }
    end

    context 'when the changelog file does not exist' do
      before do
        allow(File).to receive(:read).and_call_original
        allow(File).to receive(:read).with(changelog_path).and_raise(Errno::ENOENT, 'No such file or directory')
        project.changelog_path = changelog_path
      end

      it { is_expected.to eq('') }
    end

    context 'when the changelog file could not be read' do
      before do
        allow(File).to receive(:read).and_call_original
        allow(File).to receive(:read).with(changelog_path).and_raise(Errno::EACCES, 'Permission denied')
        project.changelog_path = changelog_path
      end

      it 'should raise a RuntimeError' do
        expect { subject }.to raise_error(RuntimeError, 'Could not read the changelog file')
      end
    end

    context 'when last_release_changelog is explicitly set' do
      let(:last_release_changelog) { <<~CHANGELOG }
        # Project Changelog

        ## v0.1.0 (2021-11-07)

        * e718690 Release v0.1.0 (#3)
      CHANGELOG
      before { project.last_release_changelog = last_release_changelog }
      it { is_expected.to eq(last_release_changelog) }
    end
  end

  describe '#next_release_changelog' do
    subject { project.next_release_changelog }

    let(:changelog_path) { 'CHANGES.txt' }

    let(:last_release_changelog) { <<~CHANGELOG }
      # Project Changelog

      ## v0.1.0 (2021-11-07)

      * e718690 Release v0.1.0 (#3)
    CHANGELOG

    let(:next_release_description) do
      <<~NEXT_RELEASE_DESCRIPTION
        ## v1.0.0 (2022-11-07)

        [Full Changelog](https://github.com/username/repo/compare/v0.1.0..v1.0.0)

        * e718690 Release v1.0.0 (#3)
        * ab598f3 Fix Rubocop offenses (#2)
      NEXT_RELEASE_DESCRIPTION
    end

    let(:expected_next_release_changelog) { <<~CHANGELOG }
      # Project Changelog

      ## v1.0.0 (2022-11-07)

      [Full Changelog](https://github.com/username/repo/compare/v0.1.0..v1.0.0)

      * e718690 Release v1.0.0 (#3)
      * ab598f3 Fix Rubocop offenses (#2)

      ## v0.1.0 (2021-11-07)

      * e718690 Release v0.1.0 (#3)
    CHANGELOG

    context 'when next_release_changelog is not explicitly set' do
      before do
        project.last_release_changelog = last_release_changelog
        project.next_release_description = next_release_description
      end

      it { is_expected.to eq(expected_next_release_changelog) }
    end

    context 'when next_release_changelog is explicitly set' do
      before do
        project.next_release_changelog = expected_next_release_changelog
      end

      it { is_expected.to eq(expected_next_release_changelog) }
    end
  end

  describe '#verbose?' do
    subject { project.verbose? }

    context 'when options.verbose is true' do
      before { options.verbose = true }
      it { is_expected.to eq(true) }
    end

    context 'when options.verbose is false' do
      before { options.verbose = false }
      it { is_expected.to eq(false) }
    end

    context 'when explicitly set to true with #verbose=' do
      before { project.verbose = true }
      it { is_expected.to eq(true) }
    end
  end

  describe '#quiet?' do
    subject { project.quiet? }

    context 'when options.quiet is true' do
      before { options.quiet = true }
      it { is_expected.to eq(true) }
    end

    context 'when options.quiet is false' do
      before { options.quiet = false }
      it { is_expected.to eq(false) }
    end

    context 'when explicitly set to true with #quiet=' do
      before { project.quiet = true }
      it { is_expected.to eq(true) }
    end
  end

  describe '#backtick_debug?' do
    subject { project.send('backtick_debug?') }
    context 'when #verbose? is true' do
      before { project.verbose = true }
      it { is_expected.to eq(true) }
    end
    context 'when #verbose? is false' do
      before { project.verbose = false }
      it { is_expected.to eq(false) }
    end
  end

  describe '#to_s' do
    subject { project.to_s }

    let(:mocked_commands) do
      [
        MockedCommand.new("git remote show 'origin'", stdout: "  HEAD branch: main\n"),
        MockedCommand.new('bump show-next major', stdout: "1.0.0\n"),
        MockedCommand.new('git show --format=format:%aI --quiet "v1.0.0"', stdout: "2023-02-01 00:00:00 -0800\n"),
        MockedCommand.new('bump current', stdout: "0.1.0\n"),
        MockedCommand.new("git remote get-url 'origin'", stdout: "https://github.com/org/repo.git\n"),
        MockedCommand.new('git tag --list "v1.0.0"', stdout: "v1.0.0\n")
      ]
    end

    let(:expected_result) { <<~EXPECTED_RESULT }
      default_branch: main
      next_release_tag: v1.0.0
      next_release_date: 2023-02-01
      next_release_version: 1.0.0
      last_release_tag: v0.1.0
      last_release_version: 0.1.0
      release_branch: release-v1.0.0
      release_log_url: https://github.com/org/repo/compare/v0.1.0..v1.0.0
      release_type: major
      release_url: https://github.com/org/repo/releases/tag/v1.0.0
      remote: origin
      remote_base_url: https://github.com/
      remote_repository: org/repo
      remote_url: https://github.com/org/repo
      verbose?: false
      quiet?: false
    EXPECTED_RESULT

    it { is_expected.to eq(expected_result) }
  end
end
