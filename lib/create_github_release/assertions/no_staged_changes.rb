# frozen_string_literal: true

require 'English'

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
      #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
      #   assertion = CreateGithubRelease::Assertions::NoStagedChanges.new(options)
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
        if `git diff --staged --name-only | wc -l`.to_i.zero? && $CHILD_STATUS.success?
          puts 'OK'
        else
          error 'There are staged changes'
        end
      end
    end
  end
end
