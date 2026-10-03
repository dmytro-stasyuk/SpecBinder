# Example 2: Step Parameters & Type Inference

Demonstrates how quoted values in Gherkin steps become typed Java method parameters with automatic type inference.

## What this demonstrates

- Quoted values in steps (`"59.99"`, `"3"`, `"true"`) become method parameters
- Automatic type inference: `"59.99"` → `Double`, `"3"` → `Integer`, `"true"` → `Boolean`, `"Wireless Headphones"` → `String`, `"Y"` → `Character`
- Parameter placeholders in method names (`$p1`, `$p2`, `$p3`)
- Multiple parameters in a single step
- The concrete `ShoppingCartTest` receives the values already typed and uses them directly, with no parsing

## Type inference rules

| Quoted value | Inferred type |
|---|---|
| `"true"` / `"false"` | `Boolean` |
| Integer literal (e.g. `"3"`) | `Integer` (or `Long` if too large) |
| Decimal literal (e.g. `"59.99"`) | `Double` |
| Single character (e.g. `"Y"`) | `Character` |
| Everything else (e.g. `"Wireless Headphones"`) | `String` |

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/ShoppingCart.feature` | Feature with steps containing various quoted value types |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class annotated with `@Gherkin2JUnit` |
| `src/test/java/.../ShoppingCartTest.java` | Concrete subclass implementing the step methods with assertions |

## Class hierarchy

```
ShoppingCartFeature.java          (marker class, @Gherkin2JUnit)
  └→ ShoppingCartScenarios.java   (generated, abstract — one abstract method per step)
      └→ ShoppingCartTest.java    (your concrete class, implements the step methods)
```

## Generated output

The generator produces abstract step methods like:

```java
public abstract void myCartContains$p1WithQuantity$p2AndUnitPrice$p3(String p1, Integer p2, Double p3);
public abstract void iChangeTheQuantityTo$p1(Integer p1);
public abstract void theCartSubtotalShouldBe$p1(Double p1);
public abstract void theDiscountAppliedIs$p1(Boolean p1);
public abstract void theDiscountBadgeShows$p1(Character p1);
```

`ShoppingCartTest` implements them, so the step code works with real types:

```java
@Override
public void theDiscountAppliedIs$p1(Boolean applied) {
    discountApplied = applied;
}

@Override
public void theDiscountBadgeShows$p1(Character expectedBadge) {
    assertEquals(expectedBadge, discountBadge);
}
```
