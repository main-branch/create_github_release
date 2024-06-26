# frozen_string_literal: true

require 'English'
require 'create_github_release/assertion_base'

module CreateGithubRelease
  module Assertions
    # Assert that the current directory is a git repository
    #
    # Checks both the local repository and the remote repository.
    #
    # @api public
    #
    class InGitRepo < AssertionBase
      # Make sure that the current directory is a git repository
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::CommandLine::Options.new { |o| o.release_type = 'major' }
      #   project = CreateGithubRelease::Project.new(options)
      #   assertion = CreateGithubRelease::Assertions::InGitRepo.new(project)
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
        print 'Checking that you are in a git repo...'
        `git rev-parse --is-inside-work-tree --quiet > /dev/null 2>&1`
        if $CHILD_STATUS.success?
          puts 'OK'
        else
          error 'You are not in a git repo'
        end
      end
    end
  end
end
