# frozen_string_literal: true

require 'uri'
require 'forwardable'

module CreateGithubRelease
  module CommandLine
    # Stores and validates the command line options
    #
    # @example
    #   options = CreateGithubRelease::CommandLine::Options.new
    #   options.release_type = 'major'
    #   options.valid? #=> true
    #   options.errors #=> []
    #
    # @api public
    #
    class Options
      CreateGithubRelease::CommandLine::ALLOWED_OPTIONS.each { |option| attr_accessor option }

      # @attribute release_type [rw] the type of release to create
      #
      #   Must be one of the VALID_RELEASE_TYPES
      #
      #   @example
      #     options = CreateGithubRelease::CommandLine::Options.new(release_type: 'major')
      #     options.release_type #=> 'major'
      #   @return [String]
      #   @api public

      # @attribute default_branch [rw] the default branch of the repository
      #   @example
      #     options = CreateGithubRelease::CommandLine::Options.new(default_branch: 'main')
      #     options.default_branch #=> 'main'
      #   @return [String]
      #   @api public

      # @attribute release_branch [rw] the branch use to create the release
      #   @example
      #     options = CreateGithubRelease::CommandLine::Options.new(release_branch: 'release-v1.0.0')
      #     options.release_branch #=> 'release-v1.0.0'
      #   @return [String]
      #   @api public

      # @attribute remote [rw] the name of the remote to use to access Github
      #   @example
      #     options = CreateGithubRelease::CommandLine::Options.new(remote: 'origin')
      #     options.remote #=> 'origin'
      #   @return [String]
      #   @api public

      # @attribute last_release_version [rw] the version of the last release
      #   @example
      #     options = CreateGithubRelease::CommandLine::Options.new(last_release_version: '0.1.1')
      #     options.last_release_version #=> '0.1.1'
      #   @return [String]
      #   @api public

      # @attribute next_release_version [rw] the version of the next release
      #   @example
      #     options = CreateGithubRelease::CommandLine::Options.new(next_release_version: '1.0.0')
      #     options.next_release_version #=> '1.0.0'
      #   @return [String]
      #   @api public

      # @attribute changelog_path [rw] the path to the changelog file
      #   @example
      #     options = CreateGithubRelease::CommandLine::Options.new(changelog_path: 'CHANGELOG.md')
      #     options.changelog_path #=> 'CHANGELOG.md'
      #   @return [String]
      #   @api public

      # @attribute quiet [rw] if `true`, suppresses all output
      #   @example
      #     options = CreateGithubRelease::CommandLine::Options.new(quiet: true)
      #     options.quiet #=> true
      #   @return [Boolean]
      #   @api public

      # @attribute verbose [rw] if `true`, enables verbose output
      #   @example
      #     options = CreateGithubRelease::CommandLine::Options.new(verbose: true)
      #     options.verbose #=> true
      #   @return [Boolean]
      #   @api public

      # Create a new instance of this class
      #
      # @example No arguments or block given
      #   options = CreateGithubRelease::CommandLine::Options.new
      #   options.release_type #=> nil
      #   options.valid? #=> false
      #   options.errors #=> ["--release-type must be given and be one of 'major', 'minor', 'patch'"]
      #
      # @example With keyword arguments
      #   config = { release_type: 'major', default_branch: 'main', quiet: true }
      #   options = CreateGithubRelease::CommandLine::Options.new(**config)
      #   options.release_type #=> 'major'
      #   options.default_branch #=> 'main'
      #   options.quiet #=> true
      #   options.valid? #=> true
      #
      # @example with a configuration block
      #   options = CreateGithubRelease::CommandLine::Options.new do |o|
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
      # @yieldparam self [CreateGithubRelease::CommandLine::Options] the instance being initialized
      # @yieldreturn [void] the return value is ignored
      #
      def initialize(**options)
        assert_no_unknown_options(options)
        options.each { |k, v| instance_variable_set("@#{k}", v) }

        self.quiet ||= false
        self.verbose ||= false
        self.pre ||= false
        @errors = []

        yield(self) if block_given?

        @validator = CommandLine::Validator.new(self)

        valid?
      end

      extend Forwardable
      def_delegators :@validator, :valid?, :errors

      private

      # Raise ArgumentError if options has a key not in ALLOWED_OPTIONS
      # @return [void]
      # @api private
      def assert_no_unknown_options(options)
        unknown_options = options.keys - ALLOWED_OPTIONS
        return if unknown_options.empty?

        message = "Unknown keywords: #{unknown_options.join(', ')}"
        raise ArgumentError, message
      end
    end
  end
end
