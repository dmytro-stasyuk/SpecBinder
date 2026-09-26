package dev.specbinder.examples.goingfurther.multipletests;

// Generated classes take their package from the spec's own folder, so this one is specs.
import specs.CartPricingScenarios;

/**
 * The CartPricing spec run against the half-up configuration, which every scenario expects.
 *
 * <p>Writes its own report to
 * {@code target/specbinder-reports/dev/specbinder/examples/goingfurther/multipletests/CartPricingHalfUpTest.json}.
 */
public class CartPricingHalfUpTest extends CartPricingScenarios {

    @Override
    protected PricingEngine pricingEngine() {
        return new HalfUpPricing();
    }
}
