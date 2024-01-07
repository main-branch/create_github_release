# frozen_string_literal: true

require_relative 'validations'

module CreateGithubRelease
  module CommandLine
    # Validates a set of options after the options have been fully initialized
    # @api private
    class Validator
      # Create a new instance of this class
      # @param options [CreateGithubRelease::CommandLine::Options] the options to validate
      # @api private
      def initialize(options)
        @options = options
      end

      # Returns `true` if all options are valid and `false` otherwise
      #
      # * If the options are valid, returns `true` clears the `#errors` array
      # * If the options are not valid, returns `false` and populates the `#errors` array
      #
      # @example when all options are valid
      #   options = CreateGithubRelease::CommandLine::Options.new
      #   options.release_type = 'major'
      #   options.valid? #=> true
      #   options.errors #=> []
      #
      # @example when one or more options are not valid
      #   options = CreateGithubRelease::CommandLine::Options.new
      #   options.release_type #=> nil
      #   options.valid? #=> false
      #   options.errors #=> ["--release-type must be given and be one of 'major', 'minor', 'patch'"]
      #
      # @return [Boolean]
      #
      def valid?
        @errors = []
        validation_classes.each do |validation_class|
          validation = validation_class.new(options)
          @errors << validation.error unless validation.valid?
        end
        @errors.empty?
      end

      # Returns an array of error messages
      #
      # * If the options are valid, returns an empty array
      # * If the options are not valid, returns an array of error messages
      #
      # @example when all options are valid
      #   options = CreateGithubRelease::CommandLine::Options.new
      #   options.release_type = 'major'
      #   options.valid? #=> true
      #   options.errors #=> []
      #
      # @example when one or more options are not valid
      #   options = CreateGithubRelease::CommandLine::Options.new
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

      # The options to validate
      # @return [CreateGithubRelease::CommandLine::Options]
      # @api private
      attr_reader :options

      # Returns an array of validation classes
      # @return [Array<CreateGithubRelease::Validations::Base>]
      # @api private
      def validation_classes
        [].tap do |validation_classes|
          CreateGithubRelease::CommandLine::Validations.constants.each do |constant_name|
            constant = Validations.const_get(constant_name)
            validation_classes << constant if constant.is_a?(Class) && constant_name.to_s.start_with?('Validate')
          end
        end
      end
    end
  end
end
