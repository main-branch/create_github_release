# frozen_string_literal: true

require 'English'

module CreateGithubRelease
  module Assertions
    # Assert that the release tag does not exist
    #
    # Checks both the local repository and the remote repository.
    #
    # @api public
    #
    class ReleaseTagDoesNotExist < AssertionBase
      # Assert that the release tag does not exist
      #
      # Checks both the local repository and the remote repository.
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
      #   assertion = CreateGithubRelease::Assertions::ReleaseTagDoesNotExist.new(options)
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
        local_tag_does_not_exist
        remote_tag_does_not_exist
      end

      private

      # Assert that the release branch does not exist locally
      # @return [void]
      # @raise [SystemExit] if bundle update fails
      # @api private
      def local_tag_does_not_exist
        print "Checking that local tag '#{options.tag}' does not exist..."

        tags = `git tag --list "#{options.tag}"`.chomp
        error 'Could not list tags' unless $CHILD_STATUS.success?

        if tags.split.empty?
          puts 'OK'
        else
          error "Local tag '#{options.tag}' already exists"
        end
      end

      # Assert that the release branch does not exist remotely
      # @return [void]
      # @raise [SystemExit] if bundle update fails
      # @api private
      def remote_tag_does_not_exist
        print "Checking that the remote tag '#{options.tag}' does not exist..."
        `git ls-remote --tags --exit-code '#{options.remote}' #{options.tag} >/dev/null 2>&1`
        if $CHILD_STATUS.success?
          error "Remote tag '#{options.tag}' already exists"
        else
          puts 'OK'
        end
      end
    end
  end
end
