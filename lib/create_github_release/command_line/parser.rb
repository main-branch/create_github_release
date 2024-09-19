# frozen_string_literal: true

require 'English'
require 'command_line_boss'
require 'create_github_release/command_line/options'
require 'create_github_release/version'

module CreateGithubRelease
  module CommandLine
    # Parses the options for this script
    #
    # @example Specify the release type
    #   options = CommandLineParser.new.parse('major')
    #   options.valid? # => true
    #   options.release_type # => "major"
    #   options.quiet # => false
    #
    # @example Specify the release type and the quiet option
    #   parser = CommandLineParser.new
    #   args = %w[minor --quiet]
    #   options = parser.parse(*args)
    #   options.release_type # => "minor"
    #   options.quiet # => true
    #
    # @example Show the command line help
    #   CommandLineParser.new.parse('--help')
    #   parser.parse('--help')
    #
    # @api public
    #
    class Parser < CommandLineBoss
      # @!attribute [r] options
      #
      # The options to used for the create-github-release script
      #
      # @example
      #   parser = CommandLineParser.new
      #   parser.parse(['major'])
      #   options = parser.options
      #   options.release_type # => 'major'
      #
      # @return [CreateGithubRelease::CommandLine::Options] the options
      #
      # @api private
      #
      attr_reader :options

      private

      # Set the default options
      # @return [Void]
      # @api private
      def set_defaults
        @options = CreateGithubRelease::CommandLine::Options.new
      end

      # Parse non-option arguments (the release type)
      # @return [void]
      # @api private
      def parse_arguments
        options.release_type = args.shift
      end

      # The banner for the option parser
      # @return [String] the banner
      # @api private
      def banner = <<~BANNER.freeze
        Usage:
        #{File.basename($PROGRAM_NAME)} --help | RELEASE_TYPE [options]

        Version #{CreateGithubRelease::VERSION}

        RELEASE_TYPE must be 'major', 'minor', 'patch', 'pre', 'release', or 'first'

        Options:
      BANNER

      # Define the release_pr_label option which requires a value
      # @return [void]
      # @api private
      def define_release_pr_label_option
        parser.on('--release-pr-label=LABEL', 'The label to apply to the release pull request') do |label|
          options.release_pr_label = label
        end
      end

      # Define the pre option
      # @return [void]
      # @api private
      def define_pre_option
        parser.on('-p', '--pre', 'Create a pre-release') do |pre|
          options.pre = pre
        end
      end

      # Define the pre-type option
      # @return [void]
      # @api private
      def define_pre_type_option
        description = 'Type of pre-release to create (e.g. alpha, beta, etc.)'
        parser.on('-t', '--pre-type=TYPE', description) do |pre_type|
          options.pre_type = pre_type
        end
      end

      # Define the quiet option
      # @return [void]
      # @api private
      def define_quiet_option
        parser.on('-q', '--[no-]quiet', 'Do not show output') do |quiet|
          options.quiet = quiet
        end
      end

      # Define the verbose option
      # @return [void]
      # @api private
      def define_verbose_option
        parser.on('-V', '--[no-]verbose', 'Show extra output') do |verbose|
          options.verbose = verbose
        end
      end

      # Define the help option
      # @return [void]
      # @api private
      def define_help_option
        parser.on_tail('-h', '--help', 'Show this message') do
          puts parser
          exit 0
        end
      end

      # Define the default_branch option which requires a value
      # @return [void]
      # @api private
      def define_default_branch_option
        parser.on('--default-branch=BRANCH_NAME', 'Override the default branch') do |name|
          options.default_branch = name
        end
      end

      # Define the release_branch option which requires a value
      # @return [void]
      # @api private
      def define_release_branch_option
        parser.on('--release-branch=BRANCH_NAME', 'Override the release branch to create') do |name|
          options.release_branch = name
        end
      end

      # Define the remote option which requires a value
      # @return [void]
      # @api private
      def define_remote_option
        parser.on('--remote=REMOTE_NAME', "Use this remote name instead of 'origin'") do |name|
          options.remote = name
        end
      end

      # Define the last_release_version option which requires a value
      # @return [void]
      # @api private
      def define_last_release_version_option
        parser.on(
          '--last-release-version=VERSION',
          'Use this version instead `gem-version-boss current`'
        ) do |version|
          options.last_release_version = version
        end
      end

      # Define the next_release_version option which requires a value
      # @return [void]
      # @api private
      def define_next_release_version_option
        parser.on(
          '--next-release-version=VERSION',
          'Use this version instead `gem-version-boss next-RELEASE_TYPE`'
        ) do |version|
          options.next_release_version = version
        end
      end

      # Define the changelog_path option which requires a value
      # @return [void]
      # @api private
      def define_changelog_path_option
        parser.on('--changelog-path=PATH', 'Use this file instead of CHANGELOG.md') do |name|
          options.changelog_path = name
        end
      end

      # Define the version option
      # @return [void]
      # @api private
      def define_version_option
        parser.on_tail('-v', '--version', 'Output the version of this script') do
          puts CreateGithubRelease::VERSION
          exit 0
        end
      end

      # Validate the options once they have been parsed
      # @return [Void]
      # @raise [SystemExit] if the options are invalid
      # @api private
      def validate_options
        options.errors.each { |error_message| add_error_message(error_message) }
      end
    end
  end
end
