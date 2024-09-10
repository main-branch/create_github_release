# frozen_string_literal: true

require 'tmpdir'
require 'timecop'

RSpec.describe CreateGithubRelease::Project do
  let(:release_type) { 'major' }
  let(:project) { described_class.new(options, &project_init_block) }
  let(:project_init_block) { nil }
  let(:options) { CreateGithubRelease::CommandLine::Options.new { |o| o.release_type = release_type } }

  before do
    allow_any_instance_of(described_class).to receive(:`).with(String) do |_object, command|
      execute_mocked_command(mocked_commands, command)
    end
  end

  let(:mocked_commands) { [] }

  describe '#initialize' do
    subject { project }

    context '#without a block' do
      it 'should successfully create a project' do
        expect(subject).to be_a(described_class)
      end
      it 'should set the options attribute' do
        expect(subject.options).to eq(options)
      end
    end

    context '#with a block' do
      let(:project_init_block) { ->(p) { p.release_type = 'minor' } }

      it 'should call the block with the project as an argument' do
        expect(subject.release_type).to eq('minor')
      end
    end

    context "when release_type is 'first' and 'gem-version-boss current' returns 0.0.1" do
      let(:release_type) { 'first' }

      subject { project }

      let(:mocked_commands) { [MockedCommand.new('gem-version-boss current', stdout: "0.0.1\n")] }

      it do
        is_expected.to(
          have_attributes(
            first_release: true,
            last_release_version: '',
            last_release_tag: '',
            next_release_version: '0.0.1',
            next_release_tag: 'v0.0.1'
          )
        )
      end
    end
  end

  # describe '#first_release?' do
  # end

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
      let(:project_init_block) { ->(p) { p.default_branch = 'production' } }
      it { is_expected.to eq('production') }
    end
  end

  describe '#next_release_tag' do
    subject { project.next_release_tag }

    context 'when next_release_tag is explicitly set with next_release_tag=' do
      let(:project_init_block) { ->(p) { p.next_release_tag = 'v1.2.3' } }
      it { is_expected.to eq('v1.2.3') }
    end

    context 'when next_release_tag is not explicitly set' do
      context 'when the next_release_version is 1.0.0' do
        let(:project_init_block) { ->(p) { p.next_release_version = '1.0.0' } }
        it { is_expected.to eq('v1.0.0') }
      end
    end
  end

  describe '#next_release_date' do
    subject { project.next_release_date }
    let(:next_release_date) { Date.parse('2017-01-01') }

    # before { Timecop.freeze(Date.parse(next_release_date)) }

    context 'when next_release_date is explicitly set with next_release_date=' do
      let(:project_init_block) { ->(p) { p.next_release_date = next_release_date } }
      it { is_expected.to eq(next_release_date) }
    end

    context 'when next_release_date is not explicitly set' do
      context 'when next release tag is v1.0.0' do
        let(:next_release_tag) { 'v1.0.0' }
        let(:project_init_block) { ->(p) { p.next_release_tag = next_release_tag } }
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
      let(:project_init_block) { ->(p) { p.next_release_version = '1.2.3' } }
      it { is_expected.to eq('1.2.3') }
    end

    context 'when next_release_version is set in options' do
      let(:project_init_block) { ->(p) { p.next_release_version = '1.2.3' } }
      it { is_expected.to eq('1.2.3') }
    end

    context 'when not explicitly set and not set in options' do
      context 'when this is the first release' do
        let(:release_type) { 'first' }
        let(:mocked_commands) { [MockedCommand.new('gem-version-boss current', stdout: "1.0.0\n")] }
        it "should determine the version using 'gem-version-boss current'" do
          expect(subject).to eq('1.0.0')
        end
      end

      context 'when release_type is pre' do
        context 'when asking for the next pre-release of the same type' do
          let(:project_init_block) do
            lambda do |p|
              p.release_type = 'pre'
              p.pre = true
            end
          end

          let(:mocked_commands) do
            [
              MockedCommand.new('gem-version-boss next-pre --pre --dry-run', stdout: "1.0.0-alpha.2\n")
            ]
          end

          it { is_expected.to eq('1.0.0-alpha.2') }
        end

        context 'when asking for the next pre-release of a different type' do
          let(:project_init_block) do
            lambda do |p|
              p.release_type = 'pre'
              p.pre = true
              p.pre_type = 'beta'
            end
          end

          let(:mocked_commands) do
            [
              MockedCommand.new('gem-version-boss next-pre --pre --pre-type=beta --dry-run', stdout: "1.0.0-beta.1\n")
            ]
          end

          it { is_expected.to eq('1.0.0-beta.1') }
        end
      end

      context 'when release_type is release' do
        let(:project_init_block) { ->(p) { p.release_type = 'release' } }

        let(:mocked_commands) do
          [
            MockedCommand.new('gem-version-boss next-release --dry-run', stdout: "1.0.0\n")
          ]
        end

        it { is_expected.to eq('1.0.0') }
      end

      context 'when release_type is major' do
        context 'when the gem-version-boss command succeeds' do
          let(:mocked_commands) { [MockedCommand.new('gem-version-boss next-major --dry-run', stdout: "1.0.0\n")] }
          it { is_expected.to eq('1.0.0') }
        end

        context 'when the gem-version-boss command succeeds with extra output' do
          let(:mocked_commands) do
            [
              MockedCommand.new('gem-version-boss next-major --dry-run', stdout: "Resolving dependencies...\n1.0.0\n")
            ]
          end
          it { is_expected.to eq('1.0.0') }
        end

        context 'when the gem-version-boss command fails' do
          let(:mocked_commands) { [MockedCommand.new('gem-version-boss next-major --dry-run', exitstatus: 1)] }
          it 'should raise a RuntimeError' do
            expect { subject }.to raise_error(RuntimeError)
          end
        end

        context 'when asking for a pre-release version' do
          let(:project_init_block) do
            lambda do |p|
              p.pre = true
              p.pre_type = 'alpha'
            end
          end

          let(:mocked_commands) do
            [
              MockedCommand.new('gem-version-boss next-major --pre --pre-type=alpha --dry-run',
                                stdout: "1.0.0-alpha.1\n")
            ]
          end

          it { is_expected.to eq('1.0.0-alpha.1') }
        end
      end
    end
  end

  describe '#last_release_tag' do
    subject { project.last_release_tag }

    context 'when last_release_tag is explicitly set with next_release_tag=' do
      let(:project_init_block) { ->(p) { p.last_release_tag = 'v0.1.0' } }
      it { is_expected.to eq('v0.1.0') }
    end

    context 'when last_release_tag is not explicitly set' do
      context 'when this is the first release' do
        let(:release_type) { 'first' }
        let(:project_init_block) { ->(p) { p.next_release_version = '0.0.1' } }
        it 'should be an empty string' do
          expect(subject).to eq('')
        end
      end

      context 'when the last_release_version is 0.0.1' do
        let(:project_init_block) { ->(p) { p.last_release_version = '0.0.1' } }
        it { is_expected.to eq('v0.0.1') }
      end
    end
  end

  describe '#last_release_version' do
    subject { project.last_release_version }
    context 'when last_release_version is explicitly set with last_release_version=' do
      let(:project_init_block) { ->(p) { p.last_release_version = '1.2.3' } }
      it { is_expected.to eq('1.2.3') }
    end

    context 'when last_release_version is set in options' do
      before { options.last_release_version = '1.2.3' }
      it { is_expected.to eq('1.2.3') }
    end

    context 'when not otherwise specified' do
      context 'when this is the first release' do
        let(:project_init_block) do
          lambda do |p|
            p.release_type = 'first'
            p.next_release_version = '0.0.1'
          end
        end
        it 'should return an empty string' do
          expect(subject).to eq('')
        end
      end

      context 'when this is the first release' do
        let(:release_type) { 'first' }
        let(:mocked_commands) { [MockedCommand.new('gem-version-boss current', stdout: '0.0.1')] }
        it 'should return an empty string' do
          expect(subject).to eq('')
        end
      end

      context 'when the gem-version-boss command succeeds' do
        let(:mocked_commands) { [MockedCommand.new('gem-version-boss current', stdout: "0.0.1\n")] }
        it { is_expected.to eq('0.0.1') }
      end

      context 'when the gem-version-boss command succeeds with extra output' do
        let(:mocked_commands) do
          [
            MockedCommand.new('gem-version-boss current', stdout: "Resolving dependencies...\n0.0.1\n")
          ]
        end
        it { is_expected.to eq('0.0.1') }
      end

      context 'when the gem-version-boss command fails' do
        let(:mocked_commands) { [MockedCommand.new('gem-version-boss current', exitstatus: '1')] }
        it 'should raise a RuntimeError' do
          expect { subject }.to raise_error(RuntimeError)
        end
      end
    end
  end

  describe '#release_branch' do
    subject { project.release_branch }

    context 'when release_branch is explicitly set with release_branch=' do
      let(:project_init_block) { ->(p) { p.release_branch = 'release-v1.1.1' } }
      it { is_expected.to eq('release-v1.1.1') }
    end

    context 'when release_branch is set in options' do
      before { options.release_branch = 'release-v1.1.1' }
      it { is_expected.to eq('release-v1.1.1') }
    end

    context 'when release_branch is not explicitly set' do
      context 'when the next_release_tag is v1.0.0' do
        let(:project_init_block) { ->(p) { p.next_release_tag = 'v1.0.0' } }
        it { is_expected.to eq('release-v1.0.0') }
      end
    end
  end

  describe '#release_log_url' do
    subject { project.release_log_url }

    context 'when release_log_url is explicitly set with release_log_url=' do
      let(:release_log_url) { 'https://github.com/user/repo/compare/v0.1.0..v0.2.0' }
      let(:project_init_block) { ->(p) { p.release_log_url = release_log_url } }
      it { is_expected.to eq(release_log_url) }
    end

    context 'when release_log_url is not explicitly set' do
      context 'when this is the first release' do
        context "when remote_url is 'https://github.com/org/repo', " \
                'last_release_tag is v0.0.1, and next_release_tag is v1.0.0' do
          let(:project_init_block) do
            lambda do |p|
              p.release_type = 'first'
              p.remote_url = 'https://github.com/org/repo'
              p.next_release_version = '0.0.1'
              p.first_commit = '1234567'
            end
          end
          it { is_expected.to eq(URI.parse('https://github.com/org/repo/compare/1234567..v0.0.1')) }
        end
      end

      context 'when this is not the first release' do
        context "when remote_url is 'https://github.com/org/repo', " \
                'last_release_tag is v0.0.1, and next_release_tag is v1.0.0' do
          let(:project_init_block) do
            lambda do |p|
              p.remote_url = 'https://github.com/org/repo'
              p.last_release_tag = 'v0.1.0'
              p.next_release_tag = 'v1.0.0'
            end
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

    context 'when the release_type is explicitly set' do
      let(:project_init_block) { ->(p) { p.release_type = 'minor' } }
      it 'should return the set release type' do
        expect(subject).to eq('minor')
      end
    end
  end

  describe '#release_pr_label' do
    subject { project.release_pr_label }

    context 'when the release_pr_label is not explicitly set' do
      it 'should return options.release_type' do
        expect(subject).to be_nil
      end
    end

    context 'when the release_pr_label is explicitly set' do
      let(:project_init_block) { ->(p) { p.release_pr_label = 'release' } }
      it 'should return the set release pr label' do
        expect(subject).to eq('release')
      end
    end
  end

  describe '#release_url' do
    subject { project.release_url }

    context 'when release_url is explicitly set with release_url=' do
      let(:release_url) { 'https://github.com/user/repo/releases/tag/v1.0.0' }
      let(:project_init_block) { ->(p) { p.release_url = release_url } }
      it { is_expected.to eq(release_url) }
    end

    context 'when release_url is not explicitly set' do
      context "when remote_url is 'https://github.com/user/repo' and next_release_tag is 'v1.0.0'" do
        let(:project_init_block) do
          lambda do |p|
            p.next_release_tag = 'v1.0.0'
            p.remote_url = 'https://github.com/user/repo'
          end
        end
        it { is_expected.to eq(URI.parse('https://github.com/user/repo/releases/tag/v1.0.0')) }
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
      let(:project_init_block) { ->(p) { p.remote = 'upstream' } }
      it 'should return the set remote' do
        expect(subject).to eq('upstream')
      end
    end
  end

  describe '#remote_base_url' do
    subject { project.remote_base_url }

    context 'when remote_base_url is explicitly set with remote_base_url=' do
      let(:remote_base_url) { URI.parse('https://github.com/') }
      let(:project_init_block) { ->(p) { p.remote_base_url = remote_base_url } }
      it { is_expected.to eq(remote_base_url) }
    end

    context 'when remote_base_url is not explicitly set' do
      context "when remote_url is 'https://github.com/org/repo'" do
        let(:project_init_block) { ->(p) { p.remote_url = URI.parse('https://github.com/org/repo') } }
        it { is_expected.to eq(URI.parse('https://github.com/')) }
      end
    end
  end

  describe '#remote_repository' do
    subject { project.remote_repository }

    context 'when remote_repository is explicitly set with remote_repository=' do
      let(:remote_repository) { 'org/repo' }
      let(:project_init_block) { ->(p) { p.remote_repository = remote_repository } }
      it { is_expected.to eq(remote_repository) }
    end

    context 'when remote_repository is not explicitly set' do
      context "when remote_url is 'https://github.com/org/repo'" do
        let(:project_init_block) { ->(p) { p.remote_url = URI.parse('https://github.com/org/repo') } }
        it { is_expected.to eq('org/repo') }
      end
    end
  end

  describe '#remote_url' do
    subject { project.remote_url }

    context 'when the remote_url is explicity set with #remote_url=' do
      let(:remote_url) { URI.parse('https://github.com/org2/repo2') }
      let(:project_init_block) { ->(p) { p.remote_url = remote_url } }
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
      let(:project_init_block) { ->(p) { p.changelog_path = 'docs/CHANGES.txt' } }
      it 'should return the set changelog_path' do
        expect(subject).to eq('docs/CHANGES.txt')
      end
    end
  end

  describe '#changes' do
    subject { project.changes }

    let(:project_init_block) { ->(p) { p.last_release_tag = 'v0.1.0' } }

    context 'when changes is not explicitly set' do
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

      context 'when this is the first release' do
        let(:project_init_block) do
          lambda do |p|
            p.release_type = 'first'
            p.next_release_version = '0.0.1'
          end
        end
        let(:git_log_command) { "git log 'HEAD' --oneline --format='format:%h\t%s'" }
        let(:git_log_output) { <<~LOG_OUTPUT }
          14b04ec\tFeature 1 (#2)
          025fa29\tInitial commit (#1)
        LOG_OUTPUT
        let(:mocked_commands) { [MockedCommand.new(git_log_command, stdout: git_log_output)] }

        let(:expected_changes) do
          [
            CreateGithubRelease::Change.new('14b04ec', 'Feature 1 (#2)'),
            CreateGithubRelease::Change.new('025fa29', 'Initial commit (#1)')
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
      let(:project_init_block) { ->(p) { p.changes = changes } }
      it { is_expected.to eq(changes) }
    end
  end

  context '#next_release_description' do
    subject { project.next_release_description }

    context 'when next_release_description is not explicitly set' do
      let(:project_init_block) do
        lambda do |p|
          p.remote_url = URI.parse('https://github.com/username/repo')
          p.last_release_version = '0.1.0'
          p.next_release_version = '1.0.0'
          p.next_release_date = Date.new(2022, 11, 7)
          p.changes = [
            CreateGithubRelease::Change.new('e718690', 'Release v1.0.0 (#3)'),
            CreateGithubRelease::Change.new('ab598f3', 'Fix Rubocop offenses (#2)')
          ]
        end
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
      let(:project_init_block) do
        lambda do |p|
          p.remote_url = URI.parse('https://github.com/username/repo')
          p.last_release_version = '0.1.0'
          p.next_release_version = '1.0.0'
          p.next_release_date = Date.new(2022, 11, 7)
          p.changes = []
        end
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

    context 'when this is the first release' do
      let(:project_init_block) do
        lambda do |p|
          p.release_type = 'first'
          p.remote_url = URI.parse('https://github.com/username/repo')
          p.next_release_version = '0.0.1'
          p.next_release_date = Date.new(2022, 11, 7)
          p.changes = [
            CreateGithubRelease::Change.new('e718690', 'Release v1.0.0 (#3)'),
            CreateGithubRelease::Change.new('ab598f3', 'Fix Rubocop offenses (#2)')
          ]
          p.first_commit = '1234567'
        end
      end

      let(:expected_next_release_description) { <<~NEXT_RELEASE_DESCRIPTION }
        ## v0.0.1 (2022-11-07)

        [Full Changelog](https://github.com/username/repo/compare/1234567..v0.0.1)

        Changes:

        * e718690 Release v1.0.0 (#3)
        * ab598f3 Fix Rubocop offenses (#2)
      NEXT_RELEASE_DESCRIPTION

      it { is_expected.to eq(expected_next_release_description) }
    end

    context 'when next_release_description is explicitly set' do
      let(:next_release_description) { 'This is a release description' }
      let(:project_init_block) { ->(p) { p.next_release_description = next_release_description } }
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
      let(:project_init_block) { ->(p) { p.changelog_path = changelog_path } }

      before do
        allow(File).to receive(:read).and_call_original
        allow(File).to receive(:read).with(changelog_path).and_return(last_release_changelog)
      end

      it { is_expected.to eq(last_release_changelog) }
    end

    context 'when the changelog file does not exist' do
      let(:project_init_block) { ->(p) { p.changelog_path = changelog_path } }

      before do
        allow(File).to receive(:read).and_call_original
        allow(File).to receive(:read).with(changelog_path).and_raise(Errno::ENOENT, 'No such file or directory')
      end

      it { is_expected.to eq('') }
    end

    context 'when the changelog file could not be read' do
      let(:project_init_block) { ->(p) { p.changelog_path = changelog_path } }

      before do
        allow(File).to receive(:read).and_call_original
        allow(File).to receive(:read).with(changelog_path).and_raise(Errno::EACCES, 'Permission denied')
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
      let(:project_init_block) { ->(p) { p.last_release_changelog = last_release_changelog } }
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
      let(:project_init_block) do
        lambda do |p|
          p.last_release_changelog = last_release_changelog
          p.next_release_description = next_release_description
        end
      end

      it { is_expected.to eq(expected_next_release_changelog) }
    end

    context 'when next_release_changelog is explicitly set' do
      let(:project_init_block) { ->(p) { p.next_release_changelog = expected_next_release_changelog } }

      it { is_expected.to eq(expected_next_release_changelog) }
    end
  end

  describe '#first_commit' do
    subject { project.first_commit }
    let(:project_init_block) { ->(p) { p.next_release_version = 'v1.0.0' } }

    context 'when explicitly set with #first_commit=' do
      let(:project_init_block) { ->(p) { p.first_commit = 'e718690' } }
      it { is_expected.to eq('e718690') }
    end

    context 'when not explicitly set' do
      let(:project_init_block) do
        lambda do |p|
          p.last_release_version = '0.0.1'
          p.next_release_version = '1.0.0'
        end
      end

      let(:mocked_commands) do
        [MockedCommand.new("git log 'HEAD' --oneline --format='format:%h'", stdout: "1234567\ne718690\n")]
      end

      it { is_expected.to eq('e718690') }
    end
  end

  describe 'pre' do
    subject { project.pre }

    context 'when options.pre is true' do
      before { options.pre = true }
      it { is_expected.to eq(true) }
    end

    context 'when options.pre is false' do
      before { options.pre = false }
      it { is_expected.to eq(false) }
    end

    context 'when explicitly set to true with #pre=' do
      let(:project_init_block) { ->(p) { p.pre = true } }
      it { is_expected.to eq(true) }
    end
  end

  describe 'pre_type' do
    subject { project.pre_type }

    context 'when options.pre_type is "alpha"' do
      before { options.pre_type = 'alpha' }
      it { is_expected.to eq('alpha') }
    end

    context 'when options.pre_type is nil' do
      before { options.pre_type = nil }
      it { is_expected.to be_nil }
    end

    context 'when explicitly set to "alpha" with #pre_type=' do
      let(:project_init_block) { ->(p) { p.pre_type = 'alpha' } }
      it { is_expected.to eq('alpha') }
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
      let(:project_init_block) { ->(p) { p.verbose = true } }
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
      let(:project_init_block) { ->(p) { p.quiet = true } }
      it { is_expected.to eq(true) }
    end
  end

  describe '#backtick_debug?' do
    subject { project.send('backtick_debug?') }
    context 'when #verbose? is true' do
      let(:project_init_block) { ->(p) { p.verbose = true } }
      it { is_expected.to eq(true) }
    end
    context 'when #verbose? is false' do
      let(:project_init_block) { ->(p) { p.verbose = false } }
      it { is_expected.to eq(false) }
    end
  end

  describe '#release_pr_number' do
    subject { project.release_pr_number }

    let(:release_pr_number) { '123' }
    let(:remote_url) { 'https://github.com/org/repo' }
    let(:release_pr_url) { "#{remote_url}/pull/#{release_pr_number}" }
    let(:next_release_version) { '1.0.0' }
    let(:next_release_branch) { "release-v#{next_release_version}" }

    context 'when explicitly set' do
      let(:project_init_block) { ->(p) { p.release_pr_number = release_pr_number } }
      it { is_expected.to eq(release_pr_number) }
    end

    context 'when there is no release PR' do
      let(:project_init_block) { ->(p) { p.next_release_version = next_release_version } }

      let(:mocked_commands) do
        [
          MockedCommand.new(
            %(gh pr list --search "head:#{next_release_branch}" --json number --jq ".[].number"),
            stdout: "\n"
          )
        ]
      end

      it 'should return nil' do
        expect(subject).to be_nil
      end
    end

    context 'when the release PR is 123' do
      let(:project_init_block) { ->(p) { p.next_release_version = '1.0.0' } }

      let(:mocked_commands) do
        [
          MockedCommand.new(
            'gh pr list --search "head:release-v1.0.0" --json number --jq ".[].number"',
            stdout: "#{release_pr_number}\n"
          )
        ]
      end

      it 'should return "123"' do
        expect(subject).to eq(release_pr_number)
      end
    end
  end

  describe '#release_pr_url' do
    subject { project.release_pr_url }

    let(:release_pr_number) { '123' }
    let(:remote_url) { 'https://github.com/org/repo' }
    let(:release_pr_url) { URI.parse("#{remote_url}/pull/#{release_pr_number}") }
    let(:next_release_version) { '1.0.0' }
    let(:next_release_branch) { "release-v#{next_release_version}" }

    context 'when explicitly set' do
      let(:project_init_block) { ->(p) { p.release_pr_url = release_pr_url } }
      it { is_expected.to eq(release_pr_url) }
    end

    context 'when there is not release PR' do
      let(:project_init_block) do
        lambda do |p|
          p.remote_url = remote_url
          p.next_release_version = next_release_version
        end
      end

      let(:mocked_commands) do
        [
          MockedCommand.new(
            %(gh pr list --search "head:#{next_release_branch}" --json number --jq ".[].number"),
            stdout: "\n"
          )
        ]
      end

      it { is_expected.to be_nil }
    end

    context 'when the release PR is 123' do
      let(:project_init_block) do
        lambda do |p|
          p.remote_url = remote_url
          p.next_release_version = next_release_version
        end
      end

      let(:mocked_commands) do
        [
          MockedCommand.new(
            %(gh pr list --search "head:#{next_release_branch}" --json number --jq ".[].number"),
            stdout: "#{release_pr_number}\n"
          )
        ]
      end

      it { is_expected.to eq(release_pr_url) }
    end
  end

  describe '#to_s' do
    subject { project.to_s }

    let(:mocked_commands) do
      [
        MockedCommand.new("git remote show 'origin'", stdout: "  HEAD branch: main\n"),
        MockedCommand.new('gem-version-boss next-major --dry-run', stdout: "1.0.0\n"),
        MockedCommand.new('git show --format=format:%aI --quiet "v1.0.0"', stdout: "2023-02-01 00:00:00 -0800\n"),
        MockedCommand.new('gem-version-boss current', stdout: "0.1.0\n"),
        MockedCommand.new("git remote get-url 'origin'", stdout: "https://github.com/org/repo.git\n"),
        MockedCommand.new('git tag --list "v1.0.0"', stdout: "v1.0.0\n"),
        MockedCommand.new('gh pr list --search "head:release-v1.0.0" --json number --jq ".[].number"', stdout: "123\n")
      ]
    end

    let(:expected_result) { <<~EXPECTED_RESULT }
      first_release: false
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
      release_pr_number: 123
      release_pr_url: https://github.com/org/repo/pull/123
      changelog_path: CHANGELOG.md
      verbose?: false
      quiet?: false
    EXPECTED_RESULT

    it { is_expected.to eq(expected_result) }
  end
end
