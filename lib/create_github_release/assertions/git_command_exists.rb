# frozen_string_literal: true

require 'English'
require 'create_github_release/assertion_base'

module CreateGithubRelease
  module Assertions
    # Assert that the 'git' command is in the path
    #
    # @api public
    #
    class GitCommandExists < AssertionBase
      # Make sure that the 'git' command is in the path
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
      #   assertion = CreateGithubRelease::Assertions::GitCommandExists.new(options)
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
        print 'Checking that the git command exists...'
        `which git > /dev/null 2>&1`
        if $CHILD_STATUS.success?
          puts 'OK'
        else
          error 'The git command was not found'
        end
      end
    end
  end
end
