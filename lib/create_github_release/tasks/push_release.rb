# frozen_string_literal: true

require 'English'
require 'create_github_release/task_base'

module CreateGithubRelease
  module Tasks
    # Push the release branch and tag to Github
    #
    # @api public
    #
    class PushRelease < TaskBase
      # Push the release branch and tag to Github
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
      #   task = CreateGithubRelease::Tasks::PushRelease.new(options)
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
        print "Pushing branch '#{options.branch}' to remote..."
        `git push --tags --set-upstream '#{options.remote}' '#{options.branch}' > /dev/null 2>&1`
        if $CHILD_STATUS.success?
          puts 'OK'
        else
          error 'Could not push release commit'
        end
      end
    end
  end
end
