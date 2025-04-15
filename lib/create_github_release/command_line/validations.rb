# frozen_string_literal: true

module CreateGithubRelease
  module CommandLine
    # Module containing all option validations
    #
    # All validation classes must inherit from `CreateGithubRelease::Validations::Base`
    # and implement the `#valid?` and `#error` methods.
    #
    # All validation classes must be named `Validate*` and must be defined in the
    # `CreateGithubRelease::Validations` namespace. Classes that follow this convention
    # are automatically run by `CreateGithubRelease::CommandLine::OptionsValidator`.
    #
    # @api private
    #
    module Validations
      # All validation classes inherit this classes initializer and options reader
      # @api public
      class Base
        # Create a new validation object with the given options
        #
        # @example
        #  class ValidatePreFlag < Base
        #    def validate
        #      options.pre == false || %w[major minor patch].include?(options.release_type)
        #    end
        #  end
        #
        # @param options [CreateGithubRelease::CommandLine::Options] the options to validate
        #
        def initialize(options)
          @options = options
        end

        private

        # The options to validate
        # @return [CreateGithubRelease::CommandLine::Options]
        # @api private
        attr_reader :options

        # Returns `true` if the given version is a valid gem version
        # @return [Boolean]
        # @api private
        def valid_gem_version?(version)
          Gem::Version.new(version)
          true
        rescue ArgumentError
          false
        end

        # `true` if the given name is a valid git reference
        # @return [Boolean]
        # @api private
        def valid_reference?(name)
          VALID_REF_PATTERN.match?(name)
        end

        # Returns `true` if the given path is a valid path
        # @param path [String] the path to validate
        # @return [Boolean]
        # @api private
        def valid_path?(path)
          File.expand_path(path)
          true
        rescue ArgumentError
          false
        end
      end

      # Validate that `pre` is unset or is set with the appropriate release types
      # @api private
      #
      class ValidatePreFlag < Base
        # Returns `true` if valid
        # @return [Boolean]
        # @api private
        def valid?
          options.pre == false || %w[major minor patch].include?(options.release_type)
        end

        # Called when valid? is `false` to return the error messages
        # @return [String, Array<String>]
        # @api private
        def error
          '--pre can only be given with a release type of major, minor, or patch'
        end
      end

      # Validate if pre_type is nil or releast_type is 'pre' or the pre flag is set
      # @api private
      #
      class ValidatePreType < Base
        # Returns `true` if valid
        # @return [Boolean]
        # @api private
        def valid?
          options.pre_type.nil? ||
            options.release_type == 'pre' ||
            (%w[major minor patch].include?(options.release_type) && options.pre == true)
        end

        # Called when valid? is `false` to return the error messages
        # @return [String, Array<String>]
        # @api private
        def error
          if %w[major minor patch pre].include?(options.release_type)
            '--pre must be given when --pre-type is given'
          else
            '--pre-type can only be given with a release type of major, minor, patch, or pre'
          end
        end
      end

      # Validate that the quiet flag is true or false
      # @api private
      class ValidateQuiet < Base
        # Returns `true` if valid
        # @return [Boolean]
        # @api private
        def valid?
          [true, false].include? options.quiet
        end

        # Called when valid? is `false` to return the error messages
        # @return [String, Array<String>]
        # @api private
        def error
          'quiet must be either true or false'
        end
      end

      # Validate that the verbose flag is true or false
      # @api private
      class ValidateVerbose < Base
        # Returns `true` if the `#verbose` is `true` or `false` and `false` otherwise
        # @return [Boolean]
        # @api private
        def valid?
          [true, false].include? options.verbose
        end

        # Called when valid? is `false` to return the error messages
        # @return [String, Array<String>]
        # @api private
        def error
          'verbose must be either true or false'
        end
      end

      # Validate that either quiet or verbose is given, but not both
      # @api private
      class ValidateOnlyQuietOrVerbose < Base
        # Returns `true` if at most only one of `#quiet` or `#verbose` is `true`
        # @return [Boolean]
        # @api private
        def valid? = !options.quiet || !options.verbose

        # Called when valid? is `false` to return the error messages
        # @return [String, Array<String>]
        # @api private
        def error = '--quiet and --verbose cannot be used together'
      end

      # Validates that a release type is given
      # @api private
      class ValidateReleaseTypeGiven < Base
        # Returns `true` if the `#release_type` is not nil
        # @return [Boolean]
        # @api private
        def valid? = !options.release_type.nil?

        # Called when valid? is `false` to return the error messages
        # @return [String, Array<String>]
        # @api private
        def error
          valid_release_types = "'#{VALID_RELEASE_TYPES.join("', '")}'"
          "RELEASE_TYPE must be given.  Must be one of #{valid_release_types}"
        end
      end

      # Validates that the given release type is valid
      # @api private
      class ValidateReleaseType < Base
        # Returns `true` if the `#release_type` is nil or a valid release type
        # @return [Boolean]
        # @api private
        def valid? = options.release_type.nil? || VALID_RELEASE_TYPES.include?(options.release_type)

        # Called when valid? is `false` to return the error messages
        # @return [String, Array<String>]
        # @api private
        def error
          valid_release_types = "'#{VALID_RELEASE_TYPES.join("', '")}'"
          "RELEASE_TYPE '#{options.release_type}' is not valid. Must be one of #{valid_release_types}"
        end
      end

      # Validates the default branch (if given) a valid Git reference
      # @api private
      class ValidateDefaultBranch < Base
        # Returns `true` if the `#default_branch` is nil or is a valid git reference
        # @return [Boolean]
        # @api private
        def valid? = options.default_branch.nil? || valid_reference?(options.default_branch)

        # Called when valid? is `false` to return the error messages
        # @return [String, Array<String>]
        # @api private
        def error = "--default-branch='#{options.default_branch}' is not valid"
      end

      # Validates the release branch (if given) a valid Git reference
      # @api private
      class ValidateReleaseBranch < Base
        # Returns `true` if the `#release_branch` is nil or is a valid git reference
        # @return [Boolean]
        # @api private
        def valid? = options.release_branch.nil? || valid_reference?(options.release_branch)

        # Called when valid? is `false` to return the error messages
        # @return [String, Array<String>]
        # @api private
        def error = "--release-branch='#{options.release_branch}' is not valid"
      end

      # Validate that the remote (if given) is a valid Git reference
      # @api private
      class ValidateRemote < Base
        # Returns `true` if the `#remote` is nil or is a valid git reference
        # @return [Boolean]
        # @api private
        def valid? = options.remote.nil? || valid_reference?(options.remote)

        # Called when valid? is `false` to return the error messages
        # @return [String, Array<String>]
        # @api private
        def error = "--remote='#{options.remote}' is not valid"
      end

      # Validate that the last release version (if given) is a valid gem version
      # @api private
      class ValidateLastReleaseVersion < Base
        # Returns `true` if the `#last_release_version` is nil or is a valid gem version
        # @return [Boolean]
        # @api private
        def valid? = options.last_release_version.nil? || valid_gem_version?(options.last_release_version)

        # Called when valid? is `false` to return the error messages
        # @return [String, Array<String>]
        # @api private
        def error = "--last-release-version='#{options.last_release_version}' is not valid"
      end

      # Validate that the next release version (if given) is a valid gem version
      # @api private
      class ValidateNextReleaseVersion < Base
        # Returns `true` if the `#next_release_version` is nil or is a valid gem version
        # @return [Boolean]
        # @api private
        def valid? = options.next_release_version.nil? || valid_gem_version?(options.next_release_version)

        # Called when valid? is `false` to return the error messages
        # @return [String, Array<String>]
        # @api private
        def error = "--next-release-version='#{options.next_release_version}' is not valid"
      end

      # Validate that the change log path (if given) is a valid path
      # @api private
      class ValidateChangelogPath < Base
        # Returns `true` if `#changelog_path` is nil or is a valid regular file path
        # @return [Boolean]
        # @api private
        def valid?
          options.changelog_path.nil? ||
            (valid_path?(options.changelog_path) && File.file?(File.expand_path(options.changelog_path)))
        end

        # Called when valid? is `false` to return the error messages
        # @return [String, Array<String>]
        # @api private
        def error
          if valid_path?(options.changelog_path)
            "The change log path '#{options.changelog_path}' is not a regular file"
          else
            "The change log path '#{options.changelog_path}' is not a valid path"
          end
        end
      end
    end
  end
end
