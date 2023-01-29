# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Change do
  let(:change) { described_class.new(sha, subject_string) }
  let(:sha) { 'f5e69d6' }
  let(:subject_string) { 'Release v1.0.0' }

  describe '#initialize' do
    subject { change }

    it { is_expected.to(have_attributes(sha: sha, subject: subject_string)) }
  end
end
