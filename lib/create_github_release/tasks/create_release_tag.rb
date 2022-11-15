# frozen_string_literal: true

require 'English'
require 'create_github_release/task_base'

module CreateGithubRelease
  module Tasks
    # Create a release tag in git
    #
    # @api public
    #
    class CreateReleaseTag < TaskBase
      # Create a release tag in git
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
      #   task = CreateGithubRelease::Tasks::CreateReleaseTag.new(options)
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
        print "Creating tag '#{options.tag}'..."
        `git tag '#{options.tag}'`
        if $CHILD_STATUS.success?
          puts 'OK'
        else
          error "Could not create tag '#{options.tag}'"
        end
      end
    end
  end
end
