# frozen_string_literal: true

require 'English'

module CreateGithubRelease
  # The release information needed to generate a changelog
  #
  # @api public
  #
  class Release
    # Create a new release object
    #
    # @example
    #   previous_tag = 'v0.1.0'
    #   tag = 'v0.1.1'
    #   created_on = Date.new(2022, 11, 7)
    #   changes = [
    #     CreateGithubRelease::Change.new('e718690', 'Release v0.1.1 (#3)'),
    #     CreateGithubRelease::Change.new('ab598f3', 'Fix Rubocop offenses')
    #   ]
    #   release_log_url = 'https://github.com/username/repo/compare/v0.1.0...v0.1.1'
    #
    #   release = CreateGithubRelease::Release.new(previous_tag, tag, created_on, changes, release_log_url)
    #   release.tag # => 'v0.1.1'
    #   release.created_on # => #<Date: 2022-11-07 ((2459773j,0s,0n),+0s,2299161j)>
    #
    # @param previous_tag [String] The tag of the previous release
    # @param tag [String] The tag of this release
    # @param created_on [Date] The date the release was created
    # @param changes [Array<CreateGithubRelease::Change>] The changes after the previous release up to this release
    #
    def initialize(previous_tag, tag, created_on, changes, release_log_url)
      @previous_tag = previous_tag
      @tag = tag
      @created_on = created_on
      @changes = changes
      @release_log_url = release_log_url
    end

    # The Git release tag for the previous release
    #
    # @example
    #   previous_tag = 'v0.1.0'
    #   tag = 'v0.1.1'
    #   created_on = Date.new(2022, 11, 7)
    #   changes = [
    #     CreateGithubRelease::Change.new('e718690', 'Release v0.1.1 (#3)'),
    #     CreateGithubRelease::Change.new('ab598f3', 'Fix Rubocop offenses')
    #   ]
    #   release_log_url = 'https://github.com/username/repo/compare/v0.1.0...v0.1.1'
    #
    #   release = CreateGithubRelease::Release.new(previous_tag, tag, created_on, changes, release_log_url)
    #   release.previous_tag # => 'v0.1.0'
    #
    # @return [String] The Git release tag
    #
    attr_reader :previous_tag

    # The Git release tag for this release
    #
    # @example
    #   previous_tag = 'v0.1.0'
    #   tag = 'v0.1.1'
    #   created_on = Date.new(2022, 11, 7)
    #   changes = [
    #     CreateGithubRelease::Change.new('e718690', 'Release v0.1.1 (#3)'),
    #     CreateGithubRelease::Change.new('ab598f3', 'Fix Rubocop offenses')
    #   ]
    #   release_log_url = 'https://github.com/username/repo/compare/v0.1.0...v0.1.1'
    #
    #   release = CreateGithubRelease::Release.new(previous_tag, tag, created_on, changes, release_log_url)
    #   release.tag # => 'v0.1.1'
    #
    # @return [String] The Git release tag
    #
    attr_reader :tag

    # The date the release tag was created
    #
    # @example
    #   previous_tag = 'v0.1.0'
    #   tag = 'v0.1.1'
    #   created_on = Date.new(2022, 11, 7)
    #   changes = [
    #     CreateGithubRelease::Change.new('e718690', 'Release v0.1.1 (#3)'),
    #     CreateGithubRelease::Change.new('ab598f3', 'Fix Rubocop offenses')
    #   ]
    #   release_log_url = 'https://github.com/username/repo/compare/v0.1.0...v0.1.1'
    #
    #   release = CreateGithubRelease::Release.new(previous_tag, tag, created_on, changes, release_log_url)
    #   release.created_on # => #<Date: 2022-11-07 ((2459773j,0s,0n),+0s,2299161j)>
    #
    # @return [Date] The date the release tag was created
    #
    attr_reader :created_on

    # The changes after the previous release up to this release
    #
    # @example
    #   previous_tag = 'v0.1.0'
    #   tag = 'v0.1.1'
    #   created_on = Date.new(2022, 11, 7)
    #   changes = [
    #     CreateGithubRelease::Change.new('e718690', 'Release v0.1.1 (#3)'),
    #     CreateGithubRelease::Change.new('ab598f3', 'Fix Rubocop offenses')
    #   ]
    #   release_log_url = 'https://github.com/username/repo/compare/v0.1.0..v0.1.1'
    #
    #   release = CreateGithubRelease::Release.new(previous_tag, tag, created_on, changes, release_log_url)
    #   release.changes.size # => 2
    #   release.changes[0].sha # => 'e718690'
    #   release.changes[0].subject # => 'Release v0.1.1 (#3)'
    #
    # @return [Array<CreateGithubRelease::Change>] The changes after the previous release up to this release
    #
    attr_reader :changes

    # A page that lists the changes for this release
    #
    # @example
    #   previous_tag = 'v0.1.0'
    #   tag = 'v0.1.1'
    #   created_on = Date.new(2022, 11, 7)
    #   changes = [
    #     CreateGithubRelease::Change.new('e718690', 'Release v0.1.1 (#3)'),
    #     CreateGithubRelease::Change.new('ab598f3', 'Fix Rubocop offenses')
    #   ]
    #   release_log_url = URL.parse('https://github.com/username/repo/compare/v0.1.0...v0.1.1')
    #
    #   release = CreateGithubRelease::Release.new(previous_tag, tag, created_on, changes, release_log_url)
    #   release.changes.size # => 2
    #   release.changes[0].sha # => 'e718690'
    #   release.changes[0].subject # => 'Release v0.1.1 (#3)'
    #
    # @return [URL] A page that lists the changes for this release
    #
    attr_reader :release_log_url

    # The formatted release description
    #
    # @example
    #   previous_tag = 'v0.1.0'
    #   tag = 'v0.1.1'
    #   created_on = Date.new(2022, 11, 7)
    #   changes = [
    #     CreateGithubRelease::Change.new('e718690', 'Release v0.1.1 (#3)'),
    #     CreateGithubRelease::Change.new('ab598f3', 'Fix Rubocop offenses')
    #   ]
    #   release_log_url = 'https://github.com/username/repo/compare/v0.1.0..v0.1.1'
    #
    #   release = CreateGithubRelease::Release.new(previous_tag, tag, created_on, changes, release_log_url)
    #   puts release.to_s
    #   ## v0.1.1 (2022-11-07)
    #
    #   [Full Changelog](https://github.com/username/repo/compare/v0.1.0...v0.1.1)
    #
    #   * e718690 Release v0.1.1 (#3)
    #   * ab598f3 Fix Rubocop offenses
    #
    # @return [String] The formatted release description
    #
    def to_s
      <<~DESCRIPTION
        ## #{tag} (#{created_on.strftime('%Y-%m-%d')})

        [Full Changelog](#{release_log_url})

        #{changes_to_s}
      DESCRIPTION
    end

    # The list of changes in the release as a string
    # @return [String] The list of changes in the release as a string
    # @api private
    def changes_to_s
      changes.map do |change|
        "* #{change.sha} #{change.subject}"
      end.join("\n")
    end
  end
end
