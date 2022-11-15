# frozen_string_literal: true

module CreateGithubRelease
  # Tasks/commands used to creat the Github release
  #
  # @api public
  #
  module Tasks; end
end

require_relative 'tasks/commit_release'
require_relative 'tasks/create_github_release'
require_relative 'tasks/create_release_branch'
require_relative 'tasks/create_release_pull_request'
require_relative 'tasks/create_release_tag'
require_relative 'tasks/push_release'
require_relative 'tasks/update_changelog'
require_relative 'tasks/update_version'
