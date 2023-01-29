# frozen_string_literal: true

require 'English'
require 'create_github_release/assertion_base'

module CreateGithubRelease
  module Assertions
    # Assert that the release tag does not exist in the local repository
    #
    # @api public
    #
    class LastReleaseTagExists < AssertionBase
      # Assert that the last release tag exists in the local repository
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
      #   assertion = CreateGithubRelease::Assertions::LastReleaseTagExists.new(options)
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
        print "Checking that last release tag '#{project.last_release_tag}' exists..."

        tags = `git tag --list "#{project.last_release_tag}"`.chomp
        error 'Could not list tags' unless $CHILD_STATUS.success?

        if tags == ''
          error "Last release tag '#{project.last_release_tag}' does not exist"
        else
          puts 'OK'
        end
      end
    end
  end
end
