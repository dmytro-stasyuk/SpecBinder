package dev.specbinder.examples.goingfurther.stepinterfaces;

import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.examples.goingfurther.stepinterfaces.steps.CartSteps;
import dev.specbinder.examples.goingfurther.stepinterfaces.steps.CheckoutSteps;

/**
 * Marker class that organizes its step methods into domain interfaces
 * ({@link CartSteps}, {@link CheckoutSteps}) instead of declaring them all
 * inline. The generator sees the step methods inherited through these
 * interfaces and does not emit abstract declarations for them, so the
 * generated class inherits the shared implementations.
 */
@Gherkin2JUnit("specs/ShoppingCart.specb")
public abstract class ShoppingCartFeature implements CartSteps, CheckoutSteps {
}
