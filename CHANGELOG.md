# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-08

### Added
- **Safe clone mechanism**: Repository now clones to a temporary directory first, only replacing the local copy after successful clone. This protects your local data if the clone fails for any reason.
- **Automatic branch restoration**: After recloning, the tool automatically checks out your original branch if it exists on the remote.
- **StandardRB linting**: Added StandardRB as a code linter with rake integration and Travis CI checks.
- **Comprehensive test suite**: Added tests for temp directory cleanup, failed clone handling, and branch restoration.
- **Modern git platform support**: Added support for Gitea and Gogs in addition to GitHub and Bitbucket.
- **Local assets**: Moved screencast from Imgur to local `assets/` folder in the repository.

### Changed
- **Updated documentation**: Changed language from "destroy" to "replace" to better reflect the safer behavior.
- **Warning messages**: Updated user-facing messages to accurately describe the safe clone-to-temp-first approach.
- **Test repository**: Switched test suite to use GitHub's official `octocat/Hello-World` repository for better reliability.
- **Branch references**: Updated from `master` to `main` to reflect modern Git conventions.
- **Constant naming**: Renamed `Version` and `Help` to `VERSION` and `HELP` to follow Ruby naming conventions.
- **Gemspec improvements**:
  - Added distinct summary and description
  - Added bounded version constraints for all dependencies
  - Improved description to highlight safety features

### Removed
- **Ronn dependency**: Removed unused documentation generation dependency.
- **Heroku references**: Replaced with modern self-hosted Git platforms (Gitea, Gogs).

### Fixed
- **Credential prompting**: Added `GIT_TERMINAL_PROMPT=0` to prevent interactive credential prompts during tests.
- **Test output**: Suppressed git clone progress output to keep test output clean.
- **All linting issues**: Fixed code style issues to comply with StandardRB.

### Security
- **Safer reclone process**: Local repository is now preserved if remote clone fails, preventing data loss.

## [0.2.3] - Previous Release
- Legacy version before major safety improvements

[1.0.0]: https://github.com/jeremywrnr/git-reclone/compare/v0.2.3...v1.0.0
