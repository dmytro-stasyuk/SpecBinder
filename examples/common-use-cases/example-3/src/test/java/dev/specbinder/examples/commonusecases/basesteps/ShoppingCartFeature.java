package dev.specbinder.examples.commonusecases.basesteps;

import dev.specbinder.annotations.Gherkin2JUnit;

/**
 * Marker class that extends {@link BaseShopSteps}. Because the shared cart steps
 * are already implemented in the base class, the generated ShoppingCartScenarios
 * inherits them and declares abstract methods only for the remaining,
 * feature-specific steps.
 *
 * This package holds two co-located spec files, so the path is given explicitly
 * ("./" resolves against this package) — a bare @Gherkin2JUnit would pick up both.
 */
@Gherkin2JUnit("./ShoppingCart.specb")
public abstract class ShoppingCartFeature extends BaseShopSteps {
}
