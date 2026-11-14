package dev.specbinder.examples.goingfurther.compositesteps;

import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.annotations.Gherkin2JUnitOptions;

/**
 * Marker class for the Checkout spec. It turns on composite steps; the step methods live in CheckoutTest.
 * <p>
 * With {@code enableCompositeSteps = true}, a step directly followed by {@code *} steps becomes a composite step. The
 * generated CheckoutScenarios gives it a composite method taking the step's values and a lambda that calls its
 * sub-steps in order; each sub-step gets an ordinary step method, the same one it would get written on its own.
 * <p>
 * No path in @Gherkin2JUnit — the processor discovers the co-located Checkout.specb in this package by convention.
 */
@Gherkin2JUnit
@Gherkin2JUnitOptions(enableCompositeSteps = true)
public abstract class CheckoutFeature {
}
