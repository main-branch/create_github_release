# frozen_string_literal: true

require 'tmpdir'

RSpec.describe CreateGithubRelease::Options do
  let(:current_version) { '0.1.0' }
  let(:release_type) { 'major' }

  let(:options) { described_class.new.tap { |o| o.release_type = release_type } }

  subject { options }
  context 'Given current version is 0.1.0, release type is major, default branch is main, ' \
          'and repo url is https://github.com/org/repo.git' do
    let(:command_responses) do
      {
        "git remote show 'origin'" => "HEAD branch: main\n",
        "git remote get-url 'origin'" => "https://github.com/org/repo.git\n",
        "git remote get-url 'upstream'" => "https://github.com/org/upstream_repo.git\n"
      }
    end

    before do
      allow(options).to receive(:`).with(String) do |command|
        raise "Command '#{command}' was not stubbed" unless command_responses.key?(command)

        command_responses[command]
      end
    end

    before do
      allow(Bump::Bump).to receive(:current).and_return(current_version)
    end

    describe '#initialize' do
      context 'without a block' do
        it { is_expected.to be_a(described_class) }
      end

      context 'with a block' do
        subject { described_class.new { |o| o.release_type = 'patch' } }
        it { is_expected.to be_a(described_class) }
        it 'should have called the block' do
          expect(subject.release_type).to eq('patch')
        end
      end

      context 'default values' do
        it { is_expected.to(have_attributes(branch: 'release-v1.0.0')) }
        it { is_expected.to(have_attributes(current_tag: 'v0.1.0')) }
        it { is_expected.to(have_attributes(current_version: '0.1.0')) }
        it { is_expected.to(have_attributes(default_branch: 'main')) }
        it { is_expected.to(have_attributes(next_tag: 'v1.0.0')) }
        it { is_expected.to(have_attributes(next_version: '1.0.0')) }
        it { is_expected.to(have_attributes(quiet: false)) }
        it { is_expected.to(have_attributes(release_type: release_type)) }
        it { is_expected.to(have_attributes(remote: 'origin')) }
        it { is_expected.to(have_attributes(remote_url: URI.parse('https://github.com/org/repo.git'))) }
        it { is_expected.to(have_attributes(remote_base_url: 'https://github.com/')) }
        it { is_expected.to(have_attributes(remote_repository: 'org/repo')) }
        it { is_expected.to(have_attributes(release_url: 'https://github.com/org/repo/releases/tag/v1.0.0')) }
        it { is_expected.to(have_attributes(tag: 'v1.0.0')) }
      end
    end

    describe '#branch' do
      it { is_expected.to(have_attributes(branch: 'release-v1.0.0')) }

      context "when branch is set to 'release-v2.0.0'" do
        before { options.branch = 'release-v2.0.0' }
        it { is_expected.to have_attributes(branch: 'release-v2.0.0') }
      end

      context "when branch is 'release-v1.0.0' and then tag is changed to 'v1.1.1'" do
        before do
          options.branch = 'release-v1.0.0'
          options.tag = 'v1.1.1'
        end
        it { is_expected.to have_attributes(branch: 'release-v1.1.1') }
      end
    end

    describe '#current_tag' do
      it { is_expected.to(have_attributes(current_tag: 'v0.1.0')) }

      context "when current_tag is set to 'v1.0.0'" do
        before { options.current_tag = 'v1.0.0' }
        it { is_expected.to have_attributes(current_tag: 'v1.0.0') }
      end

      context "when current_tag is 'v0.1.0' and then current_version is changed to '1.0.0'" do
        before do
          options.current_tag = 'v0.1.0'
          options.current_version = '1.0.0'
        end
        it { is_expected.to have_attributes(current_tag: 'v1.0.0') }
      end
    end

    describe '#current_version' do
      it { is_expected.to(have_attributes(current_version: '0.1.0')) }

      context "when current_version is set to '2.0.0'" do
        before { options.current_version = '2.0.0' }
        it { is_expected.to have_attributes(current_version: '2.0.0') }
      end
    end

    describe '#default_branch' do
      it { is_expected.to(have_attributes(default_branch: 'main')) }

      context "when default_branch is set to 'master'" do
        before { options.default_branch = 'master' }
        it { is_expected.to have_attributes(default_branch: 'master') }
      end
    end

    describe '#next_tag' do
      it { is_expected.to(have_attributes(next_tag: 'v1.0.0')) }

      context "when next_tag is set to 'v3.0.0'" do
        before { options.next_tag = 'v3.0.0' }
        it { is_expected.to have_attributes(next_tag: 'v3.0.0') }
      end

      context "when next_tag is 'v2.0.0' and then release_type is changed to 'minor'" do
        before do
          options.next_tag = 'v2.0.0'
          options.release_type = 'minor'
        end
        it { is_expected.to have_attributes(next_tag: 'v0.2.0') }
      end

      context "when next_tag is 'v2.0.0' and then next_version is changed to '3.0.0'" do
        before do
          options.next_tag = 'v2.0.0'
          options.next_version = '3.0.0'
        end
        it { is_expected.to have_attributes(next_tag: 'v3.0.0') }
      end

      context "when next_tag is 'v2.0.0' and then current_version is changed to '10.0.0'" do
        before do
          options.next_tag = 'v2.0.0'
          options.current_version = '10.0.0'
        end
        it { is_expected.to have_attributes(next_tag: 'v11.0.0') }
      end
    end

    describe '#next_version' do
      it { is_expected.to(have_attributes(next_version: '1.0.0')) }

      context "when next_version is set to '3.0.0'" do
        before { options.next_version = '3.0.0' }
        it { is_expected.to have_attributes(next_version: '3.0.0') }
      end

      context "when next_version is '4.0.0' and then release_type is changed to 'patch'" do
        before do
          options.next_version = '4.0.0'
          options.release_type = 'patch'
        end
        it { is_expected.to have_attributes(next_version: '0.1.1') }
      end

      context "when next_version is '4.0.0' and then current_version is changed to '10.0.0'" do
        before do
          options.next_version = '4.0.0'
          options.current_version = '10.0.0'
        end
        it { is_expected.to have_attributes(next_version: '11.0.0') }
      end
    end

    describe '#quiet' do
      it { is_expected.to(have_attributes(quiet: false)) }

      context 'when quiet is set to true' do
        before { options.quiet = true }
        it { is_expected.to have_attributes(quiet: true) }
      end
    end

    describe '#remote' do
      it { is_expected.to(have_attributes(remote: 'origin')) }

      context "when remote is set to 'upstream'" do
        before { options.remote = 'upstream' }
        it { is_expected.to have_attributes(remote: 'upstream') }
      end
    end

    describe '#remote_url' do
      it { is_expected.to(have_attributes(remote_url: URI.parse('https://github.com/org/repo.git'))) }

      context "when remote_url is set to 'https://github.com/org2/repo2.git'" do
        before { options.remote_url = URI.parse('https://github.com/org2/repo2.git') }
        it { is_expected.to(have_attributes(remote_url: URI.parse('https://github.com/org2/repo2.git'))) }
      end

      context "when remote_url is 'blah' and remote is changed to 'upstream'" do
        before do
          options.remote_url = 'blah'
          options.remote = 'upstream'
        end
        it { is_expected.to(have_attributes(remote_url: URI.parse('https://github.com/org/upstream_repo.git'))) }
      end
    end

    describe '#remote_base_url' do
      it { is_expected.to(have_attributes(remote_base_url: 'https://github.com/')) }

      context "when remote_base_url is set to 'https://gitlab.com/'" do
        before { options.remote_base_url = 'https://gitlab.com/' }
        it { is_expected.to(have_attributes(remote_base_url: 'https://gitlab.com/')) }
      end

      context "when remote_base_url is 'blah' and remote_url is changed to 'https://git.mydomain.com/org/repo.git'" do
        before do
          options.remote_base_url = 'blah'
          options.remote_url = URI.parse('https://git.mydomain.com/org/repo.git')
        end
        it { is_expected.to(have_attributes(remote_base_url: 'https://git.mydomain.com/')) }
      end
    end

    describe '#remote_repository' do
      it { is_expected.to(have_attributes(remote_repository: 'org/repo')) }

      context "when remote_repository is set to 'org2/repo2'" do
        before { options.remote_repository = 'org2/repo2' }
        it { is_expected.to(have_attributes(remote_repository: 'org2/repo2')) }
      end

      context "whne remote_repository is 'foo/bar' and remote_url is" \
              "changed to 'https://git.mydomain.com/org/repo.git'" do
        before do
          options.remote_repository = 'foo/bar'
          options.remote_url = URI.parse('https://git.mydomain.com/org/repo.git')
        end
        it { is_expected.to(have_attributes(remote_repository: 'org/repo')) }
      end
    end

    describe '#release_type' do
      it { is_expected.to(have_attributes(release_type: release_type)) }

      context 'when release_type is set to "minor"' do
        let(:release_type) { 'minor' }
        it { is_expected.to(have_attributes(release_type: 'minor')) }
      end

      context 'when release_type is set to an invalid value' do
        it { expect { options.release_type = 'blah' }.to raise_error(ArgumentError, /^Invalid release_type/) }
      end
    end

    describe '#release_url' do
      it { is_expected.to(have_attributes(release_url: 'https://github.com/org/repo/releases/tag/v1.0.0')) }

      context "when release_url is set to 'https://gitlab.com/org/repo/releases/tag/v9.0.0'" do
        before { options.release_url = 'https://gitlab.com/org/repo/releases/tag/v9.0.0' }
        it { is_expected.to(have_attributes(release_url: 'https://gitlab.com/org/repo/releases/tag/v9.0.0')) }
      end

      context "when release_url is 'https://gitlab.com/org/repo/releases/tag/v9.0.0' " \
              "and remote_url is changed to 'https://git.mydomain.com/org/repo.git'" do
        before do
          options.release_url = 'https://gitlab.com/org/repo/releases/tag/v9.0.0'
          options.remote_url = URI.parse('https://git.mydomain.com/org/repo.git')
        end
        it { is_expected.to(have_attributes(release_url: 'https://git.mydomain.com/org/repo/releases/tag/v1.0.0')) }
      end
    end

    describe '#to_s' do
      it 'should return a string containing all the options' do
        expect(options.to_s).to eq(<<~OPTIONS)
          branch='release-v1.0.0'
          current_tag='v0.1.0'
          current_version='0.1.0'
          default_branch='main'
          next_tag='v1.0.0'
          next_version='1.0.0'
          quiet=false
          release_type='major'
          remote='origin'
          remote_url='https://github.com/org/repo.git'
          remote_base_url='https://github.com/'
          remote_repository='org/repo'
          tag='v1.0.0'
        OPTIONS
      end
    end
  end
end
