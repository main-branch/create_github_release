# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v2.0.0 (2024-09-18)

[Full Changelog](https://github.com/main-branch/create_github_release/compare/v1.5.0..v2.0.0)

Changes since v1.5.0:

* 639dc5c Use the command_line_boss gem for CLI parsing
* 81b10ac Use shared Rubocop config
* 7f2576a Update copyright notice in this project
* 29c7b6e Update links in gemspec
* 610f216 Add Slack badge for this project in README
* 2fb5005 Use standard badges at the top of the README
* 9386029 Update yardopts with new standard options
* 35af127 Standardize YARD and Markdown Lint configurations
* 5b0cc7b Set JRuby —debug option when running tests in GitHub Actions workflows
* ec2a239 Update continuous integration and experimental ruby builds
* f4d0e93 Depend on v1 of semver_pr_label_check

## v1.5.0 (2024-09-10)

[Full Changelog](https://github.com/main-branch/create_github_release/compare/v1.4.0..v1.5.0)

Changes since v1.4.0:

* fdc35ee Optionally apply a release label to release PRs
* c122e7f Add Semver PR Label Check workflow
* afc3883 Update to the latest version of the CodeClimate test coverage reporter
* 0a57cbd Fix test errors due to array being in different order
* 30d46fb Fix rubocop offense from new Gemspec/AddRuntimeDependency cop

## v1.4.0 (2024-05-10)

[Full Changelog](https://jcouball@github.com/main-branch/create_github_release/compare/v1.3.4..v1.4.0)

Changes since v1.3.4:

* a2e2500 Increment version with version_boss instead of semverify
* 44f8d15 Release v1.3.4 (#60)

## v1.3.4 (2024-01-09)

[Full Changelog](https://github.com/main-branch/create_github_release/compare/v1.3.3..v1.3.4)

Changes since v1.3.3:

* 23a5db6 Document the revert-github-release script in the project README (#59)
* 0ed4549 Format the output so next steps are easier to read (#58)
* 5442745 Wait for some time between creating the release PR and searching for it (#56)

## v1.3.3 (2024-01-08)

[Full Changelog](https://github.com/main-branch/create_github_release/compare/v1.3.2..v1.3.3)

Changes since v1.3.2:

* 69c7a3f Show release PR URL and other minor changes in the output. (#54)

## v1.3.2 (2024-01-08)

[Full Changelog](https://github.com/main-branch/create_github_release/compare/v1.3.1..v1.3.2)

Changes since v1.3.1:

* 6b0e295 Delete the release in GitHub and add a comment to the release PR (#52)

## v1.3.1 (2024-01-08)

[Full Changelog](https://github.com/main-branch/create_github_release/compare/v1.3.0..v1.3.1)

Changes since v1.3.0:

* 7015e17 Require create_github_release/version where the gem version is needed (#50)

## v1.3.0 (2024-01-08)

[Full Changelog](https://github.com/main-branch/create_github_release/compare/v1.2.0..v1.3.0)

Changes since v1.2.0:

* fa6ddb2 Add option to create and revert scripts to show version (#48)
* 954bea7 Add revert-github-release script (#47)
* 564267a Correctly use semverify to increment pre-release versions (#46)

## v1.2.0 (2024-01-07)

[Full Changelog](https://github.com/main-branch/create_github_release/compare/v1.1.0..v1.2.0)

Changes since v1.1.0:

* 80da449 Add support for pre-release versions (#43)

## v1.1.0 (2023-10-15)

[Full Changelog](https://github.com/main-branch/create_github_release/compare/v1.0.0..v1.1.0)

Changes since v1.0.0:

* 5088cd0 Add instruction for publishing the resulting gem (#41)
* 60553b0 Integrate solargraph:typecheck into Rake and fix any problems (#40)
* c0dd2d8 Improve reporting of code not covered by tests (#38)
* 5dff0b5 Tell rubocop development dependencies go in the gemspec (#39)
* d55f2f4 Merge pull request #37 from main-branch/debugging_support
* 4a28c4c Allow the build to continue if the Ruby head build fails
* 2814761 Add launch.json to run the ruby debugger in VS Code
* c3de36d Require 'debug' in spec_helper so `binding.break` can be used
* 3f3276d Add gems needed for debugging
* e299d97 Replace 'bump' with 'semverify' (#35)
* 68fa672 Drop support for Ruby 2.7 and require at least Ruby 3.0 (#36)

## v1.0.0 (2023-02-05)

[Full Changelog](https://github.com/main-branch/create_github_release/compare/v0.3.0..v1.0.0)

Changes since v0.3.0:

* bfd40e6 Handle the first release of a gem (#32)
* 7a76148 Release v0.3.0 (#31)

## v0.3.0 (2023-01-29)

[Full Changelog](https://github.com/main-branch/create_github_release/compare/v0.2.1..v0.3.0)

Changes since v0.2.1:

* 92ce55a Report "no changes" in the release description (#30)
* 1b3505b Assert that gh has been authenticated (#29)
* c7bd12d Complete redesign of this gem (#28)
* d75e1e9 Create release tag after committing release changes (#27)
* 24bdd02 Release v0.2.1

## v0.2.1 (2022-11-16)

[Full Changelog](https://github.com/main-branch/create_github_release/compare/v0.2.0...v0.2.1)

* 14b04ec Normalize local release branch and local release tag assertions' (#25)
* 025fa29 Refactor LocalReleaseBranchDoesNotExist#assert (#24)
* 7880c89 Further reduce the complexity of Changelog@to_s (#21)
* 2aa335e Fix high cognitive complexity of Changelog#to_s (#20)
* 42c263a Add CodeClimate badges and test coverage reporting (#19)
* 904d6cb Release v0.2.0

## v0.2.0 (2022-11-15)

[Full Changelog](https://github.com/main-branch/create_github_release/compare/v0.1.0...v0.2.0)

* 039b152 Make it so Options#default_branch does not actually run git (#17)
* 754224c Require date (#15)
* 7789a28 Do not hardcode the version file path (#14)
* 73b61bd Do not use unneeded regexps in tests (#13)
* 6fa12e5 Create the release tag before trying to create the release branch (#12)
* 819afd3 Call the right method for creating the release (#11)
* 8a0fe61 Fix error in the create-github-release script (#10)
* 6999d91 Execute the tasks from the create-github-release script (#9)
* 819b657 Add a changelog file (#8)
* 697fb95 Add 'tmp' and 'sig' directories to rake cleanup (#7)
* 993e121 Add release tasks (#6)
* a2d0b4d Add assertion to check that the git command is in the path (#5)
* c3ed55b Refactor assertions (#4)
* 0f3733e Add release assertions (#3)
* a2c00ee Add the CommandLineParser class (#2)
* 9535c0e Add the Options class (#1)

## v0.1.0 (2022-10-26)

* Initial version (976b790)
