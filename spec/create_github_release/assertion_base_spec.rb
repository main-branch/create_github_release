# frozen_string_literal: true

RSpec.describe CreateGithubRelease::AssertionBase do
  let(:assertion) { described_class.new(options) }
  let(:options) { CreateGithubRelease::Options.new { |o| o.release_type = 'major' } }

  describe '#assert' do
    subject { assertion.assert }
    it 'calling assert on an instance of AssertionBase should raise a NotImplementedError' do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

  describe '#options' do
    subject { assertion.options }
    it { is_expected.to eq(options) }
  end
end
