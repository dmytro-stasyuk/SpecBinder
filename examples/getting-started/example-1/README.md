# Example 1: Hello World — Simplest Possible Feature

The most basic SpecBinder example. A single scenario with plain steps — no parameters, no rules, no configuration.

## What this demonstrates

- Minimal setup: one marker class, one `.feature` file and one test class
- How `@Gherkin2JUnit("path")` triggers code generation
- Given/When/Then steps become method calls in the generated test class
- Each step becomes an abstract method in the generated class — implemented in a concrete subclass
- The marker class stays empty; a step left unimplemented is a compile error

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/ShoppingCart.feature` | Gherkin feature file with one scenario |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class annotated with `@Gherkin2JUnit` |
| `src/test/java/.../ShoppingCartTest.java` | Concrete subclass implementing the three step methods |

## Class hierarchy

```
ShoppingCartFeature.java          (marker class, @Gherkin2JUnit)
  └→ ShoppingCartScenarios.java   (generated, abstract — one abstract method per step)
      └→ ShoppingCartTest.java    (your concrete class, implements the step methods)
```

## Generated output

After compilation, the annotation processor generates an abstract `ShoppingCartScenarios.java` which extends
`ShoppingCartFeature` and contains:

- A `@Test` method for the scenario, calling one method per step
- One abstract step method per step
- `@DisplayName` annotations preserving the Gherkin scenario title

```java
public abstract void iHaveAnEmptyShoppingCart();
public abstract void iAddAnItemToTheCart();
public abstract void theCartShouldContainOneItem();
```

`ShoppingCartTest` extends it and implements the three methods; JUnit runs `ShoppingCartTest`.
