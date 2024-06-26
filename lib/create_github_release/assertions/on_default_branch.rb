# frozen_string_literal: true

require 'English'
require 'create_github_release/assertion_base'

module CreateGithubRelease
  module Assertions
    # Assert that the default branch is checked out
    #
    # Checks both the local repository and the remote repository.
    #
    # @api public
    #
    class OnDefaultBranch < AssertionBase
      # Assert that the default branch is checked out
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::CommandLine::Options.new { |o| o.release_type = 'major' }
      #   project = CreateGithubRelease::Project.new(options)
      #   assertion = CreateGithubRelease::Assertions::OnDefaultBranch.new(project)
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
        print 'Checking that you are on the default branch...'
        current_branch = `git branch --show-current`.chomp
        if current_branch == project.default_branch
          puts 'OK'
        else
          error "You are not on the default branch '#{project.default_branch}'"
        end
      end
    end
  end
end
