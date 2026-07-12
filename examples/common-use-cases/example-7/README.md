# Example 7: Configuration Inheritance via `@Gherkin2JUnitOptions`

Demonstrates how to define shared generation options in a base class and selectively override them in individual marker classes.

## What this demonstrates

- `@Gherkin2JUnitOptions` on a base class applies to all extending marker classes
- Child marker classes **inherit** all options from the parent
- A child can place its own `@Gherkin2JUnitOptions` to **override specific options** — unspecified options continue to inherit
- Standardize generation behavior across a project via a single base class

## Class hierarchy

```
BaseFeature.java                          (@Gherkin2JUnitOptions — shared options)
  ├── ShoppingCartFeature.java            (inherits all options)
  │     └→ ShoppingCartFeatureTest.java   (generated — concrete, keyword prefixes)
  └── CheckoutFeature.java               (@Gherkin2JUnitOptions — overrides shouldBeAbstract)
        └→ CheckoutFeatureScenarios.java  (generated — abstract, keyword prefixes)
```

## Options flow

| Option | BaseFeature | ShoppingCartFeature | CheckoutFeature |
|--------|-------------|---------------------|-----------------|
| `useStepKeywordInStepMethodName` | `true` | inherited (`true`) | inherited (`true`) |
| `tagForEmptyScenarios` | `"todo"` | inherited (`"todo"`) | inherited (`"todo"`) |
| `tagForEmptyRules` | `"todo"` | inherited (`"todo"`) | inherited (`"todo"`) |
| `shouldBeAbstract` | `false` (default) | inherited (`false`) | **overridden** (`true`) |

## Effect on generated code

**ShoppingCartFeature** (inherits all, concrete mode):
```java
// Step methods include keyword prefix (useStepKeywordInStepMethodName = true)
public void givenIHaveAnEmptyShoppingCart() { ... }
public void whenIAdd$p1ToTheCart(String p1) { ... }
public void thenTheCartShouldContain$p1Item(Integer p1) { ... }
```

**CheckoutFeature** (overrides shouldBeAbstract):
```java
// Abstract class (shouldBeAbstract = true) + keyword prefixes (inherited)
public abstract void givenIHaveACartWith$p1Items(Integer p1);
public abstract void whenIProceedToCheckout();
public abstract void whenIPayWithCard$p1(String p1);
public abstract void thenTheOrderShouldBeConfirmed();
```

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/ShoppingCart.feature` | Simple cart feature |
| `src/test/resources/specs/Checkout.feature` | Checkout feature |
| `src/test/java/.../BaseFeature.java` | Base class with shared `@Gherkin2JUnitOptions` |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class inheriting all options |
| `src/test/java/.../CheckoutFeature.java` | Marker class overriding `shouldBeAbstract` |
