# Example 3: Organizing Steps into Interfaces

Demonstrates splitting step methods into **domain interfaces** that the marker class implements, instead of declaring every step inline on one class. The generator inherits step methods through the interfaces and does not re-declare them as abstract.

## What this demonstrates

- Step methods grouped by domain into interfaces (`CartSteps`, `CheckoutSteps`)
- Interfaces use Java `default` methods to carry shared implementations
- Interfaces can't hold state, so each declares a `cart()` accessor; the steps work on whatever `Cart` it returns
- The marker class implements the interfaces to pull in all their steps
- The generator sees inherited step methods and emits no abstract declarations for them
- A single marker can compose any number of step interfaces — no per-feature wiring
- The concrete `ShoppingCartTest` only supplies the state — one fresh `Cart` per test — and makes the scenarios runnable

## Structure

```
src/test/java/.../stepinterfaces/
  ├── ShoppingCart.specb           ← one scenario touching cart + checkout steps
  ├── ShoppingCartFeature.java     ← marker; implements CartSteps, CheckoutSteps
  ├── ShoppingCartTest.java        ← concrete test; supplies the Cart
  ├── Cart.java                    ← tiny in-memory cart and checkout
  └── steps/
      ├── CartSteps.java           ← interface — cart step methods
      └── CheckoutSteps.java       ← interface — checkout step methods
```

## Class hierarchy

```
CartSteps, CheckoutSteps           (interfaces — default step implementations, abstract cart() accessor)
  └→ ShoppingCartFeature.java      (marker, @Gherkin2JUnit — implements both interfaces)
      └→ ShoppingCartScenarios.java (generated, abstract — no step declarations, all inherited)
          └→ ShoppingCartTest.java  (your concrete class — implements cart())
```

## The pattern

Group step methods by domain using interfaces with `default` methods:

```java
public interface CartSteps {

    Cart cart();

    default void iHaveAnEmptyShoppingCart() {
        cart().clear();
    }

    default void iAdd$p1ToTheCart(String item) {
        cart().add(item);
    }
}
```

`CheckoutSteps` declares the same `cart()` accessor, so cart and checkout steps share one cart. The marker class
implements every interface:

```java
@Gherkin2JUnit
public abstract class ShoppingCartFeature implements CartSteps, CheckoutSteps {
}
```

The generated `ShoppingCartScenarios` inherits all step implementations through the marker — no abstract declarations,
no per-feature glue. The concrete test only provides the state:

```java
public class ShoppingCartTest extends ShoppingCartScenarios {

    private final Cart cart = new Cart();

    @Override
    public Cart cart() {
        return cart;
    }
}
```

Without that subclass the generated class stays abstract, and JUnit never runs it. Pair this with the [glob pattern](../../common-use-cases/example-6) example to share one set of step interfaces across many features.

## Run it

```bash
cd examples/going-further/example-3
mvn test
```
