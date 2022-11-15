# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Release do
  let(:release) { described_class.new(tag, date, description) }

  describe '#initialize' do
    subject { release }
    let(:tag) { 'v0.1.1' }
    let(:date) { Date.parse('2019-01-01') }
    let(:description) { <<~RELEASE_DESCRIPTION }
      * f5e69d6 Release v1.0.0 (#10)
      * 8fe479b Update document for initial GA release (#7)
      * e718690 Release v0.1.1 (#3)
      * a92453c Bug fix (#2)
      * 43739A3 Initial commit
    RELEASE_DESCRIPTION

    it { is_expected.to have_attributes(tag: tag, date: date, description: description) }
  end
end
