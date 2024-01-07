# frozen_string_literal: true

require 'English'
require 'create_github_release/assertion_base'

module CreateGithubRelease
  module Assertions
    # Assert that the 'gh' command is in the path
    #
    # @api public
    #
    class GhCommandExists < AssertionBase
      # Make sure that the 'gh' command is in the path
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::CommandLine::Options.new { |o| o.release_type = 'major' }
      #   project = CreateGithubRelease::Project.new(options)
      #   assertion = CreateGithubRelease::Assertions::GhCommandExists.new(project)
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
        print 'Checking that the gh command exists...'
        `which gh > /dev/null 2>&1`
        if $CHILD_STATUS.success?
          puts 'OK'
        else
          error 'The gh command was not found'
        end
      end
    end
  end
end
