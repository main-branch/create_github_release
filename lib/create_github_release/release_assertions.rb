# frozen_string_literal: true

require 'create_github_release/assertions'

module CreateGithubRelease
  # Assertions that must be true for a new Github release to be created
  #
  # @example
  #   require 'create_github_release'
  #
  #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
  #   assertions = CreateGithubRelease::ReleaseAssertions.new(options)
  #   assertions.options # => #<CreateGithubRelease::Options:0x00007f9b0a0b0a00>
  #
  # @api public
  #
  class ReleaseAssertions
    # The options used in the assertions
    #
    # @example
    #   require 'create_github_release'
    #
    #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
    #   assertions = CreateGithubRelease::ReleaseAssertions.new(options)
    #   assertions.options # => #<CreateGithubRelease::Options:0x00007f9b0a0b0a00>
    #
    # @return [CreateGithubRelease::Options]
    attr_reader :options

    # Create a new instance of ReleaseAssertions
    #
    # @example
    #   require 'create_github_release'
    #
    #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
    #   assertions = CreateGithubRelease::ReleaseAssertions.new(options)
    #   assertions.make_assertions
    #
    def initialize(options)
      @options = options
    end

    ASSERTIONS = [
      CreateGithubRelease::Assertions::GitCommandExists,
      CreateGithubRelease::Assertions::BundleIsUpToDate,
      CreateGithubRelease::Assertions::InGitRepo,
      CreateGithubRelease::Assertions::InRepoRootDirectory,
      CreateGithubRelease::Assertions::OnDefaultBranch,
      CreateGithubRelease::Assertions::NoUncommittedChanges,
      CreateGithubRelease::Assertions::NoStagedChanges,
      CreateGithubRelease::Assertions::LocalAndRemoteOnSameCommit,
      CreateGithubRelease::Assertions::LocalReleaseTagDoesNotExist,
      CreateGithubRelease::Assertions::RemoteReleaseTagDoesNotExist,
      CreateGithubRelease::Assertions::LocalReleaseBranchDoesNotExist,
      CreateGithubRelease::Assertions::RemoteReleaseBranchDoesNotExist,
      CreateGithubRelease::Assertions::DockerIsRunning,
      CreateGithubRelease::Assertions::ChangelogDockerContainerExists,
      CreateGithubRelease::Assertions::GhCommandExists
    ].freeze

    # Run all assertions
    #
    # @example
    #   require 'create_github_release'
    #
    #   options = CreateGithubRelease::Options.new { |o| o.release_type = 'major' }
    #   assertions = CreateGithubRelease::ReleaseAssertions.new(options)
    #   assertions.make_assertions
    #
    # @return [void]
    #
    # @raises [SystemExit] if any assertion fails
    #
    def make_assertions
      ASSERTIONS.each do |assertion_class|
        assertion_class.new(options).assert
      end
    end
  end
end
