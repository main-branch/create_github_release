# frozen_string_literal: true

require 'date'
require 'English'
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
      # @example
      #   require 'create_github_release'
      #
      #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
      #   task = CreateGithubRelease::Tasks::UpdateChangelog.new(options)
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
        current_tag = options.current_tag
        next_tag = options.next_tag
        next_tag_date = next_tag_date(next_tag)
        new_release = new_release(current_tag, next_tag, next_tag_date)
        update_changelog(existing_changelog, new_release)
        stage_updated_changelog
      end

      private

      # Add the updated changelog to the git staging area
      # @return [void]
      # @raise [SystemExit] if the git command fails
      # @api private
      def stage_updated_changelog
        print 'Staging CHANGLOG.md...'

        `git add CHANGELOG.md`
        if $CHILD_STATUS.success?
          puts 'OK'
        else
          error 'Could not stage changes to CHANGELOG.md'
        end
      end

      # Read the existing changelog file
      # @return [String] the contents of the changelog file
      # @raise [SystemExit] if the file cannot be read
      # @api private
      def existing_changelog
        @existing_changelog ||= begin
          File.read('CHANGELOG.md')
        rescue Errno::ENOENT
          ''
        end
      end

      # Find the date the release tag was created using git
      # @return [Date] the date the release tag was created
      # @raise [SystemExit] if the git command fails
      # @api private
      def next_tag_date(next_tag)
        @next_tag_date ||= begin
          print "Determining date #{next_tag} was created..."
          date = `git show --format=format:%aI --quiet "#{next_tag}"`
          if $CHILD_STATUS.success?
            puts 'OK'
            Date.parse(date)
          else
            error 'Could not stage changes to CHANGELOG.md'
          end
        end
      end

      # Build the command to list the changes since the last release
      # @return [String] the command to list the changes since the last release
      # @api private
      def docker_command(git_dir, from_tag, to_tag)
        "docker run --rm --volume '#{git_dir}:/worktree' changelog-rs '#{from_tag}' '#{to_tag}'"
      end

      # Generate the new release section of the changelog
      # @return [CreateGithubRelease::Release] the new release section of the changelog
      # @raise [SystemExit] if the docker command fails
      # @api private
      def new_release(current_tag, next_tag, next_tag_date)
        print 'Generating release notes...'
        command = docker_command(FileUtils.pwd, current_tag, next_tag)
        release_description = `#{command}`.rstrip.lines[1..].join
        if $CHILD_STATUS.success?
          puts 'OK'
          ::CreateGithubRelease::Release.new(next_tag, next_tag_date, release_description)
        else
          error 'Could not generate the release notes'
        end
      end

      # Update the changelog file with the changes since the last release
      # @return [void]
      # @raise [SystemExit] if the file cannot be written
      # @api private
      def update_changelog(existing_changelog, new_release)
        print 'Updating CHANGELOG.md...'
        changelog = ::CreateGithubRelease::Changelog.new(existing_changelog, new_release)
        begin
          File.write('CHANGELOG.md', changelog.to_s)
        rescue StandardError => e
          error "Could not write to CHANGELOG.md: #{e.message}"
        end
        puts 'OK'
      end
    end
  end
end
