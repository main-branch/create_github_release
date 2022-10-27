# frozen_string_literal: true

require 'tmpdir'

RSpec.describe CreateGithubRelease::CommandLineParser do
  let(:parser) { described_class.new }

  describe '#initialize' do
    subject { parser }
    it { is_expected.to be_a described_class }
  end

  describe '#parse' do
    subject { parser.parse(args) }
    context 'when given patch for release type' do
      let(:args) { ['patch'] }
      it { is_expected.to have_attributes(release_type: 'patch', quiet: false) }
    end

    context 'when a release type is not given' do
      let(:args) { [] }
      it 'should exit' do
        expect { subject }.to raise_error(SystemExit).and output(/^ERROR: No release type specified/).to_stderr
      end
    end

    context 'when too many args are given' do
      let(:args) { %w[major minor] }
      it 'should exit' do
        expect { subject }.to raise_error(SystemExit).and output(/^ERROR: Too many args/).to_stderr
      end
    end

    context 'when the --quiet option is given' do
      let(:args) { ['--quiet', 'patch'] }
      it { is_expected.to have_attributes(release_type: 'patch', quiet: true) }
    end

    context 'when the --help options is given' do
      let(:args) { ['--help'] }
      it 'should exit and display the help message' do
        expect { subject }.to raise_error(SystemExit).and output(/^Usage: /).to_stdout
      end
    end
  end
end
