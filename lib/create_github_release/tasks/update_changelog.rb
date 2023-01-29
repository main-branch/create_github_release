# frozen_string_literal: true

require 'date'
require 'English'
require 'create_github_release/release'
require 'create_github_release/task_base'

module CreateGithubRelease
  module Tasks
    # Update the changelog file with changes made since the last release
    #
    # @api public
    #
    class UpdateChangelog < TaskBase
      # Update the changelog file with changes made since the last release
      #
      # The changes since the last release are determined by using git log of all
      # changes after the previous release tag up to and including HEAD.
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::CommandLineOptions.new { |o| o.release_type = 'major' }
      #   project = CreateGithubRelease::Project.new(options)
      #   task = CreateGithubRelease::Tasks::UpdateChangelog.new(project)
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
        update_changelog
        stage_updated_changelog
      end

      private

      # Add the updated changelog to the git staging area
      # @return [void]
      # @raise [SystemExit] if the git command fails
      # @api private
      def stage_updated_changelog
        print "Staging #{project.changelog_path}..."

        `git add #{project.changelog_path}`
        if $CHILD_STATUS.success?
          puts 'OK'
        else
          error "Could not stage changes to #{project.changelog_path}"
        end
      end

      # Update the changelog file with the changes since the last release
      # @return [void]
      # @raise [SystemExit] if the file cannot be written
      # @api private
      def update_changelog
        print "Updating #{project.changelog_path}..."
        begin
          # File.open('debug.txt', 'w') { |f| f.write("CHANGELOG:\n#{project.next_release_changelog}") }
          File.write(project.changelog_path, project.next_release_changelog)
        rescue StandardError => e
          # File.open('debug.txt', 'w') { |f| f.write("#{project.changelog_path}\n\nERROR:\n#{e.message}") }
          error "Could not update #{project.changelog_path}: #{e.message}"
        end
        puts 'OK'
      end
    end
  end
end
