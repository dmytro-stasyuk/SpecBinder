# Example 2: JUnit Parameter Resolution in Step Methods

Demonstrates how step methods can receive parameters filled by JUnit's parameter resolution at test execution time — both JUnit's built-in resolvers and custom user-registered `ParameterResolver`s opted in via the `@JUnitResolved` marker annotation.

## What this demonstrates

- **Built-in implicit resolution** — `@TempDir Path` (per-test temporary directory) and `TestInfo` (test metadata) are recognized by the generator without any marker
- **Custom resolver** — a `Clock` filled by `FixedClockResolver` is opted in with `@JUnitResolved` on the parameter
- **Mixing on a single step** — one step method has a Gherkin-derived parameter plus both built-in and custom resolved parameters
- **Aggregation across steps** — the generated `@Test scenario_1` method receives the union (deduplicated) of every resolved parameter required by any of the scenario's steps
- **Annotation passthrough** — `@TempDir` is preserved on the generated parameter so JUnit's resolver fires; `@JUnitResolved` is a SpecBinder-internal marker and is stripped

## Why each resolved type is used here

| Type | Why |
|------|-----|
| `@TempDir Path` | Each test gets a fresh receipt output directory, so file assertions never collide between tests |
| `TestInfo` | Failure message includes the test display name, so a CI log makes it obvious which scenario broke |
| `@JUnitResolved Clock` | The receipt timestamp comes from a fixed clock, making the test deterministic regardless of when it runs |

## Step method signatures (from `ReceiptWriterFeature`)

```java
// Gherkin-derived + built-in @TempDir + custom @JUnitResolved — three sources on one step
public void anOrder$p1WithItemsHasBeenPlaced(
        String orderId,
        @TempDir Path receiptsDir,
        @JUnitResolved Clock clock) throws IOException { ... }

// Built-in TestInfo only — used in the failure message
public void theReceiptFileExists(TestInfo testInfo) { ... }

// Custom @JUnitResolved Clock only
public void theReceiptIsTimestampedWithTheTestClock(@JUnitResolved Clock clock) throws IOException { ... }
```

## Generated `@Test` method (excerpt)

The processor aggregates the union of resolved parameters across all three steps:

```java
@Test
@Order(1)
@DisplayName("Scenario: Write a timestamped receipt for an order")
public void scenario_1(@TempDir Path receiptsDir, Clock clock, TestInfo testInfo) {
    /*
     * Given an order "ORD-001" with items has been placed
     */
    anOrder$p1WithItemsHasBeenPlaced("ORD-001", receiptsDir, clock);
    /*
     * Then the receipt file exists
     */
    theReceiptFileExists(testInfo);
    /*
     * And the receipt is timestamped with the test clock
     */
    theReceiptIsTimestampedWithTheTestClock(clock);
}
```

Note: `@JUnitResolved` is stripped from the generated parameter (it has no JUnit semantics), while `@TempDir` is preserved so JUnit's resolver fires.

## `@JUnitResolved` placement options

This example uses **parameter-level** placement (`@JUnitResolved Clock clock`), which is required for JDK types like `Clock` that you can't modify. For user-controlled types, the **type-level** placement is equivalent and more convenient — mark the type once and use it freely:

```java
@JUnitResolved
public class OrderContext { ... }

// then anywhere:
public void anOrderIsBeingProcessed(OrderContext ctx) { ... }
```

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/ReceiptWriter.feature` | The spec |
| `src/test/java/.../ReceiptWriterFeature.java` | Marker class with step implementations |
| `src/test/java/.../FixedClockResolver.java` | Custom `ParameterResolver` providing a deterministic `Clock` |

## Key points

- **Built-in JUnit types don't require `@JUnitResolved`** — they are recognized by type (and by `@TempDir` for the temp-dir variants)
- **Custom types do require `@JUnitResolved`** — without it, the generator does not recognize the parameter as JUnit-resolved and falls back to its default behavior (regenerates a fresh step method, treating the user's declaration as an unused overload)
- **Order matters in the source signature, not in the generated test method** — JUnit's parameter resolution is type-based, so the generated signature lists params in a deterministic but order-agnostic way
- **`@ExtendWith` on the marker class** registers the custom resolver; because `@ExtendWith` is `@Inherited`, the generated `MyFeatureTest` picks it up automatically
