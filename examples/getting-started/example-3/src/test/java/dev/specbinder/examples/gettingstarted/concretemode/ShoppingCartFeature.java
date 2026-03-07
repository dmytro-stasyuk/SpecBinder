package dev.specbinder.examples.gettingstarted.concretemode;

import dev.specbinder.annotations.Feature2JUnit;

import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Concrete mode: implement step methods directly in the marker class.
 * The generator detects these methods in the parent and stops generating stubs for them.
 * The generated test class inherits and calls these implementations.
 */
@Feature2JUnit("specs/ShoppingCart.feature")
public abstract class ShoppingCartFeature {

    private final List<CartItem> cart = new ArrayList<>();

    public void iHaveAnEmptyShoppingCart() {
        cart.clear();
    }

    public void iAdd$p1WithQuantity$p2AndUnitPrice$p3(String name, Integer quantity, Double unitPrice) {
        cart.add(new CartItem(name, quantity, unitPrice));
    }

    public void theCartShouldContain$p1Item(Integer expectedCount) {
        assertEquals(expectedCount, cart.size());
    }

    public void theCartShouldContain$p1Items(Integer expectedCount) {
        assertEquals(expectedCount, cart.size());
    }

    public void theCartSubtotalShouldBe$p1(Double expectedSubtotal) {
        double subtotal = cart.stream()
                .mapToDouble(item -> item.quantity * item.unitPrice)
                .sum();
        assertEquals(expectedSubtotal, subtotal, 0.001);
    }

    record CartItem(String name, int quantity, double unitPrice) {
    }
}
