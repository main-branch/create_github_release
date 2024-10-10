# frozen_string_literal: true

require 'English'
require 'create_github_release/task_base'

module CreateGithubRelease
  module Tasks
    # Commit the files added for the release
    #
    # @api public
    #
    class CommitRelease < TaskBase
      # Commit the files added for the release
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::CommandLine::Options.new { |o| o.release_type = 'major' }
      #   project = CreateGithubRelease::Project.new(options)
      #   task = CreateGithubRelease::Tasks::CommitRelease.new(project)
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
        print 'Making release commit...'
        `git commit -s -m 'chore: release #{project.next_release_tag}'`
        if $CHILD_STATUS.success?
          puts 'OK'
        else
          error 'Could not make release commit'
        end
      end
    end
  end
end
