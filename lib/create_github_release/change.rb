# frozen_string_literal: true

module CreateGithubRelease
  # The release information needed to generate a changelog
  #
  # @api public
  #
  class Change
    # Create a new release object
    #
    # @example
    #   sha = 'f5e69d6'
    #   subject = 'Release v1.0.0'
    #
    #   change = CreateGithubRelease::Change.new(sha, subject)
    #   change.sha # => 'f5e69d6'
    #   change.subject # => 'Release v1.0.0'
    #
    # @param sha [String] The sha of the change
    # @param subject [String] The subject (aka description) of the change
    #
    def initialize(sha, subject)
      @sha = sha
      @subject = subject
    end

    # The commit sha of the change
    #
    # @example
    #   sha = 'f5e69d6'
    #   subject = 'Release v1.0.0'
    #
    #   change = CreateGithubRelease::Change.new(sha, subject))
    #   change.sha # => 'f5e69d6'
    #
    # @return [String] The commit sha of the change
    attr_reader :sha

    # The subject (aka description) of the change
    #
    # @example
    #   sha = 'f5e69d6'
    #   subject = 'Release v1.0.0'
    #
    #   change = CreateGithubRelease::Change.new(sha, subject))
    #   change.subject # => 'Release v1.0.0'
    #
    # @return [String] The subject (aka description) of the change
    attr_reader :subject

    # Compare two changes to see if they refer to the same change
    #
    # Two changes are equal if their `sha` and `subject` attributes are equal.
    #
    # @example
    #   change1 = CreateGithubRelease::Change.new('f5e69d6', 'Release v1.0.0')
    #   change2 = CreateGithubRelease::Change.new('f5e69d6', 'Release v1.0.0')
    #   change3 = CreateGithubRelease::Change.new('9387be0', 'Release v1.0.0')
    #   change4 = CreateGithubRelease::Change.new('f5e69d6', 'Release v2.0.0')
    #   change5 = CreateGithubRelease::Change.new('9387be0', 'Release v2.0.0')
    #   change1 == change2 #=> true
    #   change1 == change3 #=> false
    #   change1 == change4 #=> false
    #   change1 == change5 #=> false
    #
    # @param other [CreateGithubRelease::Change] The other change to compare this change to
    #
    # @return [Boolean] true if the two changes are equal, false otherwise
    def ==(other)
      self.class == other.class && sha == other.sha && subject == other.subject
    end
  end
end
