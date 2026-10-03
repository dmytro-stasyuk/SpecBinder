package dev.specbinder.examples.goingfurther.stepinterfaces;

import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.examples.goingfurther.stepinterfaces.steps.CartSteps;
import dev.specbinder.examples.goingfurther.stepinterfaces.steps.CheckoutSteps;

/**
 * Marker class that organizes its step methods into domain interfaces
 * ({@link CartSteps}, {@link CheckoutSteps}) instead of declaring them all
 * inline. The generator sees the step methods inherited through these
 * interfaces and does not emit abstract declarations for them, so the
 * generated class inherits the shared implementations. The only thing left abstract is
 * the {@code cart()} accessor both interfaces declare — ShoppingCartTest supplies it.
 *
 * No path in @Gherkin2JUnit — the processor discovers the co-located ShoppingCart.specb
 * in this package by convention.
 */
@Gherkin2JUnit
public abstract class ShoppingCartFeature implements CartSteps, CheckoutSteps {
}
