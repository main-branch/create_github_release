# frozen_string_literal: true

require 'bump'
require 'uri'

module CreateGithubRelease
  # rubocop:disable Metrics/ClassLength

  # Captures the options for this script
  #
  # @api public
  #
  class Project
    # Initialize a new Project
    #
    # Project attributes are set using one of these methods:
    #   1. The attribute is explicitly set using an attribute writer
    #   2. The attribute is set using the options object
    #   3. The attribute is set using the default value or running some command
    #
    # Method 1 takes precedence, then method 2, then method 3.
    #
    # The recommended way to set the attributes is to use method 2 to override values
    # and otherwise method 3 to use the default value. Method 1 is only recommended for testing
    # or if there is no other way to accomplish what you need.
    #
    # @example calling `.new` without a block
    #   options = CreateGithubRelease::CommandLineOptions.new { |o| o.release_type = 'minor' }
    #   project = CreateGithubRelease::Project.new(options)
    #   options.release_type = 'minor'
    #
    # @example calling `.new` with a block
    #   options = CreateGithubRelease::CommandLineOptions.new { |o| o.release_type = 'minor' }
    #   project = CreateGithubRelease::Project.new(options) do |p|
    #     p.release_type = 'major'
    #   end
    #   options.release_type = 'major'
    #
    # @param options [CreateGithubRelease::CommandLineOptions] the options to initialize the instance with
    #
    # @yield [self] an initialization block
    # @yieldparam self [CreateGithubRelease::Project] the instance being initialized aka `self`
    # @yieldreturn [void] the return value is ignored
    #
    def initialize(options)
      @options = options
      yield self if block_given?
    end

    # @!attribute options [r]
    #
    # The command line options used to initialize this project
    #
    # @example
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.options == options #=> true
    #
    # @return [CreateGithubRelease::CommandLineOptions]
    #
    attr_reader :options

    attr_writer \
      :default_branch, :next_release_tag, :next_release_date, :next_release_version,
      :last_release_tag, :last_release_version, :release_branch, :release_log_url,
      :release_type, :release_url, :remote, :remote_base_url, :remote_repository, :remote_url,
      :changelog_path, :changes, :next_release_description, :last_release_changelog,
      :next_release_changelog, :verbose, :quiet

    # @!attribute [rw] default_branch
    #
    # The default branch of the remote repository
    #
    # This is the default branch as reported by the `HEAD branch` returned by
    # `git remote show #{remote}`.
    #
    # Uses the value of `remote` to determine the remote repository to query.
    #
    # @example By default, `default_branch` is based on `git remote show`
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   options.default_branch # => 'main'
    #
    # @example `default_branch` can be set explicitly
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.default_branch = 'master'
    #   project.default_branch #=> 'master'
    #
    # @return [String]
    #
    # @raise [RuntimeError] if the git command fails
    #
    # @api public
    #
    def default_branch
      @default_branch ||= options.default_branch || begin
        output = `git remote show '#{remote}'`
        raise "Could not determine default branch for remote '#{remote}'" unless $CHILD_STATUS.success?

        output.match(/HEAD branch: (.*?)$/)[1]
      end
    end

    # @!attribute [rw] next_release_tag
    #
    # The tag to use for the next release
    #
    # Uses the value of `next_release_version` to determine the tag name.
    #
    # @example By default, `next_release_tag` is based on `next_release_version`
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.next_release_version = '1.0.0'
    #   project.next_relase_tag #=> 'v1.0.0'
    #
    # @example `next_tag` can be set explicitly
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.next_release_tag = 'v1.0.0'
    #   project.next_relase_tag #=> 'v1.0.0'
    #
    # @return [String]
    #
    # @api public
    #
    def next_release_tag
      @next_release_tag ||= "v#{next_release_version}"
    end

    # @!attribute [rw] next_release_date
    #
    # The date next_release_tag was created
    #
    # If the next_release_tag does not exist, Date.today is returned.
    #
    # @example By default, `next_release_date` is based on `next_release_tag`
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.next_release_tag = 'v1.0.0'
    #   project.next_release_date #=> #<Date: 2023-02-01 ((2459189j,0s,0n),+0s,2299161j)>
    #
    # @example It can also be set explicitly
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.next_release_date = Date.new(2023, 2, 1)
    #   project.next_release_date #=> #<Date: 2023-02-01 ((2459189j,0s,0n),+0s,2299161j)>
    #
    # @return [Date]
    #
    # @raise [RuntimeError] if the git command fails
    #
    # @api public
    #
    def next_release_date
      @next_release_date ||=
        if tag_exist?(next_release_tag)
          date = `git show --format=format:%aI --quiet "#{next_release_tag}"`
          raise "Could not determine date for tag '#{next_release_tag}'" unless $CHILD_STATUS.success?

          Date.parse(date.chomp)
        else
          Date.today
        end
    end

    # `true` if the given tag exists in the local repository
    #
    # @example
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.tag_exist?('v1.0.0') #=> false
    #
    # @param tag [String] the tag to check
    #
    # @return [Boolean]
    #
    # @api public
    #
    def tag_exist?(tag)
      tags = `git tag --list "#{tag}"`.chomp
      raise 'Could not list tags' unless $CHILD_STATUS.success?

      !tags.empty?
    end

    # @!attribute [rw] next_release_version
    #
    # The version of the next release
    #
    # @example By default, `next_release_version` is based on the value returned by `bump show-next <release_type>`
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.next_release_version #=> '1.0.0'
    #
    # @example It can also be set explicitly
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.next_release_version = '1.0.0
    #   project.next_release_version #=> '1.0.0'
    #
    # @return [String]
    #
    # @raise [RuntimeError] if the bump command fails
    #
    # @api public
    #
    def next_release_version
      @next_release_version ||= options.next_release_version || begin
        output = `bump show-next #{release_type}`
        raise 'Could not determine next version using bump' unless $CHILD_STATUS.success?

        output.lines.last.chomp
      end
    end

    # @!attribute [rw] last_release_tag
    #
    # The tag to used for the last release
    #
    # Uses the value of `last_release_version` to determine the tag name.
    #
    # @example By default, `last_release_tag` is based on `last_release_version`
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.last_release_version = '0.0.1'
    #   project.last_relase_tag #=> 'v0.0.1'
    #
    # @example `last_release_tag` can be set explicitly
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.last_release_tag = 'v0.0.1'
    #   project.last_relase_tag #=> 'v0.0.1'
    #
    # @return [String]
    #
    # @api public
    #
    def last_release_tag
      @last_release_tag ||= "v#{last_release_version}"
    end

    # @!attribute [rw] last_release_version
    #
    # The version of the last release
    #
    # @example By default, `last_release_version` is based on the value returned by `bump current`
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.last_release_version #=> '0.0.1'
    #
    # @example It can also be set explicitly
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.last_release_version = '0.0.1
    #   project.last_release_version #=> '0.0.1'
    #
    # @return [String]
    #
    # @raise [RuntimeError] if the bump command fails
    #
    # @api public
    #
    def last_release_version
      @last_release_version ||= options.last_release_version || begin
        output = `bump current`
        raise 'Could not determine current version using bump' unless $CHILD_STATUS.success?

        output.lines.last.chomp
      end
    end

    # @!attribute [rw] release_branch
    #
    # The name of the release branch being created
    #
    # @example By default, `release_branch` is based on the value returned by `next_release_tag`
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.next_release_tag = 'v1.0.0'
    #   project.release_branch #=> 'release-v1.0.0'
    #
    # @example It can also be set explicitly
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.next_release_branch = 'release-v1.0.0'
    #   project.next_release_branch #=> 'release-v1.0.0'
    #
    # @return [String]
    #
    # @raise [RuntimeError] if the bump command fails
    #
    # @api public
    #
    def release_branch
      @release_branch ||= options.release_branch || "release-#{next_release_tag}"
    end

    # @!attribute [rw] release_log_url
    #
    # The URL of the page containing a list of the changes in the release
    #
    # @example By default, `release_log_url` is based on `remote_url`, `last_release_tag`, and `next_release_tag`
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.remote_url = URI.parse('https://github.com/org/repo')
    #   project.last_release_tag = 'v0.0.1'
    #   project.next_release_tag = 'v1.0.0'
    #   project.release_log_url #=> #<URI::HTTPS https://github.com/org/repo/compare/v0.0.1..v1.0.0>
    #
    # @example It can also be set explicitly
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.release_log_url = URI.parse('https://github.com/org/repo/compare/v0.0.1..v1.0.0')
    #   project.release_log_url #=> #<URI::HTTPS https://github.com/org/repo/compare/v0.0.1..v1.0.0>
    #
    # @return [URI]
    #
    # @raise [RuntimeError] if the bump command fails
    #
    # @api public
    #
    def release_log_url
      @release_log_url ||= URI.parse("#{remote_url}/compare/#{last_release_tag}..#{next_release_tag}")
    end

    # @!attribute [rw] release_type
    #
    # The type of the release being created (e.g. 'major', 'minor', 'patch')
    #
    # @note this must be one of the values accepted by the `bump` command
    #
    # @example By default, this value comes from the options object
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.release_type #=> 'major'
    #
    # @example It can also be set explicitly
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.release_type = 'patch'
    #   project.release_type #=> 'patch'
    #
    # @return [String]
    #
    # @raise [ArgumentError] if a release type was not provided
    #
    # @api public
    #
    def release_type
      @release_type ||= options.release_type || raise(ArgumentError, 'release_type is required')
    end

    # @!attribute [rw] release_url
    #
    # The URL of the page containing a list of the changes in the release
    #
    # @example By default, `release_url` is based on `remote_url` and `next_release_tag`
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.remote_url = URI.parse('https://github.com/org/repo')
    #   project.next_release_tag = 'v1.0.0'
    #   project.release_url #=> #<URI::HTTPS https://github.com/org/repo/releases/tag/v1.0.0>
    #
    # @example It can also be set explicitly
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.release_url = URI.parse('https://github.com/org/repo/releases/tag/v1.0.0')
    #   project.release_url #=> #<URI::HTTPS https://github.com/org/repo/releases/tag/v1.0.0>
    #
    # @return [URI]
    #
    # @api public
    #
    def release_url
      @release_url ||= URI.parse("#{remote_url}/releases/tag/#{next_release_tag}")
    end

    # @!attribute [rw] remote
    #
    # The git remote used to determine the repository url
    #
    # @example By default, 'origin' is used
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.remote #=> 'origin'
    #
    # @example It can also be set in the options
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major', remote: 'upstream')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.remote #=> 'upstream'
    #
    # @example It can also be set explicitly
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.remote = 'upstream'
    #   project.remote #=> 'upstream'
    #
    # @return [String]
    #
    # @api public
    #
    def remote
      @remote ||= options.remote || 'origin'
    end

    # @!attribute [rw] remote_base_url
    #
    # The base part of the remote url (e.g. 'https://github.com/')
    #
    # @example By default, this value is based on `remote_url`
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.remote_url = URI.parse('https://github.com/org/repo')
    #   project.remote #=> #<URI::HTTPS https://github.com/>
    #
    # @example It can also be set explicitly
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.remote_base_url = URI.parse('https://github.com/')
    #   project.remote_base_url #=> #<URI::HTTPS https://github.com/>
    #
    # @return [URI]
    #
    # @api public
    #
    def remote_base_url
      @remote_base_url ||= URI.parse(remote_url.to_s[0..-remote_url.path.length])
    end

    # @!attribute [rw] remote_repository
    #
    # The git remote owner and repository name (e.g. 'org/repo')
    #
    # @example By default, this value is based on `remote_url`
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.remote_url = URI.parse('htps://github.com/org/repo')
    #   project.remote_repository #=> 'org/repo'
    #
    # @example It can also be set explicitly
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.remote_repository = 'org/repo'
    #
    # @return [String]
    #
    # @api public
    #
    def remote_repository
      @remote_repository ||= remote_url.path.sub(%r{^/}, '').sub(/\.git$/, '')
    end

    # @!attribute [rw] remote_url
    #
    # The URL of the git remote repository (e.g. 'https://github.com/org/repo')
    #
    # @example By default, this value is based on `remote` and the `git remote get-url` command
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.remote #=> #<URI::HTTPS https://github.com/org/repo>
    #
    # @example It can also be set explicitly
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.remote_url = URI.parse('https://github.com/org/repo')
    #   project.remote_url #=> #<URI::HTTPS https://github.com/org/repo>
    #
    # @return [URI]
    #
    # @api public
    #
    def remote_url
      @remote_url ||= begin
        remote_url_string = `git remote get-url '#{remote}'`
        raise "Could not determine remote url for remote '#{remote}'" unless $CHILD_STATUS.success?

        remote_url_string = remote_url_string.chomp
        remote_url_string = remote_url_string[0..-5] if remote_url_string.end_with?('.git')
        URI.parse(remote_url_string)
      end
    end

    # @!attribute [rw] changelog_path
    #
    # The path relative to the project root where the changelog is located
    #
    # @example By default, this value is 'CHANGELOG.md'
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.changelog_path #=> 'CHANGELOG.md'
    #
    # @example It can also be set in the options
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major', changelog_path: 'docs/CHANGES.txt')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.remote_repository = 'docs/CHANGES.txt'
    #
    # @example It can also be set explicitly
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.changelog_path = 'docs/CHANGES.txt'
    #   project.remote_repository = 'docs/CHANGES.txt'
    #
    # @return [String]
    #
    # @api public
    #
    def changelog_path
      @changelog_path ||= options.changelog_path || 'CHANGELOG.md'
    end

    # @!attribute [rw] changes
    #
    # An array containing the changes since the last_release_tag
    #
    # Calls `git log HEAD <next_release_tag>` to list the changes.
    #
    # @example By default, uses `git log`
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   pp project.changes
    #   [
    #     #<CreateGithubRelease::Change:0x00000001084b92f0 @sha="24bdd02", @subject="Foo feature">,
    #     #<CreateGithubRelease::Change:0x00000001084b93e0 @sha="d75e1e9", @subject="Bar feature">
    #   ]
    #
    # @example It can also be set explicitly
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.changes = 'All the changes'
    #   project.changes #=> 'All the changes'
    #
    # @return [Array<CreateGithubRelease>]
    #
    # @api public
    #
    def changes
      @changes ||= begin
        command = "git log 'HEAD' '^#{last_release_tag}' --oneline --format='format:%h\t%s'"
        git_log = `#{command}`
        raise "Could not determine changes since #{last_release_tag}" unless $CHILD_STATUS.success?

        git_log.split("\n").map { |l| ::CreateGithubRelease::Change.new(*l.split("\t")) }
      end
    end

    # @!attribute [rw] next_release_description
    #
    # The formatted release description
    #
    # @example
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options) do |p|
    #     p.remote_url = URI.parse('https://github.com/username/repo')
    #     p.last_release_tag = 'v0.1.0'
    #     p.next_release_tag = 'v1.0.0'
    #     p.next_release_date = Date.new(2022, 11, 7)
    #     p.changes = [
    #       CreateGithubRelease::Change.new('e718690', 'Release v1.0.0 (#3)'),
    #       CreateGithubRelease::Change.new('ab598f3', 'Fix Rubocop offenses (#2)')
    #     ]
    #   end
    #   puts project.next_release_description
    #   ## v1.0.0 (2022-11-07)
    #
    #   [Full Changelog](https://github.com/username/repo/compare/v0.1.0...v1.0.0
    #
    #   * e718690 Release v1.0.0 (#3)
    #   * ab598f3 Fix Rubocop offenses (#2)
    #
    # @return [String]
    #
    # @api public
    #
    def next_release_description
      @next_release_description ||= <<~DESCRIPTION
        ## #{next_release_tag} (#{next_release_date.strftime('%Y-%m-%d')})

        [Full Changelog](#{release_log_url})

        #{list_of_changes}
      DESCRIPTION
    end

    # @!attribute [rw] last_release_changelog
    #
    # The existing changelog (of the last release) as a string
    #
    # @example
    #   changelog_path = 'TEST_CHANGELOG.md'
    #   File.write(changelog_path, <<~CHANGELOG)
    #     # Project Changelog
    #
    #     ## v0.1.0 (2021-11-07)
    #
    #     * e718690 Release v0.1.0 (#3)
    #   CHANGELOG
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options) do |p|
    #     p.changelog_path = changelog_path
    #   end
    #   puts project.last_release_changelog
    #   # Project Changelog
    #
    #   ## v0.1.0 (2021-11-07)
    #
    #   * e718690 Release v0.1.0 (#3)
    #
    # @return [String]
    #
    # @api public
    #
    def last_release_changelog
      @last_release_changelog ||= begin
        File.read(changelog_path)
      rescue Errno::ENOENT
        ''
      rescue StandardError
        raise 'Could not read the changelog file'
      end
    end

    # @!attribute [rw] next_release_changelog
    #
    # The changelog of the next release as a string
    #
    # This is the result of inserting next_release_description into
    # last_release_changelog.
    #
    # @example
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options) do |p|
    #     p.last_release_changelog = <<~CHANGELOG
    #       # Project Changelog
    #
    #       ## v0.1.0 (2021-11-07)
    #
    #       * e718690 Release v0.1.0 (#3)
    #     CHANGELOG
    #     p.next_release_description = <<~next_release_description
    #       ## v1.0.0 (2022-11-07)
    #
    #       [Full Changelog](http://github.com/org/repo/compare/v0.1.0...v1.0.0)
    #
    #       * e718690 Release v1.0.0 (#3)
    #       * ab598f3 Add the FizzBuzz Feature (#2)
    #     next_release_description
    #   end
    #   puts project.next_release_changelog
    #
    # @return [String]
    #
    # @api public
    #
    def next_release_changelog
      @next_release_changelog ||=
        CreateGithubRelease::Changelog.new(last_release_changelog, next_release_description).to_s
    end

    # Show the project details as a string
    #
    # @example
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   puts projects.to_s
    #   default_branch: main
    #   next_release_tag: v1.0.0
    #   next_release_date: 2023-02-01
    #   next_release_version: 1.0.0
    #   last_release_tag: v0.1.0
    #   last_release_version: 0.1.0
    #   release_branch: release-v1.0.0
    #   release_log_url: https://github.com/org/repo/compare/v0.1.0..v1.0.0
    #   release_type: major
    #   release_url: https://github.com/org/repo/releases/tag/v1.0.0
    #   remote: origin
    #   remote_base_url: https://github.com/
    #   remote_repository: org/repo
    #   remote_url: https://github.com/org/repo
    #   changelog_path: CHANGELOG.md
    #   verbose?: false
    #   quiet?: false
    #
    # @return [String]
    #
    # @api public
    #
    def to_s
      <<~OUTPUT
        default_branch: #{default_branch}
        next_release_tag: #{next_release_tag}
        next_release_date: #{next_release_date}
        next_release_version: #{next_release_version}
        last_release_tag: #{last_release_tag}
        last_release_version: #{last_release_version}
        release_branch: #{release_branch}
        release_log_url: #{release_log_url}
        release_type: #{release_type}
        release_url: #{release_url}
        remote: #{remote}
        remote_base_url: #{remote_base_url}
        remote_repository: #{remote_repository}
        remote_url: #{remote_url}
        verbose?: #{verbose?}
        quiet?: #{quiet?}
      OUTPUT
    end

    # @!attribute [rw] verbose
    #
    # If `true` enables verbose output
    #
    # @example By default, this value is based on the `verbose` option
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major', verbose: true)
    #   project = CreateGithubRelease::Project.new(options)
    #   project.verbose? #=> true
    #
    # @example It can also be set explicitly
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.verbose = true
    #   project.verbose? #=> true
    #
    # @return [Boolean]
    #
    # @api public
    #
    def verbose
      @verbose ||= options.verbose || false
    end

    alias verbose? verbose

    # @!attribute [rw] quiet
    #
    # If `true` supresses all output
    #
    # @example By default, this value is based on the `quiet` option
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major', quiet: true)
    #   project = CreateGithubRelease::Project.new(options)
    #   project.quiet? #=> true
    #
    # @example It can also be set explicitly
    #   options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #   project = CreateGithubRelease::Project.new(options)
    #   project.quiet = true
    #   project.quiet? #=> true
    #
    # @return [Boolean]
    #
    # @api public
    #
    def quiet
      @quiet ||= options.quiet || false
    end

    alias quiet? quiet

    private

    # The list of changes in the release as a string
    # @return [String] The list of changes in the release as a string
    # @api private
    def list_of_changes
      changes.map do |change|
        "* #{change.sha} #{change.subject}"
      end.join("\n")
    end

    # `true` if the `#verbose?` flag is `true`
    # @return [Boolean]
    # @api private
    def backtick_debug?
      verbose?
    end

    # Override the backtick operator for this class to call super and output
    # debug information if `verbose?` is true
    include CreateGithubRelease::BacktickDebug
  end

  # rubocop:enable Metrics/ClassLength
end
