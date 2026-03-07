# Example 1: Hello World — Simplest Possible Feature

The most basic Spec Binder example. A single scenario with plain steps — no parameters, no rules, no configuration.

## What this demonstrates

- Minimal setup: one marker class + one `.feature` file
- How `@Feature2JUnit("path")` triggers code generation
- Given/When/Then steps become method calls in the generated test class
- Generated step methods contain `Assertions.fail("Step is not yet implemented")` stubs
- The marker class is empty — no step implementations yet

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/ShoppingCart.feature` | Gherkin feature file with one scenario |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class annotated with `@Feature2JUnit` |

## Generated output

After compilation, the annotation processor generates `ShoppingCartFeatureTest.java` which extends `ShoppingCartFeature` and contains:

- A `@Test` method for the scenario
- Step methods with failing stubs (`Assertions.fail(...)`)
- `@DisplayName` annotations preserving the Gherkin scenario title
