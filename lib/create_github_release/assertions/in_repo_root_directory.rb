# frozen_string_literal: true

require 'English'
require 'fileutils'
require 'create_github_release/assertion_base'

module CreateGithubRelease
  module Assertions
    # Assert that the current directory is the root of the repository
    #
    # Checks both the local repository and the remote repository.
    #
    # @api public
    #
    class InRepoRootDirectory < AssertionBase
      # Make sure that the current directory is the root of the repository
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
      #   assertion = CreateGithubRelease::Assertions::InRepoRootDirectory.new(options)
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
        print "Checking that you are in the repo's root directory..."
        toplevel_directory = `git rev-parse --show-toplevel`.chomp
        error "git rev-parse failed: #{$CHILD_STATUS.exitstatus}" unless $CHILD_STATUS.success?

        if toplevel_directory == FileUtils.pwd
          puts 'OK'
        else
          error "You are not in the repo's root directory"
        end
      end
    end
  end
end
