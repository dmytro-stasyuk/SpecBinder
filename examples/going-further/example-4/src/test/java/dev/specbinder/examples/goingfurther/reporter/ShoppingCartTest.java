package dev.specbinder.examples.goingfurther.reporter;

import org.junit.jupiter.api.Assumptions;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Concrete test class implementing the ShoppingCart steps. Behaviour is intentionally varied
 * to produce several statuses in the resulting JSON report:
 * <ul>
 *     <li>Most scenarios pass.</li>
 *     <li>One scenario asserts a wrong total → {@code failed} status with an error block.</li>
 *     <li>One scenario calls {@link Assumptions#abort} → {@code aborted} status.</li>
 * </ul>
 * Note: SpecBinder doesn't currently translate a Gherkin {@code @disabled} tag to JUnit's
 * {@code @Disabled}, so the report won't contain a {@code skipped} scenario in this example —
 * the listener's skipped-status code path is verified by the unit tests in the
 * execution-reporter module instead.
 */
public class ShoppingCartTest extends ShoppingCartScenarios {

    private final Cart cart = new Cart();

    @Override
    public void iHaveANewCart() {
        cart.setSubtotal(0.0);
    }

    @Override
    public void iHaveACartWithSubtotal$p1(Double subtotal) {
        cart.setSubtotal(subtotal);
    }

    @Override
    public void iAddAnItemPriced$p1WithQuantity$p2(Double unitPrice, Integer quantity) {
        cart.addItem(unitPrice, quantity);
    }

    @Override
    public void iApplyDiscountCode$p1(String code) {
        cart.applyDiscountCode(code);
    }

    @Override
    public void theCartTotalShouldBe$p1(Double expected) {
        assertEquals(expected, cart.subtotal(), 0.001);
    }

    @Override
    public void theUpstreamPricingServiceIsUnavailable() {
        Assumptions.abort("pricing service is unreachable; skipping scenario");
    }
}
