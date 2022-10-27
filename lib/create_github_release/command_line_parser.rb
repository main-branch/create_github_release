# frozen_string_literal: true

require 'optparse'
require 'create_github_release/options'

module CreateGithubRelease
  # Parses the options for this script
  #
  # @example Specifying the release type
  #   parser = CommandLineParser.new
  #   parser.parse(['major'])
  #   options = parser.options
  #   options.release_type # => "major"
  #   options.quiet # => false
  #
  # @example Specifying the release type and the quiet option
  #   parser = CommandLineParser.new
  #   parser.parse(['--quiet', 'minor'])
  #   options = parser.options
  #   options.release_type # => "minor"
  #   options.quiet # => true
  #
  # @example Showing the command line help
  #   parser = CommandLineParser.new
  #   parser.parse(['--help'])
  #
  # @api public
  #
  class CommandLineParser
    # Create a new command line parser
    #
    # @example
    #   parser = CommandLineParser.new
    #
    def initialize
      @option_parser = OptionParser.new
      define_options
      @options = CreateGithubRelease::Options.new
    end

    # Parse the command line arguements returning the options
    #
    # @example
    #   parser = CommandLineParser.new
    #   options = parser.parse(['major'])
    #
    # @param args [Array<String>] the command line arguments
    #
    # @return [CreateGithubRelease::Options] the options
    #
    def parse(args)
      option_parser.parse!(remaining_args = args.dup)
      parse_remaining_args(remaining_args)
      # puts options unless options.quiet
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
    # @return [CreateGithubRelease::Options] the options
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
      error_with_usage('No release type specified') if remaining_args.empty?
      options.release_type = remaining_args.shift || nil
      error_with_usage('Too many args') unless remaining_args.empty?
    end

    # Output an error message and useage to stderr and exit
    # @return [void]
    # @api private
    def error_with_usage(message)
      warn <<~MESSAGE
        ERROR: #{message}
        #{option_parser}
      MESSAGE
      exit 1
    end

    # Define the options for OptionParser
    # @return [void]
    # @api private
    def define_options
      option_parser.banner = 'Usage: create_release --help | release-type'
      option_parser.separator ''
      option_parser.separator 'Options:'

      define_quiet_option
      define_help_option
    end

    # Define the quiet option
    # @return [void]
    # @api private
    def define_quiet_option
      option_parser.on('-q', '--[no-]quiet', 'Do not show output') do |quiet|
        options.quiet = quiet
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
  end
end
