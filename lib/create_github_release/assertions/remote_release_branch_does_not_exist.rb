# frozen_string_literal: true

require 'English'
require 'create_github_release/assertion_base'

module CreateGithubRelease
  module Assertions
    # Assert that the release branch does not exist in the remote repository
    #
    # @api public
    #
    class RemoteReleaseBranchDoesNotExist < AssertionBase
      # Assert that the release branch does not exist in the remote repository
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::CommandLineOptions.new { |o| o.release_type = 'major' }
      #   project = CreateGithubRelease::Project.new(options)
      #   assertion = CreateGithubRelease::Assertions::RemoteReleaseBranchDoesNotExist.new(project)
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
        print "Checking that the remote branch '#{project.release_branch}' does not exist..."
        `git ls-remote --heads --exit-code '#{project.remote}' '#{project.release_branch}' >/dev/null 2>&1`
        if $CHILD_STATUS.exitstatus == 2
          puts 'OK'
        else
          error 'Could not list branches' unless $CHILD_STATUS.success?
          error "'#{project.release_branch}' already exists"
        end
      end
    end
  end
end
