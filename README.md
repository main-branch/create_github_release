# The create_github_release Gem

Create a GitHub release for a new gem version.

To create a new GitHub release for a gem, run the following from the top level
project directory with the default branch selected:

```shell
create-github-release [major|minor|patch]
```

The following conditions must be met in order to create a release:

* The bundle must be up to date (via bundle update)
* You current directory must be in the top level of the git repository
* The default branch must be checked out
* There are no uncommitted changes
* The local and remote must be on the same commit
* The new release tag must not already exist either locally or remotely
* The new release branch must not already exist either locally or remotely
* Docker must be running
* The changelog docker container must already exist or be able to be built
* The gh command must be installed

The result of running this command is:
* A new release branch is created
* CHANGELOG.md is updated with a list of PRs since the last release
* The Gem version is updated via Bump
* The CHANGELOG.md and version changes are committed and tagged on the new release branch
* The new release branch is pushed to the remote
* A release is created on GitHub
* A release PR is created on GitHub

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

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push git
commits and the created tag, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on
[this project's GitHub issue tracker](https://github.com/main-branch/create_github_release)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
