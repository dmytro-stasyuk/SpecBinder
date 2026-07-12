package dev.specbinder.examples.commonusecases.basesteps;

import dev.specbinder.annotations.Gherkin2JUnit;

/**
 * Marker class that extends {@link BaseShopSteps}. Because the shared cart steps
 * are already implemented in the base class, the generated ShoppingCartScenarios
 * inherits them and declares abstract methods only for the remaining,
 * feature-specific steps.
 */
@Gherkin2JUnit("specs/ShoppingCart.feature")
public abstract class ShoppingCartFeature extends BaseShopSteps {
}
