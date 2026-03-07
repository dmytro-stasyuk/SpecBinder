# Example 3: Implementing Step Methods — Concrete Mode End-to-End

A fully working example where step methods are implemented in the marker class with real assertions. Tests actually run and pass.

## What this demonstrates

- The default **concrete mode** workflow end-to-end
- Step methods implemented directly in the marker class
- The generator detects inherited methods and **stops generating stubs** for them
- State management via instance fields (no DI framework needed)
- Real JUnit assertions in step methods

## Concrete mode workflow

1. Create marker class with `@Feature2JUnit`
2. Compile — generator produces a test class with failing stubs
3. Implement step methods in the marker class
4. Recompile — generator sees parent methods, stops emitting stubs
5. Generated test class inherits and calls your implementations
6. Tests run and pass

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/ShoppingCart.feature` | Feature with two scenarios |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class with real step implementations and assertions |

## Key pattern

State is shared between steps via instance fields on the marker class — no dependency injection required:

```java
private final List<CartItem> cart = new ArrayList<>();

public void iHaveAnEmptyShoppingCart() {
    cart.clear();
}

public void iAdd$p1WithQuantity$p2AndUnitPrice$p3(String name, Integer quantity, Double unitPrice) {
    cart.add(new CartItem(name, quantity, unitPrice));
}

public void theCartSubtotalShouldBe$p1(Double expectedSubtotal) {
    double subtotal = cart.stream()
            .mapToDouble(item -> item.quantity * item.unitPrice)
            .sum();
    assertEquals(expectedSubtotal, subtotal, 0.001);
}
```
