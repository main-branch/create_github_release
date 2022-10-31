# frozen_string_literal: true

require 'English'
require 'tmpdir'

module CreateGithubRelease
  module Assertions
    # Assert that the changelog docker container exists
    #
    # @api public
    #
    class ChangelogDockerContainerExists < AssertionBase
      # Make sure the changelog docker container exists
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
      #   assertion = CreateGithubRelease::Assertions::ChangelogDockerContainerExists.new(options)
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
        Dir.mktmpdir do |dir|
          @dir = dir
          @docker_file = "#{dir}/Dockerfile"
          File.write(@docker_file, DOCKERFILE)
          assert_changelog_docker_container_exists
        end
      end

      private

      # Create the changelog docker container
      # @return [void]
      # @raise [SystemExit] if docker build fails
      # @api private
      def assert_changelog_docker_container_exists
        print 'Checking that the changelog docker container exists (might take time to build)...'
        `docker build --file "#{@docker_file}" --tag changelog-rs . 1>/dev/null 2>#{@dir}/stderr`
        if $CHILD_STATUS.success?
          puts 'OK'
        else
          error 'Failed to build the changelog-rs docker container'
        end
      end

      DOCKERFILE = <<~CONTENTS
        FROM rust

        # Build the docker image (from this project's root directory):
        # docker build --file Dockerfile.changelog-rs --tag changelog-rs .
        #
        # Use this image to output a changelog (from this project's root directory):
        # docker run --rm --volume "$PWD:/worktree" changelog-rs v1.9.1 v1.10.0

        RUN cargo install changelog-rs
        WORKDIR /worktree

        ENTRYPOINT ["/usr/local/cargo/bin/changelog-rs", "/worktree"]
      CONTENTS
    end
  end
end
