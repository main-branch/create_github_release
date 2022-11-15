# frozen_string_literal: true

module CreateGithubRelease
  # Base class for tasks
  #
  # All tasks must inherit from this class.
  # It holds the options and knows how to print, puts and error while respecting the `quiet` flag.
  #
  # @api private
  #
  class TaskBase
    # Create a new tasks object and save the given `options`
    # @param options [CreateGithubRelease::Options] the options
    # @api private
    def initialize(options)
      @options = options
    end

    # This method must be overriden by a subclass
    #
    # The subclass is expected to call `error` if the task fails.
    #
    # @return [void]
    #
    # @api private
    def run
      raise NotImplementedError
    end

    # @!attribute [r] options
    #
    # The options passed to the task object
    # @return [CreateGithubRelease::Options] the options
    # @api private
    attr_reader :options

    # Calls `Kernel.print` if the `quiet` flag is not set in the `options`
    # @param args [Array] the arguments to pass to `Kernel.print`
    # @return [void]
    # @api private
    def print(*args)
      super unless options.quiet
    end

    # Calls `Kernel.puts` if the `quiet` flag is not set in the `options`
    # @param args [Array] the arguments to pass to `Kernel.puts`
    # @return [void]
    # @api private
    def puts(*args)
      super unless options.quiet
    end

    # Writes a message to stderr and exits with exitcode 1
    # @param message [String] the message to write to stderr
    # @return [void]
    # @api private
    def error(message)
      warn "ERROR: #{message}"
      exit 1
    end
  end
end
