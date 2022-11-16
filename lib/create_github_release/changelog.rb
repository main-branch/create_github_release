# frozen_string_literal: true

module CreateGithubRelease
  # Generate a changelog for a new release
  #
  # Given an existing changelog and a description of a new release, generate a
  # new changelog that includes the new release.
  #
  # @api public
  #
  class Changelog
    # Create a new changelog object
    #
    # @example
    #   existing_changelog = <<~EXISTING_CHANGELOG.chomp
    #     # Change Log
    #
    #     List of changes in each release of this project.
    #
    #     ## v0.1.0 (2022-10-31)
    #
    #     * 07a1167 Release v0.1.0 (#1)
    #   EXISTING_CHANGELOG
    #
    #   new_release_tag = 'v1.0.0'
    #   new_release_date = Date.parse('2022-11-10')
    #   new_release_description = <<~RELEASE
    #     * f5e69d6 Release v1.0.0 (#4)
    #     * 8fe479b Update documentation for initial GA release (#3)
    #   RELEASE
    #
    #   new_release = CreateGithubRelease::Release.new(new_release_tag, new_release_date, new_release_description)
    #
    #   changelog = CreateGithubRelease::Changelog.new(existing_changelog, new_release)
    #
    #   expected_new_changelog = <<~CHANGELOG
    #     # Change Log
    #
    #     List of changes in each release of this project.
    #
    #     ## v1.0.0 (2022-11-10)
    #
    #     * f5e69d6 Release v1.0.0 (#4)
    #     * 8fe479b Update documentation for initial GA release (#3)
    #
    #     ## v0.1.0 (2022-10-31)
    #
    #     * 07a1167 Release v0.1.0 (#1)
    #   CHANGELOG
    #
    #   changelog.front_matter # =>  "# Change Log\n\nList of changes in each release of this project."
    #   changelog.body # => "## v0.1.0 (2022-10-31)\n\n* 07a1167 Release v0.1.0 (#1)"
    #   changelog.new_release # => #<CreateGithubRelease::Release:0x000000010761aac8 ...>
    #   changelog.to_s == expected_new_changelog # => true
    #
    # @param existing_changelog [String] Contents of the changelog as a string
    # @param new_release [CreateGihubRelease::Release] The new release to add to the changelog
    #
    def initialize(existing_changelog, new_release)
      @existing_changelog = existing_changelog
      @new_release = new_release

      @lines = existing_changelog.lines.map(&:chomp)
    end

    # The front matter of the changelog
    #
    # This is the part of the changelog up until the body. The body contains the list
    # of releases and is the first line starting with '## '.
    #
    # @example Changelog with front matter
    #   changelog_text = <<~CHANGELOG
    #     This is the front matter
    #     ## v0.1.0
    #     ...
    #   CHANGELOG
    #
    #   new_release = CreateGithubRelease::Release.new('v0.1.0', Date.today, '...')
    #
    #   changelog = CreateGithubRelease::Changelog.new(changelog_text, new_release)
    #   changelog.front_matter # => "This is the front matter\n"
    #
    # @example Changelog without front matter
    #   changelog_text = <<~CHANGELOG
    #     ## v0.1.0
    #     ...
    #   CHANGELOG
    #
    #   new_release = CreateGithubRelease::Release.new('v0.1.0', Date.today, '...')
    #
    #   changelog = CreateGithubRelease::Changelog.new(changelog_text, new_release)
    #   changelog.front_matter # => ""
    #
    # @example An empty changelog
    #   changelog_text = <<~CHANGELOG
    #   CHANGELOG
    #
    #   new_release = CreateGithubRelease::Release.new('v0.1.0', Date.today, '...')
    #
    #   changelog = CreateGithubRelease::Changelog.new(changelog_text, new_release)
    #   changelog.front_matter # => ""
    #
    # @example An empty changelog
    #   changelog_text = ""
    #
    #   new_release = CreateGithubRelease::Release.new('v0.1.0', Date.today, '...')
    #
    #   changelog = CreateGithubRelease::Changelog.new(changelog_text, new_release)
    #   changelog.front_matter # => ""
    #
    # @return [String] The front matter of the changelog
    def front_matter
      return '' if front_matter_start == front_matter_end

      lines[front_matter_start..front_matter_end - 1].join("\n")
    end

    # The body of the existing changelog
    #
    # @example Changelog with front matter and a body
    #   changelog_text = <<~CHANGELOG
    #     This is the front matter
    #     ## v0.1.0
    #     ...
    #   CHANGELOG
    #
    #   new_release = CreateGithubRelease::Release.new('v0.1.0', Date.today, '...')
    #
    #   changelog = CreateGithubRelease::Changelog.new(changelog_text, new_release)
    #   changelog.body # => "## v0.1.0\n..."
    #
    # @example Changelog without front matter
    #   changelog_text = <<~CHANGELOG
    #     ## v0.1.0
    #     ...
    #   CHANGELOG
    #
    #   new_release = CreateGithubRelease::Release.new('v0.1.0', Date.today, '...')
    #
    #   changelog = CreateGithubRelease::Changelog.new(changelog_text, new_release)
    #   changelog.body # => "## v0.1.0\n..."
    #
    # @example Changelog without a body
    #   changelog_text = <<~CHANGELOG
    #     This is the front matter
    #   CHANGELOG
    #
    #   new_release = CreateGithubRelease::Release.new('v0.1.0', Date.today, '...')
    #
    #   changelog = CreateGithubRelease::Changelog.new(changelog_text, new_release)
    #   changelog.body # => ""
    #
    # @example An empty changelog (new line only)
    #   changelog_text = <<~CHANGELOG
    #   CHANGELOG
    #
    #   new_release = CreateGithubRelease::Release.new('v0.1.0', Date.today, '...')
    #
    #   changelog = CreateGithubRelease::Changelog.new(changelog_text, new_release)
    #   changelog.body # => ""
    #
    # @example An empty changelog (empty string)
    #   changelog_text = ""
    #
    #   new_release = CreateGithubRelease::Release.new('v0.1.0', Date.today, '...')
    #
    #   changelog = CreateGithubRelease::Changelog.new(changelog_text, new_release)
    #   changelog.body # => ""
    #
    # @return [String] The body of the existing changelog
    #
    def body
      return '' if body_start == body_end

      lines[body_start..body_end - 1].join("\n")
    end

    # The changelog before the new release is added
    #
    # @example
    #   changelog.existing_changelog # => "# Change Log\n\n## v1.0.0...## v0.1.0...\n"
    #
    # @return [String] The changelog before the new release is added
    #
    attr_reader :existing_changelog

    # The new release to add to the changelog
    #
    # @example
    #   changelog.new_release.tag # => 'v1.0.0'
    #   changelog.new_release.date # => #<Date: 2018-06-30>
    #   changelog.new_release.description # => "[Full Changelog](...)..."
    #
    # @return [CreateGithubRelease::Release] The new release to add to the changelog
    #
    attr_reader :new_release

    # The changelog with the new release
    #
    # @example Changelog with front matter and a body
    #   changelog_text = <<~CHANGELOG
    #     This is the front matter
    #     ## v0.1.0
    #     ...
    #   CHANGELOG
    #
    #   new_release = CreateGithubRelease::Release.new(
    #     'v1.0.0', Date.parse('2022-11-08'), '...release description...'
    #   )
    #
    #   expected_changelog = <<~CHANGELOG
    #     This is the front matter
    #
    #     ## v1.0.0 (2022-11-08)
    #     ...release description...
    #
    #     ## v0.1.0
    #     ...
    #   CHANGELOG
    #
    #   changelog = CreateGithubRelease::Changelog.new(changelog_text, new_release)
    #
    #   changelog.to_s == expected_changelog # => true
    #
    # @example Changelog without front matter
    #   changelog_text = <<~CHANGELOG
    #     ## v0.1.0
    #     ...
    #   CHANGELOG
    #
    #   new_release = CreateGithubRelease::Release.new(
    #     'v1.0.0', Date.parse('2022-11-08'), '...release description...'
    #   )
    #
    #   expected_changelog = <<~CHANGELOG
    #     ## v1.0.0 (2022-11-08)
    #     ...release description...
    #
    #     ## v0.1.0
    #     ...
    #   CHANGELOG
    #
    #   changelog = CreateGithubRelease::Changelog.new(changelog_text, new_release)
    #
    #   changelog.to_s == expected_changelog # => true
    #
    # @example Changelog without a body
    #   changelog_text = <<~CHANGELOG
    #     This is the front matter
    #   CHANGELOG
    #
    #   new_release = CreateGithubRelease::Release.new(
    #     'v1.0.0', Date.parse('2022-11-08'), '...release description...'
    #   )
    #
    #   expected_changelog = <<~CHANGELOG
    #     This is the front matter
    #
    #     ## v1.0.0 (2022-11-08)
    #     ...release description...
    #   CHANGELOG
    #
    #   changelog = CreateGithubRelease::Changelog.new(changelog_text, new_release)
    #
    #   changelog.to_s == expected_changelog # => true
    #
    # @example A new release without a description
    #   changelog_text = <<~CHANGELOG
    #     This is the front matter
    #     ## v0.1.0
    #     ...
    #   CHANGELOG
    #
    #   new_release = CreateGithubRelease::Release.new(
    #     'v1.0.0', Date.parse('2022-11-08'), ''
    #   )
    #
    #   expected_changelog = <<~CHANGELOG
    #     This is the front matter
    #
    #     ## v1.0.0 (2022-11-08)
    #
    #     ## v0.1.0
    #     ...
    #   CHANGELOG
    #
    #   changelog = CreateGithubRelease::Changelog.new(changelog_text, new_release)
    #
    #   changelog.to_s == expected_changelog # => true
    #
    # @return [String] The changelog with the new release details
    #
    def to_s
      String.new.tap do |changelog|
        changelog << formatted_front_matter unless front_matter.empty?
        changelog << release_header << release_description
        changelog << formatted_body unless body.empty?
      end
    end

    private

    # The front matter formatted to insert into the changelog
    # @return [String] The front matter formatted to insert into the changelog
    # @api private
    def formatted_front_matter
      "#{front_matter}\n\n"
    end

    # The body formatted to insert into the changelog
    # @return [String] The body formatted to insert into the changelog
    # @api private
    def formatted_body
      "\n#{body}\n"
    end

    # The index of the line in @lines where the front matter begins
    # @return [Integer] The index of the line in @lines where the front matter begins
    # @api private
    def front_matter_start
      @front_matter_start ||= begin
        i = 0
        i += 1 while i < body_start && lines[i] =~ /^\s*$/
        i
      end
    end

    # One past the index of the line in @lines where the front matter ends
    # @return [Integer] One past the index of the line in @lines where the front matter ends
    # @api private
    def front_matter_end
      @front_matter_end ||= begin
        i = body_start
        i -= 1 while i.positive? && lines[i - 1] =~ /^\s*$/
        i
      end
    end

    # The index of the line in @lines where the body begins
    # @return [Integer] The index of the line in @lines where the body begins
    # @api private
    def body_start
      @body_start ||=
        lines.index { |l| l.start_with?('## ') } || lines.length
    end

    # One past the index of the line in @lines where the body ends
    # @return [Integer] One past the index of the line in @lines where the body ends
    # @api private
    def body_end
      @body_end ||=
        if body_start == lines.length
          body_start
        else
          i = lines.length
          i -= 1 while i > body_start && lines[i - 1] =~ /^\s*$/
          i
        end
    end

    # The release header to output in the changelog
    # @return [String] The release header to output in the changelog
    # @api private
    def release_header
      "## #{new_release.tag} (#{new_release.date.strftime('%Y-%m-%d')})\n"
    end

    # The release description to output in the changelog
    # @return [String] The release description to output in the changelog
    # @api private
    def release_description
      new_release.description.empty? ? '' : "\n#{new_release.description.chomp}\n"
    end

    # Line number where the body of the changelog starts
    # @return [Integer] Line number where the body of the changelog starts
    # @api private
    # attr_reader :body_start

    # The existing changelog broken into an array of lines
    # @return [Array<String>] The existing changelog broken into an array of lines
    # @api private
    attr_reader :lines
  end
end
