package dev.specbinder.examples.migratingfromcucumber.cucumberannotations;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Concrete test class. It implements the custom-named steps declared in ShoppingCartFeature,
 * plus theCartSubtotalShouldBe$p1 — the one step the generator emitted itself, with its
 * generated @Then annotation.
 */
public class ShoppingCartTest extends ShoppingCartScenarios {

    private static final Map<String, Integer> ACTIVE_DISCOUNT_CODES = Map.of("SAVE10", 10);

    private final List<String> cart = new ArrayList<>();
    private double subtotal;

    @Override
    public void startWithEmptyCart() {
        cart.clear();
    }

    @Override
    public void addItemToCart(String item) {
        cart.add(item);
    }

    @Override
    public void verifyCartSize(Integer expectedCount) {
        assertEquals(expectedCount, cart.size());
    }

    @Override
    public void setupCartWithSubtotal(Double amount) {
        subtotal = amount;
    }

    @Override
    public void applyDiscount(String code) {
        int percentage = ACTIVE_DISCOUNT_CODES.get(code);
        subtotal = subtotal * (100 - percentage) / 100;
    }

    @Override
    public void theCartSubtotalShouldBe$p1(Double expectedSubtotal) {
        assertEquals(expectedSubtotal, subtotal, 0.001);
    }
}
