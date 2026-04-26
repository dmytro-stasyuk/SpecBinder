package dev.specbinder.examples.reporter;

import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.reporter.SpecBinderReporter;

import org.junit.jupiter.api.Assumptions;
import org.junit.jupiter.api.extension.ExtendWith;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Marker class for the ShoppingCart spec. Step methods are implemented here directly
 * (concrete mode); the generator detects them in the parent and omits stubs in the
 * generated test class. Behaviour is intentionally varied to produce all four
 * statuses in the resulting JSON report:
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
@Gherkin2JUnit("specs/ShoppingCart.feature")
@ExtendWith(SpecBinderReporter.class)
public abstract class ShoppingCartFeature {

    private final Cart cart = new Cart();

    public void iHaveANewCart() {
        cart.setSubtotal(0.0);
    }

    public void iHaveACartWithSubtotal$p1(Double subtotal) {
        cart.setSubtotal(subtotal);
    }

    public void iAddAnItemPriced$p1WithQuantity$p2(Double unitPrice, Integer quantity) {
        cart.addItem(unitPrice, quantity);
    }

    public void iApplyDiscountCode$p1(String code) {
        cart.applyDiscountCode(code);
    }

    public void theCartTotalShouldBe$p1(Double expected) {
        assertEquals(expected, cart.subtotal(), 0.001);
    }

    public void theUpstreamPricingServiceIsUnavailable() {
        Assumptions.abort("pricing service is unreachable; skipping scenario");
    }
}
