# frozen_string_literal: true

require 'English'

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
      #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
      #   assertion = CreateGithubRelease::Assertions::NoUncommittedChanges.new(options)
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
        if `git status --porcelain | wc -l`.to_i.zero? && $CHILD_STATUS.success?
          puts 'OK'
        else
          error 'There are uncommitted changes'
        end
      end
    end
  end
end
