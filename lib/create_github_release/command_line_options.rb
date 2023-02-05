# frozen_string_literal: true

require 'uri'

# rubocop:disable Metrics/ModuleLength

module CreateGithubRelease
  # An array of the valid release types
  # @return [Array<String>]
  # @api private
  VALID_RELEASE_TYPES = %w[major minor patch first].freeze

  # Regex pattern for a [valid git reference](https://git-scm.com/docs/git-check-ref-format)
  # @return [Regexp]
  # @api private
  VALID_REF_PATTERN = /^(?:(?:[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*)|(?:[a-zA-Z0-9-]+))$/.freeze

  # rubocop:disable Metrics/ClassLength

  # Stores and validates the command line options
  #
  # @example
  #   options = CreateGithubRelease::CommandLineOptions.new
  #   options.release_type = 'major'
  #   options.valid? #=> true
  #   options.errors #=> []
  #
  # @api public
  #
  CommandLineOptions = Struct.new(
    :release_type, :default_branch, :release_branch, :remote, :last_release_version,
    :next_release_version, :changelog_path, :quiet, :verbose,
    keyword_init: true
  ) do
    # @attribute release_type [rw] the type of release to create
    #
    #   Must be one of the VALID_RELEASE_TYPES
    #
    #   @example
    #     options = CreateGithubRelease::CommandLineOptions.new(release_type: 'major')
    #     options.release_type #=> 'major'
    #   @return [String]
    #   @api public

    # @attribute default_branch [rw] the default branch of the repository
    #   @example
    #     options = CreateGithubRelease::CommandLineOptions.new(default_branch: 'main')
    #     options.default_branch #=> 'main'
    #   @return [String]
    #   @api public

    # @attribute release_branch [rw] the branch use to create the release
    #   @example
    #     options = CreateGithubRelease::CommandLineOptions.new(release_branch: 'release-v1.0.0')
    #     options.release_branch #=> 'release-v1.0.0'
    #   @return [String]
    #   @api public

    # @attribute remote [rw] the name of the remote to use to access Github
    #   @example
    #     options = CreateGithubRelease::CommandLineOptions.new(remote: 'origin')
    #     options.remote #=> 'origin'
    #   @return [String]
    #   @api public

    # @attribute last_release_version [rw] the version of the last release
    #   @example
    #     options = CreateGithubRelease::CommandLineOptions.new(last_release_version: '0.1.1')
    #     options.last_release_version #=> '0.1.1'
    #   @return [String]
    #   @api public

    # @attribute next_release_version [rw] the version of the next release
    #   @example
    #     options = CreateGithubRelease::CommandLineOptions.new(next_release_version: '1.0.0')
    #     options.next_release_version #=> '1.0.0'
    #   @return [String]
    #   @api public

    # @attribute changelog_path [rw] the path to the changelog file
    #   @example
    #     options = CreateGithubRelease::CommandLineOptions.new(changelog_path: 'CHANGELOG.md')
    #     options.changelog_path #=> 'CHANGELOG.md'
    #   @return [String]
    #   @api public

    # @attribute quiet [rw] if `true`, suppresses all output
    #   @example
    #     options = CreateGithubRelease::CommandLineOptions.new(quiet: true)
    #     options.quiet #=> true
    #   @return [Boolean]
    #   @api public

    # @attribute verbose [rw] if `true`, enables verbose output
    #   @example
    #     options = CreateGithubRelease::CommandLineOptions.new(verbose: true)
    #     options.verbose #=> true
    #   @return [Boolean]
    #   @api public

    # Create a new instance of this class
    #
    # @example No arguments or block given
    #   options = CreateGithubRelease::CommandLineOptions.new
    #   options.release_type #=> nil
    #   options.valid? #=> false
    #   options.errors #=> ["--release-type must be given and be one of 'major', 'minor', 'patch'"]
    #
    # @example With keyword arguments
    #   config = { release_type: 'major', default_branch: 'main', quiet: true }
    #   options = CreateGithubRelease::CommandLineOptions.new(**config)
    #   options.release_type #=> 'major'
    #   options.default_branch #=> 'main'
    #   options.quiet #=> true
    #   options.valid? #=> true
    #
    # @example with a configuration block
    #   options = CreateGithubRelease::CommandLineOptions.new do |o|
    #     o.release_type = 'major'
    #     o.default_branch = 'main'
    #     o.quiet = true
    #   end
    #   options.release_type #=> 'major'
    #   options.default_branch #=> 'main'
    #   options.quiet #=> true
    #   options.valid? #=> true
    #
    # @yield [self] an initialization block
    # @yieldparam self [CreateGithubRelease::CommandLineOptions] the instance being initialized
    # @yieldreturn [void] the return value is ignored
    #
    def initialize(*)
      super
      self.quiet ||= false
      self.verbose ||= false
      @errors = []
      yield(self) if block_given?
    end

    # Returns `true` if all options are valid and `false` otherwise
    #
    # * If the options are valid, returns `true` clears the `#errors` array
    # * If the options are not valid, returns `false` and populates the `#errors` array
    #
    # @example when all options are valid
    #   options = CreateGithubRelease::CommandLineOptions.new
    #   options.release_type = 'major'
    #   options.valid? #=> true
    #   options.errors #=> []
    #
    # @example when one or more options are not valid
    #   options = CreateGithubRelease::CommandLineOptions.new
    #   options.release_type #=> nil
    #   options.valid? #=> false
    #   options.errors #=> ["--release-type must be given and be one of 'major', 'minor', 'patch'"]
    #
    # @return [Boolean]
    #
    def valid?
      @errors = []
      private_methods(false).select { |m| m.to_s.start_with?('validate_') }.each { |m| send(m) }
      @errors.empty?
    end

    # Returns an array of error messages
    #
    # * If the options are valid, returns an empty array
    # * If the options are not valid, returns an array of error messages
    #
    # @example when all options are valid
    #   options = CreateGithubRelease::CommandLineOptions.new
    #   options.release_type = 'major'
    #   options.valid? #=> true
    #   options.errors #=> []
    #
    # @example when one or more options are not valid
    #   options = CreateGithubRelease::CommandLineOptions.new
    #   options.release_type #=> nil
    #   options.quiet = options.verbose = true
    #   options.valid? #=> false
    #   options.errors #=>  [
    #     "Both --quiet and --verbose cannot be given",
    #     "--release-type must be given and be one of 'major', 'minor', 'patch'"
    #   ]
    #
    # @return [Array<String>] an array of error messages
    #
    def errors
      valid?
      @errors
    end

    private

    # Returns `true` if the given name is a valid git reference
    # @return [Boolean]
    # @api private
    def valid_reference?(name)
      VALID_REF_PATTERN.match?(name)
    end

    # Returns `true` if the `#quiet` is `true` or `false` and `false` otherwise
    # @return [Boolean]
    # @api private
    def validate_quiet
      return true if quiet == true || quiet == false

      @errors << 'quiet must be either true or false'
      false
    end

    # Returns `true` if the `#verbose` is `true` or `false` and `false` otherwise
    # @return [Boolean]
    # @api private
    def validate_verbose
      return true if verbose == true || verbose == false

      @errors << 'verbose must be either true or false'
      false
    end

    # Returns `true` if only one of `#quiet` or `#verbose` is `true`
    # @return [Boolean]
    # @api private
    def validate_only_quiet_or_verbose_given
      return true unless quiet && verbose

      @errors << 'Both --quiet and --verbose cannot both be used'
      false
    end

    # Returns a string representation of the valid release types
    # @return [String]
    # @api private
    def valid_release_types
      "'#{VALID_RELEASE_TYPES.join("', '")}'"
    end

    # Returns `true` if the `#release_type` is not nil
    # @return [Boolean]
    # @api private
    def validate_release_type_given
      return true unless release_type.nil?

      @errors << "RELEASE_TYPE must be given and be one of #{valid_release_types}"
      false
    end

    # Returns `true` if the `#release_type` is nil or a valid release type
    # @return [Boolean]
    # @api private
    def validate_release_type
      return true if release_type.nil? || VALID_RELEASE_TYPES.include?(release_type)

      @errors << "RELEASE_TYPE '#{release_type}' is not valid. Must be one of #{valid_release_types}"
      false
    end

    # Returns `true` if the `#default_branch` is nil or is a valid git reference
    # @return [Boolean]
    # @api private
    def validate_default_branch
      return true if default_branch.nil? || valid_reference?(default_branch)

      @errors << "--default-branch='#{default_branch}' is not valid"
      false
    end

    # Returns `true` if the `#release_branch` is nil or is a valid git reference
    # @return [Boolean]
    # @api private
    def validate_release_branch
      return true if release_branch.nil? || valid_reference?(release_branch)

      @errors << "--release-branch='#{release_branch}' is not valid"
      false
    end

    # Returns `true` if the `#remote` is nil or is a valid git reference
    # @return [Boolean]
    # @api private
    def validate_remote
      return true if remote.nil? || valid_reference?(remote)

      @errors << "--remote='#{remote}' is not valid"
      false
    end

    # Returns `true` if the given version is a valid gem version
    # @return [Boolean]
    # @api private
    def valid_gem_version?(version)
      Gem::Version.new(version)
      true
    rescue ArgumentError
      false
    end

    # Returns `true` if the `#last_release_version` is nil or is a valid gem version
    # @return [Boolean]
    # @api private
    def validate_last_release_version
      return true if last_release_version.nil?

      if valid_gem_version?(last_release_version)
        true
      else
        @errors << "--last-release-version='#{last_release_version}' is not valid"
        false
      end
    end

    # Returns `true` if the `#next_release_version` is nil or is a valid gem version
    # @return [Boolean]
    # @api private
    def validate_next_release_version
      return true if next_release_version.nil?

      if valid_gem_version?(next_release_version)
        true
      else
        @errors << "--next-release-version='#{next_release_version}' is not valid"
        false
      end
    end

    # Returns `true` if the given path is valid
    # @param path [String] the path to validate
    # @return [Boolean]
    # @api private
    def valid_path?(path)
      File.expand_path(path)
      true
    rescue ArgumentError
      false
    end

    # Returns `true` if `#changelog_path` is nil or is a valid regular file path
    # @return [Boolean]
    # @api private
    def validate_changelog_path
      changelog_path.nil? || (changelog_path_valid? && changelog_regular_file?)
    end

    # `true` if `#changelog_path` is a valid path
    # @return [Boolean]
    # @api private
    def changelog_path_valid?
      return true if valid_path?(changelog_path)

      @errors << "--changelog-path='#{changelog_path}' is not valid"
      false
    end

    # `true` if `#changelog_path` does not exist OR if it exists and is a regular file
    # @return [Boolean]
    # @api private
    def changelog_regular_file?
      return true unless File.exist?(changelog_path) && !File.file?(changelog_path)

      @errors << "--changelog-path='#{changelog_path}' must be a regular file"
      false
    end
  end
  # rubocop:enable Metrics/ClassLength
end
# rubocop:enable Metrics/ModuleLength
