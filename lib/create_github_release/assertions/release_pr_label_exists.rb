# frozen_string_literal: true

require 'English'
require 'create_github_release/assertion_base'

module CreateGithubRelease
  module Assertions
    # Assert that the release tag does not exist in the local repository
    #
    # @api public
    #
    class ReleasePrLabelExists < AssertionBase
      # Assert that the release pr label is defined in GitHub
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major', o.release_pr_label = 'release' }
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
        return if project.release_pr_label.nil?

        print "Checking that release pr label '#{project.release_pr_label}' exists..."

        if labels.include?(project.release_pr_label)
          puts 'OK'
        else
          error "Release pr label '#{project.release_pr_label}' does not exist"
        end
      end

      private

      # Get the list of labels for the current repository from GitHub
      # @return [Array<String>] The list of labels for the current repository
      # @api private
      def labels
        output = `gh label list`
        error 'Could not list pr labels' unless $CHILD_STATUS.success?

        output.lines.map(&:chomp).map { |line| line.split("\t").first }
      end
    end
  end
end
