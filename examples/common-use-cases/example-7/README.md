# Example 7: Configuration Inheritance via `@Gherkin2JUnitOptions`

Demonstrates how to define shared generation options in a base class and selectively override them in individual marker classes.

## What this demonstrates

- `@Gherkin2JUnitOptions` on a base class applies to all extending marker classes
- Child marker classes **inherit** all options from the parent
- A child can place its own `@Gherkin2JUnitOptions` to **override specific options** — unspecified options continue to inherit
- Standardize generation behavior across a project via a single base class
- Both effects are visible in the concrete test classes: the class they extend and the step method names they implement

## Directory layout

The shared base class sits at the top; each feature gets its own sub-package holding its marker, spec and test, so the
package structure mirrors the inheritance hierarchy:

```
src/test/java/.../optionsinheritance/
  ├── BaseFeature.java               ← shared @Gherkin2JUnitOptions
  ├── shoppingcart/
  │   ├── ShoppingCartFeature.java   ← marker, inherits all options
  │   ├── ShoppingCart.specb
  │   └── ShoppingCartTest.java
  └── checkout/
      ├── CheckoutFeature.java       ← marker, overrides one option
      ├── Checkout.specb
      └── CheckoutTest.java
```

With one spec per sub-package, both markers use a bare `@Gherkin2JUnit` and discover their spec by convention.

## Class hierarchy

```
BaseFeature.java                     (@Gherkin2JUnitOptions — shared options)
  ├── ShoppingCartFeature.java       (inherits all options)
  │     └→ ShoppingCartSpec.java     (generated, abstract — "Spec" suffix, keyword-prefixed steps)
  │           └→ ShoppingCartTest.java
  └── CheckoutFeature.java           (@Gherkin2JUnitOptions — overrides useStepKeywordInStepMethodName)
        └→ CheckoutSpec.java         (generated, abstract — "Spec" suffix, plain step names)
              └→ CheckoutTest.java
```

## Options flow

| Option | BaseFeature | ShoppingCartFeature | CheckoutFeature |
|--------|-------------|---------------------|-----------------|
| `useStepKeywordInStepMethodName` | `true` | inherited (`true`) | **overridden** (`false`) |
| `classSuffixIfAbstract` | `"Spec"` | inherited (`"Spec"`) | inherited (`"Spec"`) |

```java
@Gherkin2JUnitOptions(
        useStepKeywordInStepMethodName = true,
        classSuffixIfAbstract = "Spec"
)
public abstract class BaseFeature {}

// in shoppingcart/
@Gherkin2JUnit
public abstract class ShoppingCartFeature extends BaseFeature {}

// in checkout/
@Gherkin2JUnitOptions(useStepKeywordInStepMethodName = false)
@Gherkin2JUnit
public abstract class CheckoutFeature extends BaseFeature {}
```

Options are inherited along the class hierarchy, not the package structure — the markers live in sub-packages and still
pick up everything from `BaseFeature`.

## Effect on generated code

**ShoppingCartFeature** (inherits both options):
```java
// Class name ends in "Spec", step methods carry the keyword prefix
public abstract class ShoppingCartSpec extends ShoppingCartFeature {
    public abstract void givenIHaveAnEmptyShoppingCart();
    public abstract void whenIAdd$p1ToTheCart(String p1);
    public abstract void thenTheCartShouldContain$p1Item(Integer p1);
}
```

**CheckoutFeature** (overrides `useStepKeywordInStepMethodName`, inherits the suffix):
```java
// Class name still ends in "Spec", step methods have no keyword prefix
public abstract class CheckoutSpec extends CheckoutFeature {
    public abstract void iHaveACartWith$p1Items(Integer p1);
    public abstract void iProceedToCheckout();
    public abstract void iPayWithCard$p1(Long p1);
    public abstract void theOrderShouldBeConfirmed();
}
```

The concrete tests extend `ShoppingCartSpec` and `CheckoutSpec` and implement those methods under exactly these names.

## Files

| File | Purpose |
|------|---------|
| `src/test/java/.../BaseFeature.java` | Base class with shared `@Gherkin2JUnitOptions` |
| `src/test/java/.../shoppingcart/ShoppingCartFeature.java` | Marker class inheriting all options |
| `src/test/java/.../shoppingcart/ShoppingCart.specb` | Simple cart feature |
| `src/test/java/.../shoppingcart/ShoppingCartTest.java` | Concrete test implementing the keyword-prefixed step methods |
| `src/test/java/.../checkout/CheckoutFeature.java` | Marker class overriding `useStepKeywordInStepMethodName` |
| `src/test/java/.../checkout/Checkout.specb` | Checkout feature |
| `src/test/java/.../checkout/CheckoutTest.java` | Concrete test implementing the plain-named step methods |
