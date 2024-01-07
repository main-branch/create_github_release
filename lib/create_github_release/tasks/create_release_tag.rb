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
      #   options = CreateGithubRelease::CommandLine::Options.new { |o| o.release_type = 'major' }
      #   project = CreateGithubRelease::Project.new(options)
      #   task = CreateGithubRelease::Tasks::CreateReleaseTag.new(project)
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
        print "Creating tag '#{project.next_release_tag}'..."
        `git tag '#{project.next_release_tag}'`
        if $CHILD_STATUS.success?
          puts 'OK'
        else
          error "Could not create tag '#{project.next_release_tag}'"
        end
      end
    end
  end
end
