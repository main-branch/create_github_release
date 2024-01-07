# frozen_string_literal: true

require 'English'
require 'create_github_release/task_base'

module CreateGithubRelease
  module Tasks
    # Create the release branch in git
    #
    # @api public
    #
    class CreateReleaseBranch < TaskBase
      # Create the release branch in git
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::CommandLine::Options.new { |o| o.release_type = 'major' }
      #   project = CreateGithubRelease::Project.new(options)
      #   task = CreateGithubRelease::Tasks::CreateReleaseBranch.new(project)
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
        print "Creating branch '#{project.release_branch}'..."
        `git checkout -b '#{project.release_branch}' > /dev/null 2>&1`
        if $CHILD_STATUS.success?
          puts 'OK'
        else
          error "Could not create branch '#{project.release_branch}'" unless $CHILD_STATUS.success?
        end
      end
    end
  end
end
