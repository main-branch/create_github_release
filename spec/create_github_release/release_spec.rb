# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Release do
  let(:release) { described_class.new(previous_tag, tag, created_on, changes, release_log_url) }

  let(:previous_tag) { 'v0.1.0' }
  let(:tag) { 'v0.1.1' }
  let(:created_on) { Date.parse('2019-01-01') }
  let(:changes) do
    [
      CreateGithubRelease::Change.new('f5e69d6', 'Release v1.0.0 (#10)'),
      CreateGithubRelease::Change.new('ab598f3', 'Some change (#9)')
    ]
  end
  let(:release_log_url) { 'https://github.com/username/repo/compare/v0.1.0..v0.1.1' }

  describe '#initialize' do
    subject { release }

    it do
      is_expected.to(
        have_attributes(
          previous_tag: previous_tag,
          tag: tag,
          created_on: created_on,
          changes: changes,
          release_log_url: release_log_url
        )
      )
    end
  end

  describe '#to_s' do
    subject { release.to_s }

    it { is_expected.to eq(<<~STRING) }
      ## v0.1.1 (2019-01-01)

      [Full Changelog](https://github.com/username/repo/compare/v0.1.0..v0.1.1)

      * f5e69d6 Release v1.0.0 (#10)
      * ab598f3 Some change (#9)
    STRING
  end
end
