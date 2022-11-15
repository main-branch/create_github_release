# frozen_string_literal: true

require 'English'
require 'create_github_release/task_base'

module CreateGithubRelease
  module Tasks
    # Update the gem version using Bump
    #
    # @api public
    #
    class UpdateVersion < TaskBase
      # Update the gem version using Bump
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
      #   task = CreateGithubRelease::Tasks::UpdateVersion.new(options)
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
        print 'Updating version...'
        message, result = Bump::Bump.run(options.release_type, commit: false)
        error "Could not bump version: #{message}" unless result.zero?

        version_file = Bump::Bump.file
        `git add "#{version_file}"`
        if $CHILD_STATUS.success?
          puts 'OK'
        else
          error "Could not stage changes to #{version_file}"
        end
      end
    end
  end
end
