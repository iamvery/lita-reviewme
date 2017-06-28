# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [0.5.0] - 2017-06-28

### Added
- [#55] [#56] - Integration with Github Reviews

### Changed
- [#54] - Use `:default` option for configuration defaults.

## [0.4.0] - 2017-02-10

### Added
- [#50] - Allow custom GitHub messages via plugin config

### Fixed
- [#51] - Avoid empty GitHub message when there are no reviewers

## [0.3.1] - 2016-02-10

### Changed
- [#41] - Expand dependency on octokit to include v4

## [0.3.0] - 2016-02-03

### Changed
- Use Lita's handler configuration rather than ENV for GH token.

## [0.2.0] - 2016-01-29

### Added
- [#36] - Prevent assignment to review your own PR

### Changed
- Respond publicly w.r.t. private reply to `reviewers`.
- Include room name in private reply to `reviewers`.

## [0.1.0] - 2016-01-12

### Added
- Review groups are scoped to chat channels.
- This CHANGELOG :+1:

## [0.0.1] - 2016-01-12

### Added
- Start versioning gem.

[Unreleased]: https://github.com/iamvery/lita-reviewme/compare/v0.5.0...HEAD
[0.5.0]: https://github.com/iamvery/lita-reviewme/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/iamvery/lita-reviewme/compare/v0.3.1...v0.4.0
[0.3.1]: https://github.com/iamvery/lita-reviewme/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/iamvery/lita-reviewme/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/iamvery/lita-reviewme/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/iamvery/lita-reviewme/compare/v0.0.1...v0.1.0
[0.0.1]: https://github.com/iamvery/lita-reviewme/compare/a02548...v0.0.1

[#41]: https://github.com/iamvery/lita-reviewme/pull/41
[#36]: https://github.com/iamvery/lita-reviewme/pull/36
[#54]: https://github.com/iamvery/lita-reviewme/pull/54
[#55]: https://github.com/iamvery/lita-reviewme/pull/55
[#56]: https://github.com/iamvery/lita-reviewme/pull/56
