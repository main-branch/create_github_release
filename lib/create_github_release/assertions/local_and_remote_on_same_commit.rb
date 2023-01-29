# frozen_string_literal: true

require 'English'
require 'create_github_release/assertion_base'

module CreateGithubRelease
  module Assertions
    # Assert that the local working directory and the remote are on the same commit
    #
    # Checks both the local repository and the remote repository.
    #
    # @api public
    #
    class LocalAndRemoteOnSameCommit < AssertionBase
      # Make sure that the local working directory and the remote are on the same commit
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::CommandLineOptions.new { |o| o.release_type = 'major' }
      #   project = CreateGithubRelease::Project.new(options)
      #   assertion = CreateGithubRelease::Assertions::LocalAndRemoteOnSameCommit.new(project)
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
        print 'Checking that local and remote are on the same commit...'
        local_commit = `git rev-parse HEAD`.chomp
        remote_commit = `git ls-remote '#{project.remote}' '#{project.default_branch}' | cut -f 1`.chomp
        if local_commit == remote_commit
          puts 'OK'
        else
          error 'Local and remote are not on the same commit'
        end
      end
    end
  end
end
