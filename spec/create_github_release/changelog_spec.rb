# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Changelog do
  let(:changelog) { described_class.new(existing_changelog, next_release_description) }

  let(:next_release_description) { <<~RELEASE_DESCRIPTION }
    ## v1.0.0 (2022-11-08)

    [Full Changelog](https://github.com/ruby-git/ruby-git/compare/v0.1.0..v1.0.0)

    * f5e69d6 Release v1.0.0 (#12)
    * 8fe479b Update documentation for initial GA release (#9)
    * 453c8bd Correctly handle file not existing (#5)
  RELEASE_DESCRIPTION

  describe '#initialize' do
    subject { changelog }

    let(:existing_changelog) { 'Changelog' }

    it do
      is_expected.to(
        have_attributes(
          existing_changelog: existing_changelog,
          next_release_description: next_release_description
        )
      )
    end
  end

  describe '#front_matter' do
    subject { changelog.front_matter }

    context 'when the changelog has both front matter and a body' do
      let(:existing_changelog) { <<~CHANGELOG }
        # Changelog

        ## v0.1.0 (2022-10-31)
        ...
      CHANGELOG

      let(:expected_front_matter) { <<~FRONT_MATTER.chomp }
        # Changelog
      FRONT_MATTER

      it 'should have the expected front matter' do
        expect(subject).to eq(expected_front_matter)
      end
    end

    context 'when the changelog has only a body' do
      let(:existing_changelog) { <<~CHANGELOG }
        ## v0.1.0
        ...
      CHANGELOG

      it 'should return an empty string' do
        expect(subject).to eq('')
      end
    end

    context 'when front matter starts with or ends with blank lines' do
      let(:existing_changelog) { <<~CHANGELOG }

        # Changelog

        All notable changes to this project will be documented in this file.



        ## v0.1.0
        ...
      CHANGELOG

      let(:expected_front_matter) { <<~FRONT_MATTER.chomp }
        # Changelog

        All notable changes to this project will be documented in this file.
      FRONT_MATTER

      it 'should remove those blank lines' do
        expect(subject).to eq(expected_front_matter)
      end
    end

    context 'with a blank changelog' do
      let(:existing_changelog) { '' }
      it 'should return an empty string' do
        expect(subject).to eq('')
      end
    end

    context 'with a changelog that does not have front matter'
  end

  describe '#body' do
    subject { changelog.body }

    context 'when the changlog has both front matter and a body' do
      let(:existing_changelog) { <<~CHANGELOG }
        # Changelog

        ## v0.1.0 (2022-10-31)
        ...
      CHANGELOG

      let(:expected_body) { <<~BODY.chomp }
        ## v0.1.0 (2022-10-31)
        ...
      BODY

      it 'should have the expected body' do
        expect(subject).to eq(expected_body)
      end
    end

    context 'when the changelog has only a body' do
      let(:existing_changelog) { <<~CHANGELOG }
        ## v0.1.0 (2022-10-31)
        ...
      CHANGELOG

      let(:expected_body) { <<~BODY.chomp }
        ## v0.1.0 (2022-10-31)
        ...
      BODY

      it 'should have the expected body' do
        expect(subject).to eq(expected_body)
      end
    end

    context 'when the changelog has only front matter' do
      let(:existing_changelog) { <<~CHANGELOG }
        # Changelog
        ...
      CHANGELOG

      it 'should return an empty string' do
        expect(subject).to eq('')
      end
    end

    context 'when the body starts with or ends with blank lines' do
      let(:existing_changelog) { <<~CHANGELOG }
        # Changelog
        ...

        ## v0.1.0 (2022-10-31)
        ...


      CHANGELOG

      let(:expected_body) { <<~BODY.chomp }
        ## v0.1.0 (2022-10-31)
        ...
      BODY

      it 'should remove those blank lines' do
        expect(subject).to eq(expected_body)
      end
    end

    context 'with a blank changelog' do
      let(:existing_changelog) { '' }

      it 'should return an empty string' do
        expect(subject).to eq('')
      end
    end
  end

  describe '#to_s' do
    let(:existing_changelog) { <<~CHANGELOG }
      # Changelog

      All notable changes to this project will be documented in this file.

      The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
      and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

      ## v0.1.1 (2022-10-31)

      * e718690 Release v0.1.1 (#3)
      * a92453c Bug fix (#2)

      ## v0.1.0 (2022-10-07)

      * 07a1167 Release v0.1.0 (#1)
      * 43739A3 Initial commit
    CHANGELOG

    let(:expected_to_s) { <<~CHANGELOG }
      # Changelog

      All notable changes to this project will be documented in this file.

      The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
      and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

      ## v1.0.0 (2022-11-08)

      [Full Changelog](https://github.com/ruby-git/ruby-git/compare/v0.1.0..v1.0.0)

      * f5e69d6 Release v1.0.0 (#12)
      * 8fe479b Update documentation for initial GA release (#9)
      * 453c8bd Correctly handle file not existing (#5)

      ## v0.1.1 (2022-10-31)

      * e718690 Release v0.1.1 (#3)
      * a92453c Bug fix (#2)

      ## v0.1.0 (2022-10-07)

      * 07a1167 Release v0.1.0 (#1)
      * 43739A3 Initial commit
    CHANGELOG

    subject { changelog.to_s }

    it 'should update the changelog with the new release' do
      expect(subject).to eq(expected_to_s)
    end
  end
end
