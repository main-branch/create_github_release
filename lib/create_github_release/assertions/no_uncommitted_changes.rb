# frozen_string_literal: true

require 'English'
require 'create_github_release/assertion_base'

module CreateGithubRelease
  module Assertions
    # Assert that there are no uncommitted changes in the local working copy
    #
    # Checks both the local repository and the remote repository.
    #
    # @api public
    #
    class NoUncommittedChanges < AssertionBase
      # Assert that there are no uncommitted changes in the local working copy
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::CommandLineOptions.new { |o| o.release_type = 'major' }
      #   project = CreateGithubRelease::Project.new(options)
      #   assertion = CreateGithubRelease::Assertions::NoUncommittedChanges.new(project)
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
        print 'Checking that there are no uncommitted changes...'
        change_count = `git status --porcelain | wc -l`.to_i
        error "git status command failed: #{$CHILD_STATUS.exitstatus}" unless $CHILD_STATUS.success?

        if change_count.zero?
          puts 'OK'
        else
          error 'There are uncommitted changes'
        end
      end
    end
  end
end
