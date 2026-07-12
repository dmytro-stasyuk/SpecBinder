package dev.specbinder.examples.commonusecases.basesteps;

import specs.CheckoutScenarios;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Concrete test for the Checkout feature. It implements only the
 * checkout-specific steps — the cart setup steps are inherited from
 * {@link BaseShopSteps}, exactly as in {@link ShoppingCartTest}, and the
 * {@code subtotal()} helper is reused here too.
 */
public class CheckoutTest extends CheckoutScenarios {

    private double orderTotal;

    @Override
    public void iCheckOut() {
        orderTotal = subtotal();
    }

    @Override
    public void theOrderTotalShouldBe$p1(Double expectedTotal) {
        assertEquals(expectedTotal, orderTotal, 0.001);
    }
}
