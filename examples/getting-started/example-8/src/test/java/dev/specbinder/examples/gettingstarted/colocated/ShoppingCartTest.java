package dev.specbinder.examples.gettingstarted.colocated;

import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Runnable implementation of the scenarios generated from the co-located
 * ShoppingCart.specb file.
 */
public class ShoppingCartTest extends ShoppingCartScenarios {

    private final List<String> items = new ArrayList<>();

    @Override
    public void iHaveAnEmptyShoppingCart() {
        items.clear();
    }

    @Override
    public void iAdd$p1ToTheCart(String item) {
        items.add(item);
    }

    @Override
    public void theCartShouldContain$p1Item(Integer expectedCount) {
        assertEquals(expectedCount, items.size());
    }

    @Override
    public void iHaveACartWith$p1(String item) {
        items.clear();
        items.add(item);
    }

    @Override
    public void iRemove$p1FromTheCart(String item) {
        items.remove(item);
    }

    @Override
    public void theCartShouldBeEmpty() {
        assertTrue(items.isEmpty());
    }
}
