# frozen_string_literal: true

require 'English'
require 'create_github_release/assertion_base'

module CreateGithubRelease
  module Assertions
    # Assert that options.branch does not exist
    #
    # Checks both the local repository and the remote repository.
    #
    # @api public
    #
    class BundleIsUpToDate < AssertionBase
      # Make sure the bundle is up to date
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
      #   assertion = CreateGithubRelease::Assertions::BundleIsUpToDate.new(options)
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
        print 'Checking that the bundle is up to date...'
        if File.exist?('Gemfile.lock')
          run_bundle_update
        else
          run_bundle_install
        end
      end

      private

      # Run bundle update
      # @return [void]
      # @raise [SystemExit] if bundle update fails
      # @api private
      def run_bundle_update
        print 'Running bundle update...'
        `bundle update --quiet`
        if $CHILD_STATUS.success?
          puts 'OK'
        else
          error 'bundle update failed'
        end
      end

      # Run bundle install
      # @return [void]
      # @raise [SystemExit] if bundle update fails
      # @api private
      def run_bundle_install
        print 'Running bundle install...'
        `bundle install --quiet`
        if $CHILD_STATUS.success?
          puts 'OK'
        else
          error 'bundle install failed'
        end
      end
    end
  end
end
