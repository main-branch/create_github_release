# frozen_string_literal: true

require 'English'
require 'create_github_release/task_base'

module CreateGithubRelease
  module Tasks
    # Create a pull request in Github with a list of changes
    #
    # @api public
    #
    class CreateReleasePullRequest < TaskBase
      # Create a pull request in Github with a list of changes
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::CommandLine::Options.new { |o| o.release_type = 'major' }
      #   project = CreateGithubRelease::Project.new(options)
      #   task = CreateGithubRelease::Tasks::CreateReleasePullRequest.new(project)
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
        tmp_path = write_pr_body_to_tmp_file
        begin
          create_release_pr(tmp_path)
        ensure
          File.unlink(tmp_path)
        end
      end

      private

      # Create the Github pull request using the gh command
      # @return [void]
      # @raise [SystemExit] if the gh command fails
      # @api private
      def create_release_pr(path)
        print 'Creating GitHub pull request...'
        tag = project.next_release_tag
        default_branch = project.default_branch
        `gh pr create --title 'Release #{tag}' --body-file '#{path}' --base '#{default_branch}'`
        if $CHILD_STATUS.success?
          puts 'OK'
        else
          error 'Could not create release pull request'
        end
      end

      # Write the changelog to a new temporary file
      # @return [String] the path to the temporary file
      # @raise [SystemExit] if the temp could not be created
      # @api private
      def write_pr_body_to_tmp_file
        begin
          f = Tempfile.create
        rescue StandardError => e
          error "Could not create a temporary file: #{e.message}"
        end
        f.write("# Release PR\n\n#{project.next_release_description}")
        f.close
        f.path
      end
    end
  end
end
