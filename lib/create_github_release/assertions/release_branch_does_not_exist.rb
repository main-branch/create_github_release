# frozen_string_literal: true

require 'English'

module CreateGithubRelease
  module Assertions
    # Assert that the release branch does not exist
    #
    # Checks both the local repository and the remote repository.
    #
    # @api public
    #
    class ReleaseBranchDoesNotExist < AssertionBase
      # Assert that the release branch does not exist
      #
      # Checks both the local repository and the remote repository.
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
      #   assertion = CreateGithubRelease::Assertions::ReleaseBranchDoesNotExist.new(options)
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
        assert_does_not_exist_locally
        assert_does_not_exist_remotely
      end

      private

      # Assert that the release branch does not exist locally
      # @return [void]
      # @raise [SystemExit] if bundle update fails
      # @api private
      def assert_does_not_exist_locally
        print "Checking that local branch ' #{options.branch}' does not exist..."

        if `git branch --list '#{options.branch}' | wc -l`.to_i.zero? && $CHILD_STATUS.success?
          puts 'OK'
        else
          error "'#{options.branch}' already exists."
        end
      end

      # Assert that the release branch does not exist remotely
      # @return [void]
      # @raise [SystemExit] if bundle update fails
      # @api private
      def assert_does_not_exist_remotely
        print "Checking that the remote branch '#{options.branch}' does not exist..."
        `git ls-remote --heads --exit-code '#{options.remote}' '#{options.branch}' >/dev/null 2>&1`
        if $CHILD_STATUS.success?
          error "'#{options.branch}' already exists"
        else
          puts 'OK'
        end
      end
    end
  end
end
