# frozen_string_literal: true

require 'rbconfig'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Helper class and method for mocking backtick calls

class MockedCommand
  def initialize(command, stdout: '', stderr: '', exitstatus: 0)
    @command = command
    @stdout = stdout
    @stderr = stderr
    @exitstatus = exitstatus
  end

  attr_reader :command, :stdout, :stderr, :exitstatus
end

def execute_mocked_command(mocked_commands, command)
  mocked_command = mocked_commands.find do |c|
    if c.command.is_a?(Regexp)
      c.command.match(command)
    else
      c.command == command
    end
  end
  raise "Command '#{command}' was not mocked" unless mocked_command

  mock_exit_status(mocked_command)

  mocked_command.stdout
end

# Sets $CHILD_STATUS (aka $?) to mock the exit status of a subprocess
#
# @return [Void]
#
def mock_exit_status(mocked_command)
  if RUBY_ENGINE == 'truffleruby'
    # In TruffleRuby backticks do not invoke a shell unless necessary, and therefore
    # cannot find shell built-ins like 'exit', leading to an Errno::ENOENT error.
    #
    # Spawning a new Ruby process to exit works around this issue and is compatible
    # with all Ruby implementations and platforms.
    #
    # However, only do this for TruffleRuby, as spawning a new process is much slower
    # than `exit` and is not necessary for other Ruby implementations.
    #
    pid = Process.spawn(RbConfig.ruby, '-e', "exit #{mocked_command.exitstatus}")
    Process.wait(pid)
  else
    `exit #{mocked_command.exitstatus}`
  end
end

# rubocop:disable Metrics/MethodLength

# Captures stdout and stderr output from a block of code
#
# @example
#   stdout, stderr, exception = capture_output { puts 'hello'; warn 'world' }
#   stdout # => "hello\n"
#   stderr # => "world\n"
#   exception # => nil
#
# @example Used to test an assertion
#   subject { @stdout, @stderr, exception } = capture_output { assertion.assert } }
#
# @return [Array<String, String>] stdout and stderr output
#
def capture_output(&block)
  $stdout = StringIO.new
  $stderr = StringIO.new
  exception = nil
  begin
    block.call
  rescue SystemExit, StandardError => e
    exception = e
  end
  [$stdout.string, $stderr.string, exception]
ensure
  $stdout = STDOUT
  $stderr = STDERR
end

# rubocop:enable Metrics/MethodLength

# SimpleCov configuration
#
def env_true?(key) = %w[true yes on 1].include? ENV.fetch(key, 'false').downcase
def cruby? = (RUBY_ENGINE == 'ruby')
def linux? = RUBY_PLATFORM.include?('linux')
def macos? = RUBY_PLATFORM.include?('darwin')
def ci_build? = ENV.fetch('GITHUB_ACTIONS', 'false') == 'true'

def check_coverage?
  env_true?('COV_CHECK') || (cruby? && (linux? || macos?))
end

if check_coverage?
  # Code specific to MRI Ruby on macOS or Linux
  require 'simplecov'
  require 'simplecov-rspec'
  require 'simplecov-lcov'

  if ci_build?
    SimpleCov.formatters = [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::LcovFormatter
    ]
  end

  SimpleCov::RSpec.start(list_uncovered_lines: ci_build?)
end

# Make sure to require your project AFTER SimpleCov.start
#
require 'create_github_release'
