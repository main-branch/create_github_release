# frozen_string_literal: true

module CreateGithubRelease
  # Base class for assertions
  #
  # All assertions must inherit from this class.
  # It holds the options and knows how to print, puts and error while respecting the `quiet` flag.
  #
  # @api private
  #
  class AssertionBase
    # Create a new assertion object and save the given `project`
    # @param project [CreateGithubRelease::Project] the project to create a release for
    # @api private
    def initialize(project)
      raise ArgumentError, 'project must be a CreateGithubRelease::Project' unless
        project.is_a?(CreateGithubRelease::Project)

      @project = project
    end

    # This method must be overriden by a subclass
    #
    # The subclass is expected to call `error` if the assertion fails.
    #
    # @return [void]
    #
    # @api private
    def assert
      raise NotImplementedError
    end

    # @!attribute [r] options
    #
    # The project passed to the assertion object
    # @return [CreateGithubRelease::Project] the project to create a release for
    # @api private
    attr_reader :project

    # Calls `Kernel.print` if the `quiet` flag is not set in the `project`
    # @param args [Array] the arguments to pass to `Kernel.print`
    # @return [void]
    # @api private
    def print(*args)
      super unless project.quiet?
    end

    # Calls `Kernel.puts` if the `quiet` flag is not set in the `project`
    # @param args [Array] the arguments to pass to `Kernel.puts`
    # @return [void]
    # @api private
    def puts(*args)
      super unless project.quiet?
    end

    # Writes a message to stderr and exits with exitcode 1
    # @param message [String] the message to write to stderr
    # @return [void]
    # @api private
    def error(message)
      warn "ERROR: #{message}"
      exit 1
    end

    # `true` if the `project.verbose?` flag is `true`
    # @return [Boolean]
    # @api private
    def backtick_debug?
      project.verbose?
    end

    # This overrides the backtick operator for this class to output debug
    # information if `verbose?` is true
    include CreateGithubRelease::BacktickDebug
  end
end
