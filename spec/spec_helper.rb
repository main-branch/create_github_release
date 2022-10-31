# frozen_string_literal: true

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Setup simplecov

require 'simplecov'

SimpleCov.formatters = [SimpleCov::Formatter::HTMLFormatter]

# Fail the rspec run if code coverage falls below the configured threshold
#
test_coverage_threshold = 100
SimpleCov.at_exit do
  unless RSpec.configuration.dry_run?
    SimpleCov.result.format!
    if SimpleCov.result.covered_percent < test_coverage_threshold
      warn "FAIL: RSpec Test coverage fell below #{test_coverage_threshold}%"
      exit 1
    end
  end
end

SimpleCov.start

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
  mocked_command = mocked_commands.find { |c| c.command.match(command) }
  raise "Command '#{command}' was not mocked" unless mocked_command

  `exit #{mocked_command.exitstatus}`
  mocked_command.stdout
end

# Captures stdout and stderr output from a block of code
#
# @example
#   stdout, stderr = capture_output { puts 'hello'; warn 'world' }
#   stdout # => "hello\n"
#   stderr # => "world\n"
#
# @example Used to test an assertion
#   subject { @stdout, @stderr = capture_output { assertion.assert } }
#
# @return [Array<String, String>] stdout and stderr output
#
def capture_output(&block)
  $stdout = StringIO.new
  $stderr = StringIO.new
  block.call
  [$stdout.string, $stderr.string]
ensure
  $stdout = STDOUT
  $stderr = STDERR
end

# Make sure to require your project AFTER SimpleCov.start
#
require 'create_github_release'
