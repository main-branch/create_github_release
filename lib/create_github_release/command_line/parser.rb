# frozen_string_literal: true

require 'English'
require 'optparse'
require 'create_github_release/command_line/options'

module CreateGithubRelease
  module CommandLine
    # rubocop:disable Metrics/ClassLength

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
    class Parser
      # Create a new command line parser
      #
      # @example
      #   parser = CommandLineParser.new
      #
      def initialize
        @option_parser = OptionParser.new
        define_options
        @options = CreateGithubRelease::CommandLine::Options.new
      end

      # Parse the command line arguements returning the options
      #
      # @example
      #   parser = CommandLineParser.new
      #   options = parser.parse(['major'])
      #
      # @param args [Array<String>] the command line arguments
      #
      # @return [CreateGithubRelease::CommandLine::Options] the options
      #
      def parse(*args)
        begin
          option_parser.parse!(remaining_args = args.dup)
        rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
          report_errors(e.message)
        end
        parse_remaining_args(remaining_args)
        # puts options unless options.quiet
        report_errors(*options.errors) unless options.valid?
        options
      end

      private

      # @!attribute [rw] options
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

      # @!attribute [rw] option_parser
      #
      # The option parser
      #
      # @return [OptionParser] the option parser
      #
      # @api private
      #
      attr_reader :option_parser

      # Parse non-option arguments (the release type)
      # @return [void]
      # @api private
      def parse_remaining_args(remaining_args)
        options.release_type = remaining_args.shift || nil
        report_errors('Too many args') unless remaining_args.empty?
      end

      # An error message constructed from the given errors array
      # @return [String]
      # @api private
      def error_message(errors)
        <<~MESSAGE
          #{errors.map { |e| "ERROR: #{e}" }.join("\n")}

          Use --help for usage
        MESSAGE
      end

      # Output an error message and useage to stderr and exit
      # @return [void]
      # @api private
      def report_errors(*errors)
        warn error_message(errors)
        exit 1
      end

      # The banner for the option parser
      BANNER = <<~BANNER.freeze
        Usage:
        #{File.basename($PROGRAM_NAME)} --help | RELEASE_TYPE [options]

        Version #{CreateGithubRelease::VERSION}

        RELEASE_TYPE must be 'major', 'minor', 'patch', 'pre', 'release', or 'first'

        Options:
      BANNER

      # Define the options for OptionParser
      # @return [void]
      # @api private
      def define_options
        # @sg-ignore
        option_parser.banner = BANNER
        %i[
          define_help_option define_default_branch_option define_release_branch_option define_pre_option
          define_pre_type_option define_remote_option define_last_release_version_option define_version_option
          define_next_release_version_option define_changelog_path_option define_quiet_option define_verbose_option
        ].each { |m| send(m) }
      end

      # Define the pre option
      # @return [void]
      # @api private
      def define_pre_option
        option_parser.on('-p', '--pre', 'Create a pre-release') do |pre|
          options.pre = pre
        end
      end

      # Define the pre-type option
      # @return [void]
      # @api private
      def define_pre_type_option
        description = 'Type of pre-release to create (e.g. alpha, beta, etc.)'
        option_parser.on('-t', '--pre-type=TYPE', description) do |pre_type|
          options.pre_type = pre_type
        end
      end

      # Define the quiet option
      # @return [void]
      # @api private
      def define_quiet_option
        option_parser.on('-q', '--[no-]quiet', 'Do not show output') do |quiet|
          options.quiet = quiet
        end
      end

      # Define the verbose option
      # @return [void]
      # @api private
      def define_verbose_option
        option_parser.on('-V', '--[no-]verbose', 'Show extra output') do |verbose|
          options.verbose = verbose
        end
      end

      # Define the help option
      # @return [void]
      # @api private
      def define_help_option
        option_parser.on_tail('-h', '--help', 'Show this message') do
          puts option_parser
          exit 0
        end
      end

      # Define the default_branch option which requires a value
      # @return [void]
      # @api private
      def define_default_branch_option
        option_parser.on('--default-branch=BRANCH_NAME', 'Override the default branch') do |name|
          options.default_branch = name
        end
      end

      # Define the release_branch option which requires a value
      # @return [void]
      # @api private
      def define_release_branch_option
        option_parser.on('--release-branch=BRANCH_NAME', 'Override the release branch to create') do |name|
          options.release_branch = name
        end
      end

      # Define the remote option which requires a value
      # @return [void]
      # @api private
      def define_remote_option
        option_parser.on('--remote=REMOTE_NAME', "Use this remote name instead of 'origin'") do |name|
          options.remote = name
        end
      end

      # Define the last_release_version option which requires a value
      # @return [void]
      # @api private
      def define_last_release_version_option
        option_parser.on('--last-release-version=VERSION', 'Use this version instead `semverify current`') do |version|
          options.last_release_version = version
        end
      end

      # Define the next_release_version option which requires a value
      # @return [void]
      # @api private
      def define_next_release_version_option
        option_parser.on(
          '--next-release-version=VERSION',
          'Use this version instead `semverify next-RELEASE_TYPE`'
        ) do |version|
          options.next_release_version = version
        end
      end

      # Define the changelog_path option which requires a value
      # @return [void]
      # @api private
      def define_changelog_path_option
        option_parser.on('--changelog-path=PATH', 'Use this file instead of CHANGELOG.md') do |name|
          options.changelog_path = name
        end
      end

      # Define the version option
      # @return [void]
      # @api private
      def define_version_option
        option_parser.on_tail('-v', '--version', 'Output the version of this script') do
          puts CreateGithubRelease::VERSION
          exit 0
        end
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
