# frozen_string_literal: true

module CreateGithubRelease
  # Assertions used to validate that everything is ready to create the release
  #
  # @api public
  #
  module Assertions; end
end

require_relative 'assertions/bundle_is_up_to_date'
require_relative 'assertions/gh_authenticated'
require_relative 'assertions/gh_command_exists'
require_relative 'assertions/git_command_exists'
require_relative 'assertions/in_git_repo'
require_relative 'assertions/in_repo_root_directory'
require_relative 'assertions/last_release_tag_exists'
require_relative 'assertions/local_and_remote_on_same_commit'
require_relative 'assertions/local_release_branch_does_not_exist'
require_relative 'assertions/local_release_tag_does_not_exist'
require_relative 'assertions/no_staged_changes'
require_relative 'assertions/no_uncommitted_changes'
require_relative 'assertions/on_default_branch'
require_relative 'assertions/release_pr_label_exists'
require_relative 'assertions/remote_release_branch_does_not_exist'
require_relative 'assertions/remote_release_tag_does_not_exist'
