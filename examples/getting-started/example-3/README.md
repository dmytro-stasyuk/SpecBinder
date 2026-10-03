# Example 3: Step Reuse and Scenario State

Shows how steps are reused across scenarios and how state flows from one step to the next. Each distinct step becomes
**one** step method, no matter how many scenarios use it, and the steps of a scenario share state through ordinary
instance fields of the test class.

## What this demonstrates

- A step used in several scenarios — or several times in one scenario — becomes **one** generated step method,
  implemented **once**
- Calls to that method differ only in their arguments
- Step text that differs even slightly becomes a **different** method — `"1" item` and `"2" items` are two steps
- Steps share state through plain instance fields on the concrete test class — no DI framework, no context object
- JUnit creates a **new test instance for every scenario**, so each scenario starts with fresh state

## The spec

```gherkin
Scenario: Add item and verify cart contents
  Given I have an empty shopping cart
  When I add "Wireless Headphones" with quantity "2" and unit price "59.99"
  Then the cart should contain "1" item
  And the cart subtotal should be "119.98"

Scenario: Add multiple different items
  Given I have an empty shopping cart
  When I add "Wireless Headphones" with quantity "1" and unit price "59.99"
  And I add "Coffee Beans" with quantity "3" and unit price "12.50"
  Then the cart should contain "2" items
  And the cart subtotal should be "97.49"
```

Nine step lines, but only five distinct steps.

## One method per distinct step

The generated class declares five abstract methods and calls them from both scenarios:

```java
public abstract void iHaveAnEmptyShoppingCart();
public abstract void iAdd$p1WithQuantity$p2AndUnitPrice$p3(String p1, Integer p2, Double p3);
public abstract void theCartShouldContain$p1Item(Integer p1);
public abstract void theCartShouldContain$p1Items(Integer p1);
public abstract void theCartSubtotalShouldBe$p1(Double p1);

public void scenario_2() {
    iHaveAnEmptyShoppingCart();
    iAdd$p1WithQuantity$p2AndUnitPrice$p3("Wireless Headphones", 1, 59.99);
    iAdd$p1WithQuantity$p2AndUnitPrice$p3("Coffee Beans", 3, 12.50);
    theCartShouldContain$p1Items(2);
    theCartSubtotalShouldBe$p1(97.49);
}
```

The `add` step appears three times across the two scenarios — the quoted values become arguments, so it is still
one method. The two "should contain" steps are a different story: `item` and `items` are different words, so the
generator produces two methods. Settle on one wording in the spec when you want one method.

## Scenario state

Each step does a small piece of the work; the instance fields of the test class carry the result from one step to the
next:

```java
public class ShoppingCartTest extends ShoppingCartScenarios {

    private final List<CartItem> cart = new ArrayList<>();

    @Override
    public void iAdd$p1WithQuantity$p2AndUnitPrice$p3(String name, Integer quantity, Double unitPrice) {
        cart.add(new CartItem(name, quantity, unitPrice));
    }

    @Override
    public void theCartSubtotalShouldBe$p1(Double expectedSubtotal) {
        double subtotal = cart.stream()
                .mapToDouble(item -> item.quantity * item.unitPrice)
                .sum();
        assertEquals(expectedSubtotal, subtotal, 0.001);
    }
}
```

## Fresh state for every scenario

JUnit's default lifecycle creates a new instance of `ShoppingCartTest` for each `@Test` method, so every scenario gets
its own empty `cart` field. The second scenario never sees the headphones added by the first, and the order the
scenarios run in doesn't matter.

## Class hierarchy

```
ShoppingCartFeature.java          (marker class, @Gherkin2JUnit)
  └→ ShoppingCartScenarios.java   (generated, abstract — one abstract method per distinct step)
      └→ ShoppingCartTest.java    (your concrete class, implements each step once, holds the state)
```

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/ShoppingCart.feature` | Two scenarios sharing most of their steps |
| `src/test/java/.../ShoppingCartFeature.java` | Empty abstract marker class |
| `src/test/java/.../ShoppingCartTest.java` | Concrete subclass implementing each distinct step once, with the cart as instance state |
