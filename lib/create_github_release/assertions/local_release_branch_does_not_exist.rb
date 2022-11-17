# frozen_string_literal: true

require 'English'
require 'create_github_release/assertion_base'

module CreateGithubRelease
  module Assertions
    # Assert that the release branch does not exist in the local repository
    #
    # @api public
    #
    class LocalReleaseBranchDoesNotExist < AssertionBase
      # Assert that the release branch does not exist in the local repository
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
      #   assertion = CreateGithubRelease::Assertions::LocalReleaseBranchDoesNotExist.new(options)
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
        print "Checking that local branch ' #{options.branch}' does not exist..."

        branch_count = `git branch --list '#{options.branch}' | wc -l`.to_i
        error 'Could not list branches' unless $CHILD_STATUS.success?

        if branch_count.zero?
          puts 'OK'
        else
          error "'#{options.branch}' already exists."
        end
      end
    end
  end
end
