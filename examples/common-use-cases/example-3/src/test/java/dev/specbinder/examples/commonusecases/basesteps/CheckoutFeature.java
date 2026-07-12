package dev.specbinder.examples.commonusecases.basesteps;

import dev.specbinder.annotations.Gherkin2JUnit;

/**
 * A second marker class that also extends {@link BaseShopSteps}. It reuses the
 * exact same cart setup steps from the base class — the generator inherits them
 * and declares abstract methods only for this feature's checkout-specific steps.
 * This is what makes the base-class steps shared across two feature files.
 */
@Gherkin2JUnit("specs/Checkout.feature")
public abstract class CheckoutFeature extends BaseShopSteps {
}
