# frozen_string_literal: true

require 'create_github_release/tasks'

module CreateGithubRelease
  # Tasks that must be run to create a new Github release.
  #
  # @example
  #   require 'create_github_release'
  #
  #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
  #   tasks = CreateGithubRelease::ReleaseTasks.new(options)
  #   tasks.run
  #
  # @api public
  #
  class ReleaseTasks
    # The options used to create the Github release
    #
    # @example
    #   require 'create_github_release'
    #
    #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
    #   tasks = CreateGithubRelease::ReleaseTasks.new(options)
    #   tasks.options # => #<CreateGithubRelease::Options:0x00007f9b0a0b0a00>
    #
    # @return [CreateGithubRelease::Options]
    attr_reader :options

    # Create a new instance of ReleaseTasks
    #
    # @example
    #   require 'create_github_release'
    #
    #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
    #   tasks = CreateGithubRelease::ReleaseTasks.new(options)
    #   tasks.run
    #
    def initialize(options)
      @options = options
    end
    # The tasks that will be run to create a new Github release
    #
    # The tasks are run in the order they are defined in this array.
    #
    # @return [Array<Class>] The tasks that will be run to create a new Github release
    #
    TASKS = [
      CreateGithubRelease::Tasks::CreateReleaseBranch,
      CreateGithubRelease::Tasks::UpdateChangelog,
      CreateGithubRelease::Tasks::UpdateVersion,
      CreateGithubRelease::Tasks::CommitRelease,
      CreateGithubRelease::Tasks::CreateReleaseTag,
      CreateGithubRelease::Tasks::PushRelease,
      CreateGithubRelease::Tasks::CreateGithubRelease,
      CreateGithubRelease::Tasks::CreateReleasePullRequest
    ].freeze

    # Run all tasks to create a new Github release
    #
    # @example
    #   require 'create_github_release'
    #
    #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
    #   tasks = CreateGithubRelease::ReleaseTasks.new(options)
    #   tasks.run
    #
    # @return [void]
    #
    # @raise [SystemExit] if any task fails
    #
    def run
      TASKS.each do |task_class|
        task_class.new(options).run
      end
    end
  end
end
