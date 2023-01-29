# frozen_string_literal: true

module CreateGithubRelease
  # Include this module to output debug information for backticks
  #
  # The class this module is included in must have a `backtick_debug?` method.
  #
  # @example Using this module to debug backticks
  #    class Foo
  #      include CreateGithubRelease::BacktickDebug
  #
  #      def backtick_debug?; true; end
  #
  #      def bar
  #        `echo foo`
  #      end
  #    end
  #
  #    Foo.new.bar #=>
  #    COMMAND
  #      echo foo
  #    OUTPUT
  #      foo
  #    EXITSTATUS
  #      0
  #
  # @api public
  #
  module BacktickDebug
    # Calls `super` and shows the command and its result if `backtick_debug?` is true
    #
    # The command, it's output, and it's exit status are output to stdout via `puts`.
    #
    # The including class is expected to have a `backtick_debug?` method.
    #
    # @example
    #   including_class.new.send('`'.to_sym, 'echo foo') #=>
    #    COMMAND
    #      echo foo
    #    OUTPUT
    #      foo
    #    EXITSTATUS
    #      0
    #
    # @example A command that fails
    #   including_class.new.send('`'.to_sym, 'echo foo; exit 1') #=>
    #    COMMAND
    #      echo foo
    #    OUTPUT
    #      foo
    #    EXITSTATUS
    #      1
    #
    # @param command [String] the command to execute
    #
    # @return [String] the output of the command
    #
    def `(command)
      puts "COMMAND\n  #{command}" if backtick_debug?
      super.tap do |output|
        if backtick_debug?
          puts "OUTPUT\n"
          output.lines { |l| puts "  #{l.chomp}" }
          puts "EXITSTATUS\n  #{$CHILD_STATUS.exitstatus}\n"
        end
      end
    end
  end
end
