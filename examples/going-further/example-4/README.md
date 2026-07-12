# Example 4: SpecBinder Execution Reporter

This example showcases the `dev.specbinder:execution-reporter` module — a JUnit 5 extension that
writes one JSON file per feature under the project's build output directory. It is activated
explicitly by annotating the marker class with `@ExtendWith(SpecBinderReporter.class)`.

## Run it

```bash
mvn test
```

After the run, look at:

```
target/specbinder-reports/specs/ShoppingCart.feature.json
```

## What's in the report

The feature is crafted to exercise the listener's main code paths:

- Several plain scenarios that pass (real assertions against an in-memory `Cart`).
- One scenario that intentionally asserts the wrong total → `status: "failed"`, `error` block populated.
- One scenario whose `Given` step calls `Assumptions.abort(...)` → `status: "aborted"`.
- A `Rule` with two scenarios → routed under the report's `rules[]` branch.
- A `Scenario Outline` with three example rows → represented as a `scenarioOutline` node with
  three entries inside `examples[]`, each carrying its own `examplesRow` map.

The schema is hierarchical:

```text
feature
├── scenarios[]   ← plain scenarios + Scenario Outlines under the feature directly
└── rules[]
    └── scenarios[]   ← scenarios that live under a Rule
```

Every node — feature, rule, scenario, outline, example — uses the same `displayName` field name.

## Enriching the report

The marker enables two generation options that make the report carry more than statuses and timings:

```java
@Gherkin2JUnitOptions(emitScenarioHash = true, descriptionAsAnnotation = true)
```

- **`emitScenarioHash = true`** stamps each scenario with a `@ScenarioHash` (a hash of its executable
  steps) for spec-drift detection, and unlocks the report's verbatim Gherkin step `text` and typed
  `arguments` — both gated on the hash still matching the source `.feature`.
- **`descriptionAsAnnotation = true`** emits Gherkin descriptions (Feature / Rule / Scenario) as
  runtime-retained `@Description` annotations, which the reporter surfaces as `description` fields in
  the JSON. This feature's `Feature:` and `Rule:` blocks both carry a description to show it at two levels.

## How activation works

Add `dev.specbinder:execution-reporter` as a `test`-scope dependency, then annotate the marker
class with `@ExtendWith(SpecBinderReporter.class)`. `SpecBinderReporter` is a JUnit 5 extension;
because `@ExtendWith` is `@Inherited`, placing it on the abstract marker means every generated
`…Scenarios` subclass JUnit runs inherits it, so one annotation covers the whole feature. Only
classes carrying the extension produce a report — every other test is left untouched.

## Note on `skipped` status

This example doesn't include a `skipped` scenario because SpecBinder doesn't currently translate
a Gherkin `@disabled` tag to JUnit's `@Disabled`. The listener's `skipped`-status code path is
verified by the unit tests in the `execution-reporter` module itself.
