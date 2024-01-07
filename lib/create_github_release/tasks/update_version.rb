# frozen_string_literal: true

require 'English'
require 'create_github_release/task_base'

module CreateGithubRelease
  module Tasks
    # Update the gem version using semverify
    #
    # @api public
    #
    class UpdateVersion < TaskBase
      # Update the gem version using semverify
      #
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::CommandLine::Options.new { |o| o.release_type = 'major' }
      #   project = CreateGithubRelease::Project.new(options)
      #   task = CreateGithubRelease::Tasks::UpdateVersion.new(project)
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
        return if project.first_release?

        print 'Updating version...'
        increment_version
        stage_version_file
      end

      private

      # Increment the version using semverify
      # @return [void]
      # @api private
      def increment_version
        command = "semverify next-#{project.release_type}"
        command += ' --pre' if project.pre
        command += " --pre-type=#{project.pre_type}" if project.pre_type
        `#{command}`
        error 'Could not increment version' unless $CHILD_STATUS.success?
      end

      # Return the path the the version file using semverify
      # @return [String]
      # @api private
      def version_file
        output = `semverify file`
        error 'Semverify could determine the version file' unless $CHILD_STATUS.success?

        output.lines.last.chomp
      end

      # Identify the version file using semverify and stage the change to it
      # @return [void]
      # @api private
      def stage_version_file
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
