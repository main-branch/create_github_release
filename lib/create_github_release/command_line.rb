# frozen_string_literal: true

module CreateGithubRelease
  # This module has all the classes and modules for the command line interface
  #
  # The Parser class is the main interface. It parses and validates the command line
  # arguments and returns an instance of the Options class.
  #
  # @example
  #   parser = CreateGithubRelease::CommandLine::Parser.new
  #   options = parser.parse(*ARGV)
  #   if !option.valid?
  #     puts options.errors
  #     exit 1
  #   end
  #   # ... do something with the options
  #
  # @api public
  #
  module CommandLine
    # An array of the valid release types
    # @return [Array<String>]
    # @api private
    VALID_RELEASE_TYPES = %w[major minor patch pre release first].freeze

    # Regex pattern for a [valid git reference](https://git-scm.com/docs/git-check-ref-format)
    # @return [Regexp]
    # @api private
    VALID_REF_PATTERN = /^(?:(?:[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*)|(?:[a-zA-Z0-9-]+))$/

    # An array of the allowed options that can be passed to `.new`
    # @return [Array<Symbol>]
    ALLOWED_OPTIONS = %i[
      release_type pre pre_type default_branch release_branch remote last_release_version
      next_release_version changelog_path quiet verbose
    ].freeze
  end
end

require_relative 'command_line/options'
require_relative 'command_line/parser'
require_relative 'command_line/validations'
require_relative 'command_line/validator'
