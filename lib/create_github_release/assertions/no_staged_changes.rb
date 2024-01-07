# frozen_string_literal: true

require 'English'
require 'create_github_release/assertion_base'

module CreateGithubRelease
  module Assertions
    # Assert that there are no staged changes in the local repository
    #
    # Checks both the local repository and the remote repository.
    #
    # @api public
    #
    class NoStagedChanges < AssertionBase
      # Assert that there are no staged changes in the local repository
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::CommandLine::Options.new { |o| o.release_type = 'major' }
      #   project = CreateGithubRelease::Project.new(options)
      #   assertion = CreateGithubRelease::Assertions::NoStagedChanges.new(project)
      #   begin
      #     assertion.assert
      #     puts 'Assertion passed'
      #   rescue SystemExit
      #     puts 'Assertion failed'
      #   end
      #
      # @return [void]
      #
      # @raise [SystemExit] if the assertion fails
      #
      def assert
        print 'Checking that there are no staged changes...'
        change_count = `git diff --staged --name-only | wc -l`.to_i
        error "git diff command failed: #{$CHILD_STATUS.exitstatus}" unless $CHILD_STATUS.success?

        if change_count.zero?
          puts 'OK'
        else
          error 'There are staged changes'
        end
      end
    end
  end
end
