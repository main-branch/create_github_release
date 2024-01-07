# frozen_string_literal: true

RSpec.describe CreateGithubRelease::AssertionBase do
  let(:assertion) { described_class.new(project) }
  let(:options) { CreateGithubRelease::CommandLine::Options.new { |o| o.release_type = 'major' } }
  let(:project) { CreateGithubRelease::Project.new(options) }

  describe '#assert' do
    subject { assertion.assert }
    it 'calling assert on an instance of AssertionBase should raise a NotImplementedError' do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

  describe '#project' do
    subject { assertion.project }
    it { is_expected.to eq(project) }
  end

  describe '#backtick_debug?' do
    subject { assertion.send('backtick_debug?') }
    context 'when project.verbose? is true' do
      before { project.verbose = true }
      it { is_expected.to eq(true) }
    end
    context 'when project.#verbose? is false' do
      before { project.verbose = false }
      it { is_expected.to eq(false) }
    end
  end
end
