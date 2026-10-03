package dev.specbinder.examples.gettingstarted.stepreuse;

import specs.ShoppingCartScenarios;

import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Concrete test class that implements each distinct step once — the add
 * step serves all three of its uses across both scenarios. The steps of a
 * scenario share state through the cart field; JUnit creates a new instance
 * of this class for every scenario, so each one starts with an empty cart.
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
