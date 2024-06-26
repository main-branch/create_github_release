# frozen_string_literal: true

require_relative 'lib/create_github_release/version'

Gem::Specification.new do |spec|
  spec.name = 'create_github_release'
  spec.version = CreateGithubRelease::VERSION
  spec.authors = ['James']
  spec.email = ['jcouball@yahoo.com']

  spec.summary = 'A script to create a GitHub release for a Ruby Gem'
  spec.description = <<~DESCRIPTION
    A script that manages your gem version and creates a GitHub branch, PR, and
    release for a new gem version.
  DESCRIPTION
  spec.homepage = 'https://github.com/main-branch/create_github_release'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "https://rubydoc.info/gems/#{spec.name}/#{spec.version}/file/CHANGELOG.md"
  spec.metadata['documentation_uri'] = "https://rubydoc.info/gems/#{spec.name}/#{spec.version}"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'version_boss', '~> 0.1'

  spec.add_development_dependency 'bundler-audit', '~> 0.9'
  spec.add_development_dependency 'debug', '~> 1.9'
  spec.add_development_dependency 'rake', '~> 13.2'
  spec.add_development_dependency 'redcarpet', '~> 3.6'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'rubocop', '~> 1.63'
  spec.add_development_dependency 'simplecov', '~> 0.22'
  spec.add_development_dependency 'simplecov-lcov', '~> 0.8'
  spec.add_development_dependency 'timecop', '~> 0.9'
  spec.add_development_dependency 'yard', '~> 0.9'
  spec.add_development_dependency 'yardstick', '~> 0.9'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html

  spec.metadata['rubygems_mfa_required'] = 'true'
end
