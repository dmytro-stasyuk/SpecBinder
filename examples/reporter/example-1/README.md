# Example: SpecBinder Execution Reporter

This example showcases the `dev.specbinder:execution-reporter` module, which auto-registers
a JUnit Platform `TestExecutionListener` and writes one JSON file per feature under the
project's build output directory.

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

## How activation works

Adding `dev.specbinder:execution-reporter` as a `test`-scope dependency is the only step:
the listener registers itself via `META-INF/services/org.junit.platform.launcher.TestExecutionListener`
and fires automatically for any test class whose own (or parent's) class carries
`@SourceFilePath` — the marker the SpecBinder annotation processor adds to every generated
test class. Tests outside SpecBinder are ignored — no JSON file is produced for them.

## Note on `skipped` status

This example doesn't include a `skipped` scenario because SpecBinder doesn't currently translate
a Gherkin `@disabled` tag to JUnit's `@Disabled`. The listener's `skipped`-status code path is
verified by the unit tests in the `execution-reporter` module itself.
