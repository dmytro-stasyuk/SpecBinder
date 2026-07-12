package dev.specbinder.examples.commonusecases.basesteps;

import specs.ShoppingCartScenarios;

/**
 * Concrete test class. It implements only the feature-specific assertion steps —
 * the cart setup steps ({@code iHaveAnEmptyShoppingCart}, {@code iAdd…}) are
 * inherited from {@link BaseShopSteps} through the generated class hierarchy and
 * never appear as abstract methods here.
 */
public class ShoppingCartTest extends ShoppingCartScenarios {

    @Override
    public void theCartShouldContain$p1Item(Integer expectedCount) {
        assertEquals(expectedCount, itemCount());
    }

    @Override
    public void theCartSubtotalShouldBe$p1(Double expectedSubtotal) {
        assertEquals(expectedSubtotal, subtotal(), 0.001);
    }
}
