# Changelog

All notable changes to SpecBinder will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com),
and this project adheres to [Semantic Versioning](https://semver.org).

## Unreleased

### Added

- Execution reporter: a JUnit 5 extension that captures hierarchical execution results (feature, rule, scenario, step) and writes per-feature JSON reports to `target/specbinder-reports/`
- Step-level reporting via ByteBuddy bytecode instrumentation — intercepts step method calls at runtime to track individual step status, timing, and errors without requiring source-level changes
- Bytecode call-site scanner that discovers ordered step method sequences from generated test class bytecode

### Changed

- Scenario test methods inside rule nested classes are now named `rule_N_scenario_M` instead of `scenario_M` to include the rule index prefix

### Fixed

- DataTable object type naming when step text ends with non-alphanumeric characters (e.g., `"Given the following reports :"` with a trailing space before the colon)

### Removed

## [2026.37.0]

### Added

### Changed

- automated tests setup
- Simplified GitHub Release creation step in the release workflow

### Fixed

### Removed

## [2026.34.0]

### Added

### Changed

### Fixed

### Removed

## [2026.33.0]

### Added

### Changed

- Upgraded GitHub Actions to v5 to resolve Node.js 20 deprecation warnings

### Fixed

- Excluded auto-generated source code archives from GitHub Releases

### Removed

## [2026.32.0]

### Added

### Changed

- Upgraded GitHub Actions to v5 to resolve Node.js 20 deprecation warnings

### Fixed

- Excluded auto-generated source code archives from GitHub Releases

### Removed

## [2026.31.0]

### Added

### Changed

### Fixed

- Fixed GitHub Release creation failing due to shell interpretation of backticks in changelog notes

### Removed

## [2026.30.0]

### Added

- Support for escaping spaces and backslashes inside DocString step argument types

### Changed

- Adopted calendar year as the major version in the versioning scheme (e.g., `2026.30.0`)
- Excluded source code archives from GitHub Releases

### Fixed

### Removed

## [0.29.0]

### Added

### Changed

### Fixed

- Fixed release profile running on child modules by adding `inherited=false`

### Removed

## [0.28.0]

### Added

- Support for escaping spaces and backslashes in Gherkin elements
- Automated release workflow via GitHub Actions triggered by `rc` tag push
- Changelog stamping as part of the release process

### Changed

- Moved to automated versioning process with minor version increments

### Fixed

### Removed
