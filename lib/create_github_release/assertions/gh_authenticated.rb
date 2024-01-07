# frozen_string_literal: true

require 'English'
require 'create_github_release/assertion_base'

module CreateGithubRelease
  module Assertions
    # Assert that the 'gh' command is in the path
    #
    # @api public
    #
    class GhAuthenticated < AssertionBase
      # Make sure that the 'gh' command is authenticated
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::CommandLine::Options.new { |o| o.release_type = 'major' }
      #   project = CreateGithubRelease::Project.new(options)
      #   assertion = CreateGithubRelease::Assertions::GhAuthenticated.new(project)
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
        print 'Checking that the gh command is authenticated...'
        output = `gh auth status 2>&1`
        if $CHILD_STATUS.success?
          puts 'OK'
        else
          error "gh not authenticated:\n#{output}"
        end
      end
    end
  end
end
