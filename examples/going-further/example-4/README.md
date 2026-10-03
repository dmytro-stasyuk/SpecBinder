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
target/specbinder-reports/dev/specbinder/examples/goingfurther/reporter/ShoppingCartTest.json
```

## What's in the report

The feature is crafted to exercise the listener's main code paths:

- Several plain scenarios that pass (real assertions in `ShoppingCartTest` against an in-memory `Cart`).
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

## Generation options

```java
@Gherkin2JUnitOptions(descriptionAsAnnotation = true)
```

- **`descriptionAsAnnotation = true`** emits Gherkin descriptions (Feature / Rule / Scenario) as
  runtime-retained `@Description` annotations, which the reporter surfaces as `description` fields in
  the JSON. It defaults to `false`. This feature's `Feature:` and `Rule:` blocks both carry a
  description to show it at two levels.

**`emitScenarioHash`** needs no entry above: it is on by default. It stamps each scenario with a
`@ScenarioHash` (a hash of its executable steps) for spec-drift detection, and carries the report's
verbatim Gherkin step `text` and typed `arguments` — both gated on the hash still matching the
source spec file.

## How activation works

Add `dev.specbinder:execution-reporter` as a `test`-scope dependency, then annotate the marker
class with `@ExtendWith(SpecBinderReporter.class)`. `SpecBinderReporter` is a JUnit 5 extension;
because `@ExtendWith` is `@Inherited`, placing it on the abstract marker means the concrete
`ShoppingCartTest` that JUnit runs inherits it, so one annotation covers the whole feature. The report
is named after that concrete class. Only
classes carrying the extension produce a report — every other test is left untouched.

## Class hierarchy

```
ShoppingCartFeature.java          (marker, @Gherkin2JUnit + @ExtendWith(SpecBinderReporter.class))
  └→ ShoppingCartScenarios.java   (generated, abstract — @Description and @ScenarioHash on each scenario)
      └→ ShoppingCartTest.java    (your concrete class, implements the steps — the class JUnit runs)
```

## Files

| File | Purpose |
|------|---------|
| `src/test/java/.../ShoppingCart.specb` | The spec, co-located with its marker |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class enabling the reporter and `descriptionAsAnnotation` |
| `src/test/java/.../ShoppingCartTest.java` | Concrete test implementing the steps — including the failing and aborted ones |
| `src/test/java/.../Cart.java` | Tiny in-memory cart used by the steps |

## Note on `skipped` status

This example doesn't include a `skipped` scenario because SpecBinder doesn't currently translate
a Gherkin `@disabled` tag to JUnit's `@Disabled`. The listener's `skipped`-status code path is
verified by the unit tests in the `execution-reporter` module itself.
