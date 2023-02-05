# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
