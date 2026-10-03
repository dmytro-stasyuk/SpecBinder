# Example 2: JUnit Parameter Resolution in Step Methods

Demonstrates how step methods can receive parameters filled by JUnit's parameter resolution at test execution time — both JUnit's built-in resolvers and custom user-registered `ParameterResolver`s opted in via the `@JUnitResolved` marker annotation.

## What this demonstrates

- **Built-in implicit resolution** — `@TempDir Path` (per-test temporary directory) and `TestInfo` (test metadata) are recognized by the generator without any marker
- **Custom resolver** — a `Clock` filled by `FixedClockResolver` is opted in with `@JUnitResolved` on the parameter
- **Mixing on a single step** — one step method has a Gherkin-derived parameter plus both built-in and custom resolved parameters
- **Aggregation across steps** — the generated `@Test scenario_1` method receives the union (deduplicated) of every resolved parameter required by any of the scenario's steps
- **Annotation passthrough** — `@TempDir` is preserved on the generated parameter so JUnit's resolver fires; `@JUnitResolved` is a SpecBinder-internal marker and is stripped
- **Declare in the marker, implement in the test** — the step signatures with resolved parameters are declared abstract in
  the marker, where the generator can see them; the concrete `ReceiptWriterTest` implements them

## Why each resolved type is used here

| Type | Why |
|------|-----|
| `@TempDir Path` | Each test gets a fresh receipt output directory, so file assertions never collide between tests |
| `TestInfo` | Failure message includes the test display name, so a CI log makes it obvious which scenario broke |
| `@JUnitResolved Clock` | The receipt timestamp comes from a fixed clock, making the test deterministic regardless of when it runs |

## Class hierarchy

```
ReceiptWriterFeature.java          (marker, @Gherkin2JUnit — declares the steps with resolved parameters)
  └→ ReceiptWriterScenarios.java   (generated, abstract — @Test methods receive the resolved parameters)
      └→ ReceiptWriterTest.java    (your concrete class, implements the steps)
```

## Step method declarations (in `ReceiptWriterFeature`)

The generator only propagates resolved parameters for step methods it finds in the marker's class hierarchy — it can't
see a subclass of the generated class. So the steps that take resolved parameters are declared abstract in the marker,
with their full signatures:

```java
// Gherkin-derived + built-in @TempDir + custom @JUnitResolved — three sources on one step
public abstract void anOrder$p1WithItemsHasBeenPlaced(
        String orderId,
        @TempDir Path receiptsDir,
        @JUnitResolved Clock clock);

// Built-in TestInfo only — used in the failure message
public abstract void theReceiptFileExists(TestInfo testInfo);

// Custom @JUnitResolved Clock only
public abstract void theReceiptIsTimestampedWithTheTestClock(@JUnitResolved Clock clock);
```

`ReceiptWriterTest` implements them; there the resolved values are just ordinary arguments:

```java
@Override
public void anOrder$p1WithItemsHasBeenPlaced(String orderId, Path receiptsDir, Clock clock) {
    receiptFile = receiptsDir.resolve(orderId + ".txt");
    try {
        Files.writeString(receiptFile, "Order " + orderId + " issued at " + clock.instant());
    } catch (IOException e) {
        throw new UncheckedIOException(e);
    }
}
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
| `src/test/java/.../ReceiptWriter.specb` | The spec, co-located with its marker |
| `src/test/java/.../ReceiptWriterFeature.java` | Marker class declaring the steps with resolved parameters |
| `src/test/java/.../ReceiptWriterTest.java` | Concrete test implementing the steps |
| `src/test/java/.../FixedClockResolver.java` | Custom `ParameterResolver` providing a deterministic `Clock` |

## Key points

- **Built-in JUnit types don't require `@JUnitResolved`** — they are recognized by type (and by `@TempDir` for the temp-dir variants)
- **Custom types do require `@JUnitResolved`** — without it, the generator does not recognize the parameter as JUnit-resolved and falls back to its default behavior (regenerates a fresh step method, treating the user's declaration as an unused overload)
- **Order matters in the source signature, not in the generated test method** — JUnit's parameter resolution is type-based, so the generated signature lists params in a deterministic but order-agnostic way
- **`@ExtendWith` on the marker class** registers the custom resolver; because `@ExtendWith` is `@Inherited`, the concrete `ReceiptWriterTest` picks it up automatically
