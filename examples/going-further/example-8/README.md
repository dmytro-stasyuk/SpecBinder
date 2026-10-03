# Example 8: One Playwright Trace per Gherkin Step

Browser tests fail for reasons a stack trace rarely explains. This example wires
[Playwright](https://playwright.dev)'s tracing to SpecBinder's execution boundaries so every Gherkin
step gets **its own self-contained trace zip** — screenshots, DOM snapshots, network, console — and
the path to that zip is stamped onto the step in the JSON execution report.

The payoff: open the spec in IntelliJ, click a step, and watch that step replay.

## Run it

```bash
mvn test
```

The first run downloads a Chromium build if you have none. If Playwright reports a missing browser:

```bash
mvn exec:java -e -Dexec.mainClass=com.microsoft.playwright.CLI -Dexec.args="install chromium"
```

One scenario fails on purpose — a step that expects the wrong total — because the trace of a red
step is the interesting one. `testFailureIgnore` keeps the build green anyway.

## What you get

```text
target/
├── playwright-traces/
│   ├── scenario_2/
│   │   ├── 01_iOpenTheCartPage.zip
│   │   ├── 02_iAdd$p1ToTheCart.zip
│   │   └── 03_theCartTotalShouldBe$p1.zip
│   ├── scenario_6_ex_01/          ← Scenario Outline rows get their own folder per row
│   └── …
└── specbinder-reports/dev/specbinder/examples/goingfurther/playwrighttrace/CartTraceTest.json
```

25 zips for 8 scenarios. Open any one of them:

```bash
npx playwright show-trace target/playwright-traces/scenario_5/03_theCartTotalShouldBe\$p1.zip
```

That is the step that failed, and the trace shows the cart reading `0.75` while the step asserted
`99.99`.

## How it fits together

```text
SpecBinderReporter  ──raises──>  ExecutionBoundaryListener
                                        │
                                        │  scenarioStarted / stepStarted / stepFinished
                                        ▼
                              PlaywrightTraceListener
                                   │            │
                    startChunk/    │            │   recordPublishedEntry(
                    stopChunk ─────┘            └──   "specbinder.playwright.trace" → path)
                         │                                    │
                         ▼                                    ▼
              one zip per step                    the step's entry in the JSON report
```

Four classes and the spec, and only one of them is really about tracing:

| File | Role |
|------|------|
| `PlaywrightTraceListener` | **The integration.** Implements `ExecutionBoundaryListener`; opens a trace chunk per step and records its path onto the report. |
| `PlaywrightTracing` | Ordinary JUnit extension: launches Chromium, starts one trace for the feature, registers the listener. |
| `CartTraceFeature` | The marker class: registers both extensions; `@Inherited`, so they cover the concrete test. |
| `CartTraceTest` | The concrete test, with step methods that drive the bundled `web/cart.html`. |
| `CartTrace.specb` | The spec, co-located with its marker in `src/test/java`. |

```
CartTraceFeature.java          (marker, @Gherkin2JUnit + @ExtendWith(SpecBinderReporter, PlaywrightTracing))
  └→ CartTraceScenarios.java   (generated, abstract)
      └→ CartTraceTest.java    (your concrete class, implements the steps — the class JUnit runs)
```

### The two moving parts

**Chunked tracing.** `tracing().start(...)` runs once per feature. Each step is then a
`startChunk()` / `stopChunk(setPath(zip))` pair inside that one recording, so each zip is a complete,
independently-openable trace rather than a slice you have to scrub to.

**A shared key.** The report entry uses `ExecutionBoundaryListener.PLAYWRIGHT_TRACE_ENTRY_KEY`
(`"specbinder.playwright.trace"`), a constant the reporter module defines so that this producer and
its consumers — notably the SpecBinder IntelliJ plugin — agree on one name instead of duplicating a
magic string across repositories.

### One ordering rule that matters

`recordPublishedEntry` attaches to whichever step is **in flight**, and the reporter has already
cleared that by the time `stepFinished` runs. So the path is recorded at `stepStarted`, before the
zip exists:

```java
@Override
public void stepStarted(StepBoundary step) {
    currentChunk = baseDir.resolve(scenarioFolder)
            .resolve(String.format("%02d_%s.zip", ++stepOrdinal, step.methodName()));

    SpecBinderReporter.recordPublishedEntry(
            Map.of(PLAYWRIGHT_TRACE_ENTRY_KEY, currentChunk.toString()), Instant.now());

    browserContext.tracing().startChunk();
}
```

`stopChunk` writes the file moments later, long before anything reads the report.

## In the report

Each step carries its trace alongside its outcome. The failing step, in full:

```json
{
  "methodName" : "theCartTotalShouldBe$p1",
  "text" : "Then the cart total should be \"99.99\"",
  "arguments" : [ { "type" : "simple", "value" : 99.99 } ],
  "status" : "failed",
  "error" : {
    "message" : "Locator expected to have text: 99.99\nReceived: 0.75",
    "expected" : "99.99",
    "actual" : "0.75"
  },
  "publishedReporterEntries" : [ {
    "values" : {
      "specbinder.playwright.trace" : "target/playwright-traces/scenario_5/03_theCartTotalShouldBe$p1.zip"
    }
  } ]
}
```

The verbatim `text` and typed `arguments` come free with `emitScenarioHash`, which is on by default.

## In the IDE

With the SpecBinder IntelliJ plugin installed and *Extra data* enabled on the editor toolbar, opening
`CartTrace.specb` after a run shows a collapsed row under each traced step:

```text
✓ Then the cart total should be "99.99"
  │ ▸ Playwright trace — 03_theCartTotalShouldBe$p1.zip  ↗
```

Clicking the file name expands Playwright's viewer inline; the `↗` hands the zip to
`trace.playwright.dev` over a loopback address, so the recording never leaves your machine.

## Naming

Chunk paths come from `ScenarioBoundary`:

- `testMethodName()` is already rule-qualified and unique within the class (e.g. `rule_1_scenario_2`),
  so it needs no separate rule segment.
- Scenario Outline rows share one method name, so `exampleRowIndex()` (1-based) is appended as
  `_ex_NN`.

## Scaling up

`PlaywrightTraceListener` holds its scenario folder, step counter and in-flight chunk in plain
fields, which assumes **one feature recording at a time** — true here, and true of any sequential
suite. If you run test classes concurrently, move that state into a `ThreadLocal` keyed per thread,
or chunks from different features will interleave into the wrong trace.
