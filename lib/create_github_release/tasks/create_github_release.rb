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
      #   options = CreateGithubRelease::CommandLineOptions.new { |o| o.release_type = 'major' }
      #   project = CreateGithubRelease::Project.new(options)
      #   task = CreateGithubRelease::Tasks::CreateGithubRelease.new(project)
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
        path = write_release_description_to_tmp_file(project.next_release_description)
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
      def gh_command(default_branch, tag, tmp_path)
        "gh release create '#{tag}' " \
          "--title 'Release #{tag}' " \
          "--notes-file '#{tmp_path}' " \
          "--target '#{default_branch}'"
      end

      # Create the Github release using the gh command
      # @return [void]
      # @raise [SystemExit] if the gh command fails
      # @api private
      def create_github_release(tmp_path)
        print "Creating GitHub release '#{project.next_release_tag}'..."
        `#{gh_command(project.default_branch, project.next_release_tag, tmp_path)}`
        if $CHILD_STATUS.success?
          puts 'OK'
        else
          error 'Could not create release'
        end
      end

      # Writes the release_description to a tmp file and returns the tmp file path
      #
      # The tmp file must be deleted by the caller.
      #
      # @return [String] the path to the tmp file that was create
      # @raise [SystemExit] if a temp file could not be created
      # @api private
      def write_release_description_to_tmp_file(release_description)
        begin
          f = Tempfile.create
        rescue StandardError => e
          error "Could not create a temporary file: #{e.message}"
        end
        f.write(release_description)
        f.close
        f.path
      end
    end
  end
end
