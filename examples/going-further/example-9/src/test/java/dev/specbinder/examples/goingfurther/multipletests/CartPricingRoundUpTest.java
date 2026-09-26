package dev.specbinder.examples.goingfurther.multipletests;

// Generated classes take their package from the spec's own folder, so this one is specs.
import specs.CartPricingScenarios;

/**
 * The same CartPricing spec run against the round-up configuration.
 *
 * <p>Three of the four scenarios pass, because their totals already land on a cent. The fourth is
 * charged 8.50 where the spec expects 8.49, so this class records a failure the half-up run does not —
 * and, because each report is named after the class that ran, both outcomes survive side by side in
 * {@code target/specbinder-reports/dev/specbinder/examples/goingfurther/multipletests/}.
 */
public class CartPricingRoundUpTest extends CartPricingScenarios {

    @Override
    protected PricingEngine pricingEngine() {
        return new RoundUpPricing();
    }
}
