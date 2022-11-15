# frozen_string_literal: true

require 'English'
require 'create_github_release/task_base'
require 'tempfile'

module CreateGithubRelease
  module Tasks
    # Create the release in Github
    #
    # @api public
    #
    class CreateGithubRelease < TaskBase
      # Create the release in Github
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
      #   task = CreateGithubRelease::Tasks::CreateGithubRelease.new(options)
      #   begin
      #     task.run
      #     puts 'Task completed successfully'
      #   rescue SystemExit
      #     puts 'Task failed'
      #   end
      #
      # @return [void]
      #
      # @raise [SystemExit] if the task fails
      #
      def run
        path = write_changelog_to_temp_file(generate_changelog)
        begin
          create_github_release(path)
        ensure
          File.unlink(path)
        end
      end

      private

      # Create the gh command to create the Github release
      # @return [String] the command to run
      # @api private
      def gh_command(default_branch, tag, changelog_path)
        "gh release create '#{tag}' " \
          "--title 'Release #{tag}' " \
          "--notes-file '#{changelog_path}' " \
          "--target '#{default_branch}'"
      end

      # Create the Github release using the gh command
      # @return [void]
      # @raise [SystemExit] if the gh command fails
      # @api private
      def create_github_release(changelog_path)
        print "Creating GitHub release '#{options.tag}'..."
        `#{gh_command(options.default_branch, options.tag, changelog_path)}`
        if $CHILD_STATUS.success?
          puts 'OK'
        else
          error 'Could not create release'
        end
      end

      # Writes the changelog to a temporary file
      # @return [void]
      # @raise [SystemExit] if a temp file could not be created
      # @api private
      def write_changelog_to_temp_file(changelog)
        begin
          f = Tempfile.create
        rescue StandardError => e
          error "Could not create a temporary file: #{e.message}"
        end
        f.write(changelog)
        f.close
        f.path
      end

      # Build the command that generates the description of the new release
      # @return [String] the command to run
      # @api private
      def docker_command(git_dir, from_tag, to_tag)
        "docker run --rm --volume '#{git_dir}:/worktree' changelog-rs '#{from_tag}' '#{to_tag}'"
      end

      # Generate the description of the new release using docker
      # @return [void]
      # @raise [SystemExit] if the docker command fails
      # @api private
      def generate_changelog
        print 'Generating changelog...'
        command = docker_command(FileUtils.pwd, options.current_tag, options.next_tag)
        `#{command}`.rstrip.lines[1..].join.tap do
          if $CHILD_STATUS.success?
            puts 'OK'
          else
            error 'Could not generate the changelog'
          end
        end
      end
    end
  end
end
