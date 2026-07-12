# Example 3: Sharing Steps via a Base Class

Demonstrates sharing common step implementations by placing them in a **base class** that multiple markers extend. The generator detects step methods already present anywhere in a marker's class hierarchy and reuses them — it emits no abstract declaration (or stub) for a step a base class already implements.

Two feature files (`ShoppingCart` and `Checkout`) each have their own marker that extends the same `BaseShopSteps`, so the cart setup steps are implemented **once** and reused across both.

## What this demonstrates

- Common step methods live in a reusable base class (`BaseShopSteps`)
- **Two** marker classes extend the base — the shared steps are reused across both feature implementations
- The generator declares abstract methods only for each feature's *own* steps
- Shared state (the cart) and helpers (`subtotal()`) also live in the base class — no per-feature glue
- Base-class inheritance as an alternative to interface composition (see the *Organizing Steps into Interfaces* example)

## Class hierarchy

```
BaseShopSteps.java                       (shared cart steps + state + helpers)
  ├→ ShoppingCartFeature.java            (marker → specs/ShoppingCart.feature)
  │     └→ ShoppingCartScenarios.java    (generated, abstract)
  │           └→ ShoppingCartTest.java   (concrete — cart-assertion steps)
  └→ CheckoutFeature.java                (marker → specs/Checkout.feature)
        └→ CheckoutScenarios.java        (generated, abstract)
              └→ CheckoutTest.java       (concrete — checkout steps)
```

Both `ShoppingCart.feature` and `Checkout.feature` use `Given I have an empty shopping cart`
and `When I add "…" with quantity "…" and unit price "…"` — implemented once in `BaseShopSteps`.

## The base class

Common steps, shared state, and helpers live here:

```java
public abstract class BaseShopSteps {

    protected final List<CartItem> cart = new ArrayList<>();

    public void iHaveAnEmptyShoppingCart() {
        cart.clear();
    }

    public void iAdd$p1WithQuantity$p2AndUnitPrice$p3(String name, Integer quantity, Double unitPrice) {
        cart.add(new CartItem(name, quantity, unitPrice));
    }

    // protected itemCount() / subtotal() helpers reused by both features
}
```

## Two markers, two concrete tests

Each marker extends the base and points at its own feature; each concrete test implements only its feature's own steps:

```java
@Gherkin2JUnit("specs/ShoppingCart.feature")
public abstract class ShoppingCartFeature extends BaseShopSteps {}

@Gherkin2JUnit("specs/Checkout.feature")
public abstract class CheckoutFeature extends BaseShopSteps {}

public class ShoppingCartTest extends ShoppingCartScenarios {
    @Override public void theCartShouldContain$p1Item(Integer expected) { assertEquals(expected, itemCount()); }
    @Override public void theCartSubtotalShouldBe$p1(Double expected)   { assertEquals(expected, subtotal(), 0.001); }
}

public class CheckoutTest extends CheckoutScenarios {
    private double orderTotal;
    @Override public void iCheckOut()                              { orderTotal = subtotal(); }
    @Override public void theOrderTotalShouldBe$p1(Double expected) { assertEquals(expected, orderTotal, 0.001); }
}
```

Neither generated class re-declares `iHaveAnEmptyShoppingCart` or `iAdd…` as abstract — both inherit them from `BaseShopSteps`.

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/ShoppingCart.feature` | First feature — cart setup + cart assertions |
| `src/test/resources/specs/Checkout.feature` | Second feature — reuses the base cart steps, adds checkout steps |
| `src/test/java/.../BaseShopSteps.java` | Base class with shared step implementations, state, and helpers |
| `src/test/java/.../ShoppingCartFeature.java` | Marker for the first feature (extends the base) |
| `src/test/java/.../CheckoutFeature.java` | Marker for the second feature (extends the base) |
| `src/test/java/.../ShoppingCartTest.java` | Concrete test — cart-assertion steps |
| `src/test/java/.../CheckoutTest.java` | Concrete test — checkout steps |

## Run it

```bash
cd examples/common-use-cases/example-3
mvn test
```
