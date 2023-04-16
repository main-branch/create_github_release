# The create_github_release Gem

[![Gem Version](https://badge.fury.io/rb/create_github_release.svg)](https://badge.fury.io/rb/create_github_release)
 [![Build Status](https://github.com/main-branch/create_github_release/workflows/Ruby/badge.svg?branch=main)](https://github.com/main-branch/create_github_release/actions?query=workflow%3ARuby)
 [![Maintainability](https://api.codeclimate.com/v1/badges/b8c0af10b15a0ffeb1a1/maintainability)](https://codeclimate.com/github/main-branch/create_github_release/maintainability)
 [![Test Coverage](https://api.codeclimate.com/v1/badges/b8c0af10b15a0ffeb1a1/test_coverage)](https://codeclimate.com/github/main-branch/create_github_release/test_coverage)

A script to manage your gem version and create a GitHub branch, PR, and release
for a new gem version.

Since this script builds a changelog by listing the commits on the default branch,
it works best if you are disciplined about squashing PR commits to the
minimum number of commits necessary (usually one) in order to avoid a noisy changelog.

Tested on Ruby 2.7+

* [The create\_github\_release Gem](#the-create_github_release-gem)
  * [Installation](#installation)
  * [Usage](#usage)
    * [First release using this script when there were NO prior releases](#first-release-using-this-script-when-there-were-no-prior-releases)
    * [First release using this script when there were prior releases](#first-release-using-this-script-when-there-were-prior-releases)
    * [Subsequent releases using this script](#subsequent-releases-using-this-script)
  * [After Running create-github-release](#after-running-create-github-release)
  * [How the changelog is updated](#how-the-changelog-is-updated)
  * [Limitations](#limitations)
  * [Development](#development)
  * [Contributing](#contributing)
  * [License](#license)

## Installation

Add `create_github_release` as a development dependency in your project's gemspec:

```ruby
spec.add_development_dependency 'create_github_release', '~> 0.1'
```

and then install using `bundle update`.

## Usage

This gem installs the `create-guthub-release` command line tool:

```text
Usage:
create-github-release --help | RELEASE_TYPE [options]

RELEASE_TYPE must be 'major', 'minor', 'patch', or 'first'

Options:
        --default-branch=BRANCH_NAME Override the default branch
        --release-branch=BRANCH_NAME Override the release branch to create
        --remote=REMOTE_NAME         Use this remote name instead of 'origin'
        --last-release-version=VERSION
                                     Use this version instead `semverify current`
        --next-release-version=VERSION
                                     Use this version instead `semverify RELEASE_TYPE`
        --changelog-path=PATH        Use this file instead of CHANGELOG.md
    -q, --[no-]quiet                 Do not show output
    -v, --[no-]verbose               Show extra output
    -h, --help                       Show this message
```

The RELEASE_TYPE should follow [Semantic Versioning](https://semver.org) rules:

* A **major** release includes incompatible API changes
* A **minor** release includes added functionality in a backwards compatible manner
* A **patch** release includes backwards compatible bug fixes or other inconsequential changes

This script will be used for three different use cases:

### First release using this script when there were NO prior releases

If this is to be the first release of this gem follow these instructions.

For this use case, let's assume the following:

* the default branch is `main` (this is the HEAD branch returned by `git remote show origin`)
* the current version of the gem is `0.1.0` (as returned by `semverify current`)

If a different first version number is desired, update the version number in the
source code making sure that `semverify current` returns the desired version number.
Then commit the change to the default branch on the remote before running this
script.

You should start with a CHANGELOG.md that just has frontmatter. An empty file or
no file is also acceptable. It is not recommended to go with the CHANGELOG.md generated
by `bundle gem`. Here are suggested CHANGELOG.md contents prior to the first release:

```markdown
# Change Log

Changes for each release are listed in this file.

This project adheres to [Semantic Versioning](https://semver.org/) for its releases.
```

See [How the changelog is updated](#how-the-changelog-is-updated) for more information.

The following prerequisites are checked by this script:

* The current directory must be in the top level of the git repository
* The HEAD commit of the default branch (`main`) must be checked out
* The HEAD commit of the default branch of the local repository must match the
  HEAD commit of the default branch of the remote repository
* There are no uncommitted or unstaged changes
* The bundle must be up to date (the script will attempt to update the bundle if needed)
* The next-release tag (`v0.1.0`) must NOT already exist
* The next-release branch (`release-v0.1.0`) must NOT already exist
* The gh command must be installed and authenticated via `gh auth`

You should run:

```shell
create-github-release first
```

The `create-github-release` script will do the following:

* Determine the next-release version (`v0.1.0`) using `semverify current`
* Update the project's changelog file `CHANGELOG.md`
* Create a release branch `release-v0.1.0`
* Commit the changes to the changelog and create a release tag (`v0.1.0`) pointing
  to that commit
* Push the release branch to GitHub
* Create a GitHub release and pull request for the release

See [After running create-github-release](#after-running-create-github-release)
for instructions for completing your release.

### First release using this script when there were prior releases

In order to start using `create-github-release` after you have used some other
method for managing the gem version and creating releases, you need to ensure the
following prerequisites are met:

1. that `semverify current` is the version of the last release (let's use `1.3.1` as an
   example).
2. that there is a corresponding release tag that points to the last commit on the
   default branch of the previous release. If the last version was `1.3.1`, then
   the last-release tag should be `v1.3.1`.

Changes to the changelog file to ensure the next-release description is added correctly
may need to be done. See [How the changelog is updated](#how-the-changelog-is-updated)
for details.

Any changes needed to make sure these prerequisites are met should merged or pushed
to the default branch on the remote.

Once these prerequisites are met and any adjustments have been done, follow the
directions in [Subserquent releases using this script](#subsequent-releases-using-this-script).

See [After running create-github-release](#after-running-create-github-release)
for instructions for completing your release.

### Subsequent releases using this script

For this use case, let's assume the following:

* you want to create a `major` release
* the default branch is `main` (this is the HEAD branch returned by `git remote show origin`)
* the current version of the gem is `0.1.0` (as returned by `semverify current`)

The following prerequisites must be met:

* The current directory must be in the top level of the git repository
* The HEAD commit of the default branch (`main`) must be checked out
* The HEAD commit of the default branch of the local repository must match the
  HEAD commit of the default branch of the remote repository
* There are no uncommitted or unstaged changes
* The bundle must be up to date (the script will attempt to update the bundle if needed)
* The last-release tag (`v0.1.0`) must already exist
* The next-release tag (`v1.0.0`) must NOT already exist
* The next-release branch (`release-v1.0.0`) must NOT already exist
* The gh command must be installed and authenticated via `gh auth`

You should run:

```shell
create-github-release major
```

The `create-github-release` script will do the following:

* Determine the last-release version using `semverify current`
* Determine the next-release version using `semverify RELEASE_TYPE --dry-run`
* Increment the project's version using `semverify RELEASE_TYPE`
* Update the project's changelog file `CHANGELOG.md`
* Create a release branch `release-v1.0.0`
* Commit the changes to the version and changelog AND create a release tag (`v1.0.0`) pointing
  to that commit
* Push the release branch to GitHub
* Create a GitHub release and pull request for the release

See [After running create-github-release](#after-running-create-github-release)
for instructions for completing your release.

## After Running create-github-release

If you want to make additional updates to the ChangeLog or make changes as
part of the release PR, it is best to do them before running this script. If
you must make changes after running this script, you should do so in additional
commits on the release branch. Before merging to the default branch, you should
squash all commits down to ONE commit on the release branch and make sure that
the new release tag (`v1.0.0` in this example) points to this commit.

If you are happy with the PR, you should approve it in GitHub.

Next, merge the release branch into the default branch **MANUALLY AT THE COMMAND
LINE** using a fast forward merge with the following commands:

```shell
git checkout main
git merge --ff-only release-v1.0.0
git push
```

GitHub will automatically close the PR after the `git push` command. These commands
are output by `create-github-release` so you do not have to memorize them ;)

It is important to use a fast foward marge to ensure that the release tag points
to the right commit after the merge. GitHub does not allow fast forward merges when
 merging a PR.

Finally, publish your gem to rubygems.org with the `rake release` command.

## How the changelog is updated

A release description is generated by listing the commits between the last release
and the next release.

As an example, let's assume the following:

* the last release version was `0.1.0`
* the next release version will be `1.0.0`
* there were two changes in the next release:
  * The first commit has sha `1111111` and a commit message starting with the
    line 'Add feature 1'
  * The second commit has sha `2222222` and a commit message starting with the
    line 'Add feature 2'

The release description will look like this:

```text
## Release v1.0.0

Full Changelog

Changes since v0.1.0:

* 2222222 Add feature 2
* 1111111 Add feature 1
```

The existing changelog file is read and split into two parts: front matter and
body.

The front matter is everything before the first markdown H2 header. If there is
no H2 header, the entire file is considered front matter.

The body is everything else in the file (if the file contains an H2 header)

The resulting updated changelog file has the following sections:

1. front matter
2. next release description
3. body (including past release descriptions)

## Limitations

* Does not work on Windows
* Has only been tested on MRI Ruby
*

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
