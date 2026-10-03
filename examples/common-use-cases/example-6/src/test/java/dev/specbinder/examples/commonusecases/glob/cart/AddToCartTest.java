package dev.specbinder.examples.commonusecases.glob.cart;

import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Concrete test for AddToCart.specb, placed next to it. The generated
 * AddToCartScenarios lands in this package because the glob found the spec here.
 */
public class AddToCartTest extends AddToCartScenarios {

    private final List<String> cart = new ArrayList<>();

    @Override
    public void iHaveAnEmptyShoppingCart() {
        cart.clear();
    }

    @Override
    public void iAdd$p1ToTheCart(String product) {
        cart.add(product);
    }

    @Override
    public void theCartShouldContain$p1Item(Integer expectedCount) {
        assertEquals(expectedCount, cart.size());
    }

    @Override
    public void theCartShouldContain$p1Items(Integer expectedCount) {
        assertEquals(expectedCount, cart.size());
    }
}
