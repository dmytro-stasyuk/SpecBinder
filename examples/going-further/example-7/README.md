# Example 7: Build-Log Diagnostics

Tune how much the SpecBinder annotation processor prints to the build log via the `verbosity` option. This is compile-time output — run `mvn test-compile` (or `mvn test`) and watch the log during generation.

## What this demonstrates

- `@Gherkin2JUnitOptions(verbosity = Verbosity.VERBOSE)` raises the processor's build-log detail
- Levels are **cumulative** — each level includes everything from the levels below it

## The verbosity levels

| Level | What it emits |
|---|---|
| `SILENT` | Only error diagnostics — no banner, warnings, headers, or summary (quiet CI on success) |
| `NORMAL` *(default)* | Errors, warnings, the startup banner, and the end-of-round summary |
| `VERBOSE` | Adds per-class processing headers, per-feature progress, the resolved spec path per class, and skipped/filtered work |
| `DEBUG` | Adds full stack traces, parsed Gherkin AST summaries, JavaPoet code-model summaries, and per-step decisions |

## The marker class

```java
@Gherkin2JUnit("specs/ShoppingCart.specb")
@Gherkin2JUnitOptions(verbosity = Verbosity.VERBOSE)
public abstract class ShoppingCartFeature {
}
```

## Run it

```bash
cd examples/going-further/example-7
mvn test
```

The verbosity output appears during the **compile** phase; the generated test itself runs like any other example.
