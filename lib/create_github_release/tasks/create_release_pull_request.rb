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
      #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
      #   task = CreateGithubRelease::Tasks::CreateReleasePullRequest.new(options)
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
        path = write_pr_body_to_temp_file(generate_changelog)
        begin
          create_release_pr(path)
        ensure
          File.unlink(path)
        end
      end

      private

      # Create the Github pull request using the gh command
      # @return [void]
      # @raise [SystemExit] if the gh command fails
      # @api private
      def create_release_pr(path)
        print 'Creating GitHub pull request...'
        tag = options.tag
        default_branch = options.default_branch
        `gh pr create --title 'Release #{tag}' --body-file '#{path}' --base '#{default_branch}'`
        if $CHILD_STATUS.success?
          puts 'OK'
        else
          error 'Could not create release pull request'
        end
      end

      # The body of the pull request
      # @return [String] the body of the pull request
      # @api private
      def pr_body(changelog)
        <<~BODY.chomp
          ## Change Log
          #{changelog}
        BODY
      end

      # Write the changelog to a new temporary file
      # @return [String] the path to the temporary file
      # @raise [SystemExit] if the temp could not be created
      # @api private
      def write_pr_body_to_temp_file(changelog)
        begin
          f = Tempfile.create
        rescue StandardError => e
          error "Could not create a temporary file: #{e.message}"
        end
        f.write(pr_body(changelog))
        f.close
        f.path
      end

      # The command to list the changes in the relese
      # @return [String] the command to run
      # @api private
      def docker_command(git_dir, from_tag, to_tag)
        "docker run --rm --volume '#{git_dir}:/worktree' changelog-rs '#{from_tag}' '#{to_tag}'"
      end

      # Generate the list of changes in the release using docker
      # @return [String] the list of changes
      # @raise [SystemExit] if the docker command fails
      # @api private
      def generate_changelog
        print 'Generating changelog...'
        command = docker_command(FileUtils.pwd, options.current_tag, options.next_tag)
        `#{command}`.rstrip.lines[1..].join.tap do
          if $CHILD_STATUS.success?
            puts 'OK'
          else
            error 'Could not generate the changelog'
          end
        end
      end
    end
  end
end
