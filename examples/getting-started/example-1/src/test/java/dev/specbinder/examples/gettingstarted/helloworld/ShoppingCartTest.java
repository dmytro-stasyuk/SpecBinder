package dev.specbinder.examples.gettingstarted.helloworld;

import specs.ShoppingCartScenarios;

import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Concrete test class that extends the generated abstract class and
 * implements its three step methods — one per Given/When/Then step.
 * Leave one out and the class no longer compiles.
 */
public class ShoppingCartTest extends ShoppingCartScenarios {

    private final List<String> cart = new ArrayList<>();

    @Override
    public void iHaveAnEmptyShoppingCart() {
        cart.clear();
    }

    @Override
    public void iAddAnItemToTheCart() {
        cart.add("Wireless Headphones");
    }

    @Override
    public void theCartShouldContainOneItem() {
        assertEquals(1, cart.size());
    }
}
