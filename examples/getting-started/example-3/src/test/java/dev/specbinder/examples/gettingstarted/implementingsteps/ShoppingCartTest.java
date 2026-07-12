package dev.specbinder.examples.gettingstarted.implementingsteps;

import specs.ShoppingCartScenarios;

import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Concrete test class that extends the generated abstract class and
 * implements each abstract step method. Shared state lives in plain
 * instance fields — no DI framework needed. Any step method left
 * unimplemented is a compile error, not a runtime failure.
 */
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
    public void theCartShouldContain$p1Item(Integer expectedCount) {
        assertEquals(expectedCount, cart.size());
    }

    @Override
    public void theCartShouldContain$p1Items(Integer expectedCount) {
        assertEquals(expectedCount, cart.size());
    }

    @Override
    public void theCartSubtotalShouldBe$p1(Double expectedSubtotal) {
        double subtotal = cart.stream()
                .mapToDouble(item -> item.quantity * item.unitPrice)
                .sum();
        assertEquals(expectedSubtotal, subtotal, 0.001);
    }

    record CartItem(String name, int quantity, double unitPrice) {
    }
}
