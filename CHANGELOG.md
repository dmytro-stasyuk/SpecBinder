# Changelog

All notable changes to SpecBinder will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com),
and this project adheres to [Semantic Versioning](https://semver.org).

## Unreleased

### Added

### Changed

### Fixed

### Removed

## [2026.45.0]

### Added

- Execution reporter: a Scenario Outline in the per-feature JSON report now carries a `templateSteps` array on the outline node — a single view of the outline's own steps with their `<>` placeholders intact, each entry pairing the called `methodName` with the original Gherkin `text`. A template step whose spec has a trailing DocString or DataTable also carries it as a typed `arguments` entry in template form — placeholders left unresolved, and DataTables keyed by their column headers without the runtime `columns` mapping since no row object is bound to the template. This complements the per-row `examples`, which resolve those placeholders to concrete values, so consumers can render the outline template once instead of re-deriving it from every row. Gated on the same scenario-hash match as step `text`; omitted when the hash is absent or the spec has been edited since the test was generated
- Execution reporter: a Scenario Outline in the per-feature JSON report now carries an aggregate `status` on the outline node, rolled up from its example rows worst-first — failed if any row failed, else aborted if any row aborted, else skipped if any row was skipped, else passed. Previously the outline node had no status of its own, so consumers had to derive one from the rows; an outline whose rows all passed could be shown as not-executed
- **(experimental)** New opt-in `@Gherkin2JUnitOptions(stripPatterns = {...})` option that strips matching text out of a spec file before it is turned into test code. Teams that annotate specs with revision markers tying wording back to an issue tracker — for example `<CHANGED BR-123>premium</CHANGED BR-123>` or `<REMOVED BR-789>legacy discount </REMOVED BR-789>` — previously found those markers reaching the generated code: they became part of step method names, so adding or editing a marker renamed an abstract step method and broke the hand-written test class implementing it, and they corrupted field names derived from data table headers and emitted unbalanced HTML into JavaDoc. Every match of every configured regular expression is removed, so the shape of the pattern decides what disappears: match only a marker and the text it wrapped survives, match an opening marker through a closing marker and the wrapped text goes with it. Text is stripped everywhere it can appear — step text, Feature/Rule/Scenario names, descriptions, doc strings, data tables and `Examples` tables, including header cells. A pattern may wrap whole Gherkin constructs such as several steps, an entire Scenario, or table rows; any line left holding only whitespace is dropped, so removing a table row does not leave a gap that would break the table, though this shifts the source line numbers of everything below it. Patterns are applied in the order declared, which matters when they overlap — a marker-only pattern listed first can strip the markers a wrapping pattern was relying on, so list wrapping patterns first. A match that takes all of a step’s text but leaves its keyword behind fails the build with a message naming the line; the default is an empty list, which leaves the spec file untouched

### Changed

- The `@BeforeEach` method generated from a feature-level `Background` is now named `background` (previously `featureBackground`). Rule-level background methods are unchanged (`ruleBackground`)
- Internal terminology cleanup: the annotation processor's internal identifiers and comments that still used the old "inject" wording were renamed to "resolved" (e.g. the trailing parameters propagated from a matched base step method), completing the alignment behind the earlier `@JUnitInject` → `@JUnitResolved` rename. No behavior or public API change
- **⚠️ BREAKING:** Scenario Outline example rows are now named `Example: [...]` instead of `Example 1: [...]` — the row number was dropped from the generated `@ParameterizedTest` display name, so IDE/CI test output and the `displayName` in execution reports no longer include it. Tooling that matches on the `Example N:` prefix must be updated; rows remain distinguishable by their `[argument = value, ...]` suffix

### Fixed

- Execution reporter: per-step outcomes are now captured for tests that use a per-class test-instance lifecycle (JUnit's `@TestInstance(Lifecycle.PER_CLASS)`, such as a base class with a non-static `@BeforeAll`). Previously every step in such a feature was reported as `skipped` in the JSON report even when it actually ran and passed or failed; now each step's true status, timing, and error are recorded just as they are under the default per-method lifecycle

### Removed

- **⚠️ BREAKING:** Execution reporter: the `sourceLine` field has been removed from every node of the per-feature JSON report — scenarios, Scenario Outlines, example rows and Rules. The field could only ever be populated when the generated test code carried a source-line marker, which generation does not produce, so in practice it was absent from real reports and present only in hand-written test classes. Scenarios and Rules are no longer re-sorted by source line either; they now appear in the order they executed, which for generated code is spec order. Tooling reading `sourceLine` should locate a scenario by its `scenarioHash` or its `id` instead

## [2026.44.0]

### Added

- The `@Gherkin2JUnit` path now accepts a leading `./` to anchor matching at the annotated class's own package directory instead of the classpath root — for both glob patterns (e.g. `"./**/*.feature"`) and individual files (e.g. `"./Cart.feature"`). This lets a marker class pick up the feature files sitting alongside it without repeating its full package path; generated class names and packages still mirror each matched file's real location. A `./` pattern that matches nothing reports the pattern exactly as written
- New opt-in `@Gherkin2JUnitOptions(skipUnchangedSpecs = true)` flag that skips regenerating a test class when none of its generation inputs have changed since it was last generated — cutting wasted work on incremental builds for projects with many feature files. The generator stamps each generated class with a `@SourceTimestamp` recording the newest last-modified time across the spec file, the marker class, and the marker's class hierarchy (where options typically live, so editing options forces regeneration); on a later run it re-stamps only when that value has advanced. A previously generated class that is missing or carries no recorded timestamp — for example after a clean build — always regenerates, so the optimization never leaves stale output behind. Detection follows the newest input time, so a change that does not advance it (such as a `git checkout` of an older revision) is not picked up; the default remains `false`

### Changed

- `@Gherkin2JUnitOptions(skipGenerationForTags = ...)` now keeps tagged Scenarios and Rules visible in the generated test class as skipped tests instead of omitting them entirely: the `@Test` method is still generated with its Gherkin steps rendered as a comment, and its body reports the test as skipped via `Assumptions.assumeTrue(false, ...)`; a tagged Rule's nested class is generated with each of its scenarios skipped this way. A tagged Feature generates no test class at all — the whole feature is dropped from generation. This surfaces manual or work-in-progress items as skipped in test reports rather than silently disappearing from the suite
- The `@ScenarioHash` value now ignores inter-word whitespace within a step, so steps that differ only in the number of spaces between words produce the same hash — matching the existing behavior where blank lines between steps and the step keyword (`Given`/`When`/`Then`/`And`/`But`/`*`) already have no effect. Downstream tooling comparing hashes against live source no longer sees spurious changes from cosmetic re-spacing

### Fixed

- Execution reporter: a hand-written `@BeforeEach` lifecycle method on a base or marker class (for example a `setUp()` that builds a test fixture) is no longer mistaken for a Gherkin `Background`. Only `@BeforeEach` methods on SpecBinder-generated test classes contribute background steps now, so infrastructure setup — and any non-serializable values it passes around — no longer leak into the per-feature JSON report as spurious background steps or step arguments
- Execution reporter: the per-feature JSON report is now written atomically — serialized in full, then moved into place — so a failure partway through serialization can no longer leave a truncated, unparseable report on disk. A previously written valid report survives intact, and a consumer reading the file never observes a partially written report
- Gherkin description text (under a Feature, Rule, Scenario, or Background) that contains a `*/` sequence — for example a glob pattern such as `**/*.feature` — no longer produces uncompilable generated test code. Such descriptions are rendered as a JavaDoc comment by default, and the sequence previously closed that comment early; it is now emitted so it stays inside the comment and reads as written

### Removed

## [2026.43.0]

### Added

- Execution reporter: each step in the per-feature JSON report now carries a `publishedReporterEntries` array of `TestReporter.publishEntry(...)` calls made from that step's code, each with its key, value, and timestamp — so structured per-step diagnostics flow through to downstream tooling alongside status and timing
- Execution reporter: each step in the per-feature JSON report now carries a `text` field with the original Gherkin line (keyword + spec text verbatim) for Backgrounds, scenarios, and Scenario Outline example rows — so consumers can render a readable Given/When/Then trace without re-parsing the `.feature` file; omitted when the spec has been edited since the test was generated
- Execution reporter: each entry of a step's `arguments` array now self-describes its Gherkin kind via a `{type, value}` envelope — `type` is one of `simple`, `docString`, or `dataTable`. DocString entries additionally carry the opening-fence media-type identifier (e.g. `html` from `"""html`) on a `mediaType` field. DataTable entries additionally carry a `columns` array of `{header, field}` pairs in source-file column order, so consumers know both the spec-verbatim column heading and the JSON key used in each row — useful when SpecBinder rewrites multi-word headers like `User Name` to `userName`. Gated on the same scenario-hash match as `text` stamping; on a mismatch or absent hash, `arguments` stay as today's bare runtime values
- New opt-in `@Gherkin2JUnitOptions(descriptionAsAnnotation = true)` flag that emits Gherkin description text (under Feature / Rule / Scenario / Background) as a runtime-retained `@Description("""…""")` annotation on the corresponding generated class or method — placed immediately below `@DisplayName` — instead of the default JavaDoc block, so downstream tooling can read the description at runtime via reflection. The two emission modes are mutually exclusive; the default remains JavaDoc and existing projects see no change
- Execution reporter: when `descriptionAsAnnotation` is enabled, the per-feature JSON report now carries the Gherkin description text on a new `description` field at the Feature, Rule, and Scenario level (including the Scenario Outline parent — example rows share the parent's description) — so consumers can render the full Gherkin context next to each heading without re-parsing the `.feature` file; omitted when the option is off or the element has no description
- Execution reporter: steps marked `skipped` (because an earlier step in the same scenario failed) now also carry their `arguments` array in the per-feature JSON report, populated from the parsed `.feature` / `.specb` source instead of from a runtime call — so consumers can render the same DocString body, DataTable rows, and quoted inline values they would have seen had the step actually run. Excludes Scenario Outline example rows, whose spec text carries `<placeholder>` tokens rather than per-example values; gated on the same scenario-hash match as `text` stamping
- DocStrings that would exceed the JVM's per-string-literal byte limit (65535 bytes for one constant-pool entry) are now automatically emitted as multiple plain string-literal chunks joined at runtime via `String.join("", …)`, so generated test classes compile even when an individual DocString — e.g. a base64-encoded fixture or snapshot image — is very large. The `+` operator can't serve this purpose because javac compile-time-folds adjacent string-literal `+` expressions back into a single constant-pool entry; `String.join` defers concatenation to runtime so each chunk stays its own constant. Below the configurable cap the existing single Java text-block emission is preserved unchanged. A new `@Gherkin2JUnitOptions(maxStringLiteralBytes = N)` option configures the cap (default 65000, just under the JVM hard limit); tests can lower it to exercise the chunking with small inputs

### Changed

- **⚠️ BREAKING:** The `@JUnitInject` marker annotation has been renamed to `@JUnitResolved`, aligning with JUnit's own "parameter resolution" terminology (its `ParameterResolver` extension point) rather than implying dependency injection. Its behavior is unchanged — mark a custom resolver-supplied step-method parameter, or its type, so the parameter is propagated to the generated test method. Update any `import dev.specbinder.annotations.JUnitInject;` and `@JUnitInject` usages to the new name
- Class-level `@DisplayName` on the generated test class now reflects the Feature title line (e.g., `Feature: Shopping Cart`) instead of the annotated class name, matching the convention already used for `Rule:` and `Scenario:` `@DisplayName` values; when `addSourceLineNumbers` is enabled the line number is included as `Feature [N]: ...`. The class-level JavaDoc now contains only the feature description lines and is omitted entirely when the feature has no description, so reports and generated code read consistently with the Gherkin source
- Execution reporter: the per-feature JSON report's top-level `displayName` now reflects the Gherkin Feature title regardless of whether SpecBinder runs in concrete or abstract generation mode — in abstract mode the reporter now walks the JUnit test class's superclass chain to read the generated class's `@DisplayName` rather than falling back to the user-written concrete subclass's simple name
- Execution reporter: the per-feature JSON report's `generatedClass` field has been renamed to `testClass`, to accurately reflect that it names the test class that was actually run — which is not always the same as the generated class
- Execution reporter: per-feature JSON report's `schemaVersion` bumped from 6 to 8 to reflect the new typed-arguments envelope shape and the renamed `testClass` field
- **⚠️ BREAKING:** The default value of `@Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = ...)` has been flipped from `true` to `false`. By default the generator now matches existing step implementations in the base/marker class by method name only, ignoring `@Given`/`@When`/`@Then` annotation values. Projects that relied on annotation-pattern matching — typically when migrating from Cucumber and keeping descriptive method names — must now opt back in with `@Gherkin2JUnitOptions(useCucumberAnnotationsForStepMatching = true)`, otherwise those steps will no longer be recognised as implemented and will be (re)generated

### Fixed

- Execution reporter: per-step `arguments` no longer accumulate nested `{type, value, …}` wrappers when the feature has Gherkin Rules — previously each Rule's `@Nested` JUnit class triggered an extra finalisation pass that re-wrapped the already-wrapped arguments, producing JSON like `value: {type: docString, value: {type: docString, value: …}}` with depth equal to (number of Rules + 1)

### Removed

## [2026.42.0]

### Added

- Propagation of JUnit 5's built-in injected parameters (`TestInfo`, `TestReporter`, `@TempDir Path` / `@TempDir File`) from base step methods through to the generated `@Test` / `@BeforeEach` / `@ParameterizedTest` methods — declared on the step method signature in the base/marker class, they are auto-forwarded on the step call and aggregated (deduplicated by name) across all steps of the enclosing scenario or background, with `@TempDir` and any other parameter annotations preserved verbatim on the generated method parameter
- New `@JUnitInject` marker annotation (`@Target({PARAMETER, TYPE})`) that extends the same propagation to custom user-defined types resolved by a JUnit `ParameterResolver` — placed on the parameter directly or once on the type's class declaration; works in concrete and abstract generation modes, in scenarios, scenario outlines, and backgrounds; all non-`@JUnitInject` annotations on the source parameter are preserved verbatim so the user's resolver can observe them at runtime

### Changed

### Fixed

### Removed

## [2026.41.0]

### Added

### Changed

### Fixed

### Removed

## [2026.40.0]

### Added

### Changed

### Fixed

### Removed

## [2026.39.0]

### Added

- Automatic wrapping of Gherkin values in a domain value object's static factory method when the target parameter or DataTable column maps to a non-enum custom type — covers quoted step parameters and `LIST_OF_OBJECT_PARAMS` cell values, including overload disambiguation by inferred value type with a unique-`String`-factory fallback

### Changed

- Default value of `@Gherkin2JUnitOptions.shouldBeAbstract` flipped from `false` to `true`, making abstract test class generation the new default — opt back into concrete generation with `@Gherkin2JUnitOptions(shouldBeAbstract = false)`

### Fixed

### Removed

## [2026.38.0]

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
