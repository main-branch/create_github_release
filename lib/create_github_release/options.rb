# frozen_string_literal: true

require 'bump'
require 'uri'

module CreateGithubRelease
  # Captures the options for this script
  #
  # @api public
  #
  class Options
    # Initialize a new instance of Options
    #
    # @example Without a block
    #   options = Options.new
    #   options.release_type = 'minor'
    #
    # @example With a block
    #   options = Options.new do |o|
    #     o.release_type = 'minor'
    #   end
    #
    # @yield [self] an initialization block
    # @yieldparam self [Options] the instance being initialized
    # @yieldreturn [void] the return value is ignored
    #
    def initialize
      yield self if block_given?
    end

    # @!attribute [rw] branch
    #
    # The release branch based on the `next_tag`
    #
    # @example By default, `branch` is based on the tag
    #   options = Options.new
    #   options.tag = 'v1.2.3'
    #   options.branch # => 'release-v1.2.3'
    #
    # @example `branch` can be set explicitly
    #   options = Options.new
    #   options.branch = 'prod-v9.9.9'
    #   options.branch # => 'prod-v9.9.9'
    #
    # @return [String] the release branch
    #
    def branch
      @branch ||= "release-#{tag}"
    end

    # @!attribute [rw] current_tag
    #
    # The git tag of the previous release
    #
    # @example By default, `current_tag` is based on `current_version`
    #   options = Options.new
    #   options.current_version = '0.1.0'
    #   options.current_tag # => 'v0.1.0'
    #
    # @example `current_tag` can be set explicitly
    #   options = Options.new
    #   options.current_tag = 'v9.9.9'
    #   options.current_tag # => 'v9.9.9'
    #
    # @return [String] the current tag
    #
    def current_tag
      @current_tag ||= "v#{current_version}"
    end

    # @!attribute [rw] current_version
    #
    # The current version of the project's gem as determined by `Bump::Bump.current`
    #
    # @example By default, `current_version` is based on `Bump::Bump.current`
    #   options = Options.new
    #   options.current_version # => 'v0.1.0'
    #
    # @example `current_version` can be set explicitly
    #   options = Options.new
    #   options.current_version = '9.9.9'
    #   options.current_version # => '9.9.9'
    #
    # @return [String] the current version
    #
    def current_version
      @current_version ||= Bump::Bump.current
    end

    def current_version=(current_version)
      self.current_tag = self.next_version = nil
      @current_version = current_version
    end

    # @!attribute [rw] default_branch
    #
    # The default branch of the remote repository
    #
    # This is the default branch as reported by the `HEAD branch` returned by
    # `git remote show #{remote}`.
    #
    # Uses the value of `remote` to determine the remote repository to query.
    #
    # @example By default, `default_branch` is based on `git remote show`
    #   options = Options.new
    #   options.default_branch # => 'main'
    #
    # @example `default_branch` can be set explicitly
    #   options = Options.new
    #   options.default_branch = 'master'
    #   options.current_version # => 'master'
    #
    # @return [String] the default branch of the remote repository
    #
    def default_branch
      @default_branch ||= `git remote show '#{remote}'`.match(/HEAD branch: (.*?)$/)[1]
    end

    # @!attribute [rw] next_tag
    #
    # The tag to use for the next release based on `next_version`
    #
    # @example By default, `next_tag` is based on `next_version`
    #   options = Options.new
    #   options.next_version = '0.2.0'
    #   options.next_tag # => 'v0.2.0 '
    #
    # @example `next_tag` can be set explicitly
    #   options = Options.new
    #   options.next_tag = 'v9.9.9'
    #   options.next_tag # => 'v9.9.9'
    #
    # @return [String] the tag to use for the next release
    #
    def next_tag
      @next_tag ||= "v#{next_version}"
    end

    def next_tag=(next_tag)
      self.branch = self.release_url = nil
      @next_tag = next_tag
    end

    alias tag next_tag
    alias tag= next_tag=

    # @!attribute [rw] next_version
    #
    # The version of the next release
    #
    # Both `release_type` and `current_version` are used to determine the next
    # version using `Bump::Bump.next_version(release_type, current_version)`.
    #
    # @example `next_version` is determined by `release_type` and `current_version`
    #   options = Options.new
    #   options.release_type = 'major'
    #   options.current_version = '0.1.0'
    #   options.next_version # => '2.0.0'
    #
    # @example `next_version` can be set explicitly
    #   options = Options.new
    #   options.next_version = '9.9.9'
    #   options.next_version # => '9.9.9'
    #
    # @return [String] the version of the next release
    #
    def next_version
      @next_version ||= Bump::Bump.next_version(release_type, current_version)
    end

    def next_version=(next_version)
      self.tag = nil
      @next_version = next_version
    end

    # Valid values for the `release_type` attribute
    #
    VALID_RELEASE_TYPES = %w[major minor patch].freeze

    # @!attribute [rw] release_type
    #
    # The type of release to make: major, minor, or patch
    #
    # This is passed to `Bump` when determining the next version. `release_type`
    # must be set before it is read.
    #
    # Reading this attribute when it has not been explicitly set will raise a RuntimeError.
    # Writing anything by major, minor, or path will raise an ArgumentError.
    #
    # @example `release_type` can be set explicitly
    #   options = Options.new
    #   options.release_type = 'major'
    #   options.release_type # => 'major'
    #
    # @return [String] the release type
    #
    def release_type
      raise 'release_type not set. Must be major, minor, or patch' if @release_type.nil?

      @release_type
    end

    def release_type=(release_type)
      unless VALID_RELEASE_TYPES.include?(release_type)
        raise(ArgumentError, "Invalid release_type #{release_type}: must be major, minor, or patch")
      end

      self.next_version = nil
      @release_type = release_type
    end

    # @!attribute [rw] quiet
    #
    # Run the script without no or minimal output
    #
    # @example By default, `quiet` is false
    #   options = Options.new
    #   options.quiet # => false
    #
    # @example `quiet` can be set explicitly
    #   options = Options.new
    #   options.quiet = true
    #   options.quiet # => true
    #
    # @return [Boolean] the quiet flag
    #
    def quiet
      @quiet = false unless instance_variable_defined?(:@quiet)
      @quiet
    end

    # @!attribute [rw] release_url
    #
    # The address of the GitHub release notes for the next release
    #
    # `remote_url` and `next_tag` are used to determine the release URL.
    #
    # @example Given the remote_url is https://github.com/user/repo.git and `next_tag` is v0.2.0
    #   options = Options.new
    #   options.release_url # => https://github.com/user/repo/releases/tag/v1.0.0
    #
    # @example `release_url` can be set explicitly
    #   options = Options.new
    #   options.release_url = "https://github.com/user/repo/releases/tag/v9.9.9"
    #   options.release_url # => "https://github.com/user/repo/releases/tag/v9.9.9"
    #
    # @return [String] the address of the GitHub release notes for the next release
    #
    def release_url
      @release_url ||= begin
        url = remote_url.to_s.sub(/\.git$/, '')
        "#{url}/releases/tag/#{next_tag}"
      end
    end

    # @!attribute [rw] remote
    #
    # The Git remote to use to get the remote repository URL
    #
    # The default is 'origin'.
    #
    # @example The default `remote`` is origin
    #   options = Options.new
    #   options.remote # => "origin"
    #
    # @example `remote` can be set explicitly
    #   options = Options.new
    #   options.remote = 'upstream'
    #   options.remote # => "upstream"
    #
    # @return [String] the address of the GitHub release notes for the next release
    #
    def remote
      @remote ||= 'origin'
    end

    def remote=(remote)
      self.default_branch = self.remote_url = nil
      @remote = remote
    end

    # @!attribute [rw] remote_url
    #
    # The URL of the remote repository
    #
    # Uses the value of `remote` to determine the remote repository URL. This is
    # the URL reported by `git remote get-url #{remote}`.
    #
    # @example
    #   options = Options.new
    #   options.remote_url # => "https://github.com/user/repo.git"
    #
    # @example Using a different `remote`
    #   options = Options.new
    #   options.remote = 'upstream'
    #   options.remote_url # => "https://github.com/another_user/upstream_repo.git"
    #
    # @return [URI] the URL of the remote repository
    #
    def remote_url
      @remote_url ||= URI.parse(`git remote get-url '#{remote}'`.chomp)
    end

    def remote_url=(remote_url)
      self.remote_base_url = self.remote_repository = self.release_url = nil

      @remote_url = remote_url.nil? || remote_url.is_a?(URI) ? remote_url : URI.parse(remote_url)
    end

    # @!attribute [rw] remote_base_url
    #
    # The base URL of the remote repository
    #
    # This is the part of the `remote_url` excluding the path.
    #
    # @example Given the `remote_url` is https://github.com/user/repo.git
    #   options = Options.new
    #   options.remote_base_url # => "https://github.com/"
    #
    # @example `remote_base_url` can be set explicitly
    #   options = Options.new
    #   options.remote_base_url = 'https://gitlab.com/'
    #   options.remote_base_url # => "https://gitlab.com/"
    #
    # @return [String] the bsae URL of the remote repository
    #
    def remote_base_url
      @remote_base_url ||= remote_url.to_s[0..-remote_url.path.length]
    end

    # @!attribute [rw] remote_repository
    #
    # The user and repository name of the remote repository
    #
    # This is the extracted from the `remote_url`.
    #
    # @example Given the `remote_url` is https://github.com/user/repo.git
    #   options = Options.new
    #   options.remote_repository # => "user/repo"
    #
    # @example `remote_repository` can be set explicitly
    #   options = Options.new
    #   options.remote_repository = 'foo/bar'
    #   options.remote_repository # => "foo/bar"
    #
    # @return [String] the bsae URL of the remote repository
    #
    def remote_repository
      @remote_repository ||= remote_url.path.sub(%r{^/}, '').sub(/\.git$/, '')
    end

    attr_writer :branch, :current_tag, :default_branch, :quiet, :remote_base_url, :remote_repository, :release_url

    # Returns a string representation of the options
    #
    # @example
    #   # Given that:
    #   #   * the remote is 'origin'
    #   #   * the url of origin is 'http://githib.com/main-branch/create_github_release.git'
    #   #   * the default branch is 'main'
    #   #   * the current version is '0.1.0'
    #   options = Options.new { |o| o.release_type = 'major' }
    #   puts options.to_s
    #   branch='release-v1.0.0'
    #   current_tag='v0.1.0'
    #   current_version='0.1.0'
    #   default_branch='main'
    #   next_tag='v1.0.0'
    #   next_version='1.0.0'
    #   quiet=false
    #   release_type='major'
    #   remote='origin'
    #   remote_url='https://github.com/main-branch/create_github_release.git'
    #   remote_base_url='https://github.com/'
    #   remote_repository='main-branch/create_github_release'
    #
    # @return [String] a string representation of the options
    #
    def to_s
      <<~OUTPUT
        branch='#{branch}'
        current_tag='#{current_tag}'
        current_version='#{current_version}'
        default_branch='#{default_branch}'
        next_tag='#{next_tag}'
        next_version='#{next_version}'
        quiet=#{quiet}
        release_type='#{release_type}'
        remote='#{remote}'
        remote_url='#{remote_url}'
        remote_base_url='#{remote_base_url}'
        remote_repository='#{remote_repository}'
        tag='#{tag}'
      OUTPUT
    end
  end
end
