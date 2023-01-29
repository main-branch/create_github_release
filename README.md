# The create_github_release Gem

[![Gem Version](https://badge.fury.io/rb/create_github_release.svg)](https://badge.fury.io/rb/create_github_release)
 [![Build Status](https://github.com/main-branch/create_github_release/workflows/Ruby/badge.svg?branch=main)](https://github.com/main-branch/create_github_release/actions?query=workflow%3ARuby)
 [![Maintainability](https://api.codeclimate.com/v1/badges/b8c0af10b15a0ffeb1a1/maintainability)](https://codeclimate.com/github/main-branch/create_github_release/maintainability)
 [![Test Coverage](https://api.codeclimate.com/v1/badges/b8c0af10b15a0ffeb1a1/test_coverage)](https://codeclimate.com/github/main-branch/create_github_release/test_coverage)

Create a GitHub release for a new gem version.

The `create-github-release` script does the following:

* Bumps the project's version
* Updates the project's changelog
* Creates a release branch
* Commits the version change and changelog update
* Creates a version tag
* Pushes the release branch to GitHub
* Creates a GitHub release and GitHub pull request for the release

You should merge the pull request once it is reviewed and approved.

Pull the changes from the default branch and publish your gem with the `rake release` command.

Here is the command line --help output:

```text
Usage:
create-github-release --help | RELEASE_TYPE [options]

RELEASE_TYPE must be 'major', 'minor', or 'patch'

Options:
        --default-branch=BRANCH_NAME Override the default branch
        --release-branch=BRANCH_NAME Override the release branch to create
        --remote=REMOTE_NAME         Use this remote name instead of 'origin'
        --last-release-version=VERSION
                                     Use this version instead `bump current`
        --next-release-version=VERSION
                                     Use this version instead `bump RELEASE_TYPE`
        --changelog-path=PATH        Use this file instead of CHANGELOG.md
    -q, --[no-]quiet                 Do not show output
    -v, --[no-]verbose               Show extra output
    -h, --help                       Show this message
```

The following conditions must be met in order to create a release:

* The bundle must be up to date (via bundle update)
* You current directory must be in the top level of the git repository
* The default branch must be checked out
* There are no uncommitted changes
* The local and remote must be on the same commit
* The last release tag must exist
* The new release tag must not already exist either locally or remotely
* The new release branch must not already exist either locally or remotely
* The gh command must be installed

## Installation

Add `create_github_release` as a development dependency in your project's gemspec:

```ruby
spec.add_development_dependency 'create_github_release', '~> 0.1'
```

and then install using `bundle update`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on
[this project's GitHub issue tracker](https://github.com/main-branch/create_github_release)

## License

The gem is available as open source under the terms of the
[MIT License](https://github.com/main-branch/create_github_release/blob/main/LICENSE.txt).
