# frozen_string_literal: true

require 'debug'

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
require 'simplecov-lcov'

SimpleCov.formatters = [SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::LcovFormatter]

# Return `true` if the environment variable is set to a truthy value
#
# @example
#   env_true?('COV_SHOW_UNCOVERED')
#
# @param name [String] the name of the environment variable
# @return [Boolean]
#
def env_true?(name)
  value = ENV.fetch(name, '').downcase
  %w[yes on true 1].include?(value)
end

# Return `true` if the environment variable is NOT set to a truthy value
#
# @example
#   env_false?('COV_NO_FAIL')
#
# @param name [String] the name of the environment variable
# @return [Boolean]
#
def env_false?(name)
  !env_true?(name)
end

# Return `true` if the the test run should fail if the coverage is below the threshold
#
# @return [Boolean]
#
def fail_on_low_coverage?
  !(RSpec.configuration.dry_run? || env_true?('COV_NO_FAIL'))
end

# Return `true` if the the test run should show the lines not covered by tests
#
# @return [Boolean]
#
def show_lines_not_covered?
  env_true?('COV_SHOW_UNCOVERED')
end

# Report if the test coverage was below the configured threshold
#
# The threshold is configured by setting the `test_coverage_threshold` variable
# in this file.
#
# Example:
#
# ```Ruby
# test_coverage_threshold = 100
# ```
#
# Coverage below the threshold will cause the rspec run to fail unless the
# `COV_NO_FAIL` environment variable is set to TRUE.
#
# ```Shell
# COV_NO_FAIL=TRUE rspec
# ```
#
# Example of running the tests in an infinite loop writing failures to `fail.txt`:
#
# ```Shell
# while true; do COV_NO_FAIL=TRUE rspec >> fail.txt; done
# ````
#
# The lines missing coverage will be displayed if the `COV_SHOW_UNCOVERED`
# environment variable is set to TRUE.
#
# ```Shell
# COV_SHOW_UNCOVERED=TRUE rspec
# ```
#
test_coverage_threshold = 100

SimpleCov.at_exit do
  SimpleCov.result.format!
  # rubocop:disable Style/StderrPuts
  if SimpleCov.result.covered_percent < test_coverage_threshold
    $stderr.puts
    $stderr.print 'FAIL: ' if fail_on_low_coverage?
    $stderr.puts "RSpec Test coverage fell below #{test_coverage_threshold}%"

    if show_lines_not_covered?
      $stderr.puts "\nThe following lines were not covered by tests:\n"
      SimpleCov.result.files.each do |source_file| # SimpleCov::SourceFile
        source_file.missed_lines.each do |line| # SimpleCov::SourceFile::Line
          $stderr.puts "  .#{source_file.project_filename}:#{line.number}"
        end
      end
    end

    $stderr.puts

    exit 1 if fail_on_low_coverage?
  end
  # rubocop:enable Style/StderrPuts
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
  mocked_command = mocked_commands.find do |c|
    if c.command.is_a?(Regexp)
      c.command.match(command)
    else
      c.command == command
    end
  end
  raise "Command '#{command}' was not mocked" unless mocked_command

  `exit #{mocked_command.exitstatus}`
  mocked_command.stdout
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

# Make sure to require your project AFTER SimpleCov.start
#
require 'create_github_release'
