# Example 3: Organizing Steps into Interfaces

Demonstrates splitting step methods into **domain interfaces** that the marker class implements, instead of declaring every step inline on one class. The generator inherits step methods through the interfaces and does not re-declare them as abstract.

## What this demonstrates

- Step methods grouped by domain into interfaces (`CartSteps`, `CheckoutSteps`)
- Interfaces use Java `default` methods to carry shared implementations
- The marker class implements the interfaces to pull in all their steps
- The generator sees inherited step methods and emits no abstract declarations for them
- A single marker can compose any number of step interfaces — no per-feature wiring

## Structure

```
src/test/resources/specs/ShoppingCart.specb   ← one scenario touching cart + checkout steps

src/test/java/.../stepinterfaces/
  ├── ShoppingCartFeature.java     ← marker; implements CartSteps, CheckoutSteps
  └── steps/
      ├── CartSteps.java           ← interface — cart step methods
      └── CheckoutSteps.java       ← interface — checkout step methods
```

## The pattern

Group step methods by domain using interfaces with `default` methods:

```java
public interface CartSteps {
    default void iHaveAnEmptyShoppingCart() { /* shared cart implementation */ }
    default void iAdd$p1ToTheCart(String item) { /* shared cart implementation */ }
}
```

Then the marker class implements every interface:

```java
@Gherkin2JUnit("specs/ShoppingCart.specb")
public abstract class ShoppingCartFeature implements CartSteps, CheckoutSteps {
}
```

The generated `ShoppingCartScenarios` inherits all step implementations through the marker — no abstract declarations, no per-feature glue. Pair this with the [glob pattern](../../common-use-cases/example-6) example to share one set of step interfaces across many features.

## Run it

```bash
cd examples/going-further/example-3
mvn test
```
