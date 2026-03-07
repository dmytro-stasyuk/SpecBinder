package dev.specbinder.examples.commonusecases.abstractmode;

import specs.ShoppingCartScenarios;

import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Concrete test class that extends the generated abstract class.
 * Only the abstract step methods need to be implemented here —
 * myCartSubtotalIs$p1 and iViewTheCart are already inherited from
 * ShoppingCartFeature (the marker class) and have no abstract declaration.
 */
public class ShoppingCartTest extends ShoppingCartScenarios {

    private final List<CartItem> cart = new ArrayList<>();

    @Override
    public void iHaveAnEmptyShoppingCart() {
        cart.clear();
        subtotal = 0;
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
    public void theCartSubtotalShouldBe$p1(Double expectedSubtotal) {
        double actual = cart.stream()
                .mapToDouble(item -> item.quantity * item.unitPrice)
                .sum();
        assertEquals(expectedSubtotal, actual, 0.001);
    }

    // NOTE: myCartSubtotalIs$p1() and iViewTheCart() are NOT here —
    // they are inherited from ShoppingCartFeature (the marker class).
    // The generator detected them and did not emit abstract declarations.

    @Override
    public void iShouldSeeThe$p1Banner(String expectedBanner) {
        assertEquals(expectedBanner, banner);
    }

    record CartItem(String name, int quantity, double unitPrice) {
    }
}
