# frozen_string_literal: true

require 'English'
require 'create_github_release/assertion_base'

module CreateGithubRelease
  module Assertions
    # Assert that the release tag does not exist in the local repository
    #
    # @api public
    #
    class LocalReleaseTagDoesNotExist < AssertionBase
      # Assert that the release tag does not exist in the local repository
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
      #   assertion = CreateGithubRelease::Assertions::LocalReleaseTagDoesNotExist.new(options)
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
        print "Checking that local tag '#{options.tag}' does not exist..."

        tags = `git tag --list "#{options.tag}"`.chomp
        error 'Could not list tags' unless $CHILD_STATUS.success?

        if tags == ''
          puts 'OK'
        else
          error "Local tag '#{options.tag}' already exists"
        end
      end
    end
  end
end
