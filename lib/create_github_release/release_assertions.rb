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
    # @return [CreateGithubRelease::CommandLine::Options]
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

    # The assertions that must be true for a new Github release to be created
    #
    # The assertions are run in the order they are defined in this array.
    #
    # @return [Array<Class>] The assertions that must be true for a new Github release to be created
    #
    ASSERTIONS = [
      CreateGithubRelease::Assertions::GitCommandExists,
      CreateGithubRelease::Assertions::BundleIsUpToDate,
      CreateGithubRelease::Assertions::InGitRepo,
      CreateGithubRelease::Assertions::InRepoRootDirectory,
      CreateGithubRelease::Assertions::OnDefaultBranch,
      CreateGithubRelease::Assertions::NoUncommittedChanges,
      CreateGithubRelease::Assertions::NoStagedChanges,
      CreateGithubRelease::Assertions::LocalAndRemoteOnSameCommit,
      CreateGithubRelease::Assertions::LastReleaseTagExists,
      CreateGithubRelease::Assertions::LocalReleaseTagDoesNotExist,
      CreateGithubRelease::Assertions::RemoteReleaseTagDoesNotExist,
      CreateGithubRelease::Assertions::LocalReleaseBranchDoesNotExist,
      CreateGithubRelease::Assertions::RemoteReleaseBranchDoesNotExist,
      CreateGithubRelease::Assertions::GhCommandExists,
      CreateGithubRelease::Assertions::GhAuthenticated,
      CreateGithubRelease::Assertions::ReleasePrLabelExists
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
    # @raise [SystemExit] if any assertion fails
    #
    def make_assertions
      ASSERTIONS.each do |assertion_class|
        # @sg-ignore
        assertion_class.new(options).assert
      end
    end
  end
end
