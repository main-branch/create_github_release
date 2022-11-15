# frozen_string_literal: true

module CreateGithubRelease
  # The release information needed to generate a changelog
  #
  # @api public
  #
  class Release
    # Create a new release object
    #
    # @example
    #   tag = 'v0.1.1'
    #   date = Date.new(2022, 11, 7)
    #   description = <<~DESCRIPTION
    #     * e718690 Release v0.1.1 (#3)
    #     * a92453c Bug fix (#2)
    #   DESCRIPTION
    #
    #   release = CreateGithubRelease::Release.new(tag, date, description)
    #   release.tag # => 'v0.1.1'
    #   release.date # => #<Date: 2022-11-07 ((2459773j,0s,0n),+0s,2299161j)>
    #   release.description # => "* e718690 Release v0.1.1 (#3)\n* a92453c Bug fix (#2)\n"
    #
    # @param tag [String] The tag of the release
    # @param date [Date] The date of the release
    # @param description [String] The description of the release (usually a bullet list of changes)
    #
    def initialize(tag, date, description)
      @tag = tag
      @date = date
      @description = description
    end

    # The Git release tag
    #
    # @example
    #   tag = 'v0.1.1'
    #   date = Date.new(2022, 11, 7)
    #   description = <<~DESCRIPTION
    #     * e718690 Release v0.1.1 (#3)
    #     * a92453c Bug fix (#2)
    #   DESCRIPTION
    #
    #   release = CreateGithubRelease::Release.new(tag, date, description)
    #   release.tag # => 'v0.1.1'
    #
    # @return [String] The Git release tag
    attr_reader :tag

    # The date the release tag was created
    #
    # @example
    #   tag = 'v0.1.1'
    #   date = Date.new(2022, 11, 7)
    #   description = <<~DESCRIPTION
    #     * e718690 Release v0.1.1 (#3)
    #     * a92453c Bug fix (#2)
    #   DESCRIPTION
    #
    #   release = CreateGithubRelease::Release.new(tag, date, description)
    #   release.date # => #<Date: 2022-11-07 ((2459773j,0s,0n),+0s,2299161j)>
    #
    # @return [Date] The date the release tag was created
    attr_reader :date

    # The description of the release
    #
    # @example
    #   tag = 'v0.1.1'
    #   date = Date.new(2022, 11, 7)
    #   description = <<~DESCRIPTION
    #     * e718690 Release v0.1.1 (#3)
    #     * a92453c Bug fix (#2)
    #   DESCRIPTION
    #
    #   release = CreateGithubRelease::Release.new(tag, date, description)
    #   release.description # => "* e718690 Release v0.1.1 (#3)\n* a92453c Bug fix (#2)\n"
    #
    # @return [String] The description of the release
    attr_reader :description
  end
end
