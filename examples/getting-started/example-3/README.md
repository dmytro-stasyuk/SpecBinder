# Example 3: Implementing Step Methods — End-to-End

A fully working example where the generated abstract class is extended by a concrete subclass that implements each step method with real assertions. Tests actually run and pass.

## What this demonstrates

- The end-to-end workflow from spec file to passing tests
- The default **abstract mode**: the generated `…Scenarios` class is abstract with one abstract method per step
- Implementing those step methods in a concrete subclass (`ShoppingCartTest`)
- State management via instance fields on the subclass (no DI framework needed)
- Real JUnit assertions in step methods
- Any unimplemented step is a **compile error**, not a runtime failure

## Workflow

1. Create a marker class with `@Gherkin2JUnit`
2. Compile — the generator emits an abstract `…Scenarios` class with one abstract method per step and one `@Test` method per scenario
3. Create a concrete subclass that extends the generated class and implement every abstract step method
4. Tests run and pass; any missing step won't compile

## Class hierarchy

```
ShoppingCartFeature.java          (marker class, @Gherkin2JUnit)
  └→ ShoppingCartScenarios.java   (generated, abstract, contains @Test methods)
      └→ ShoppingCartTest.java    (your concrete class, implements step methods)
```

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/ShoppingCart.feature` | Feature with two scenarios |
| `src/test/java/.../ShoppingCartFeature.java` | Empty abstract marker class |
| `src/test/java/.../ShoppingCartTest.java` | Concrete subclass implementing the step methods with assertions |

## Key pattern

State is shared between steps via instance fields on the concrete subclass — no dependency injection required:

```java
public class ShoppingCartTest extends ShoppingCartScenarios {

    private final List<CartItem> cart = new ArrayList<>();

    @Override
    public void iHaveAnEmptyShoppingCart() {
        cart.clear();
    }

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
