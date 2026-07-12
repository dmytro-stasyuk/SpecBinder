package dev.specbinder.examples.gettingstarted.colocated;

import dev.specbinder.annotations.Gherkin2JUnit;

/**
 * No path in @Gherkin2JUnit — the processor discovers ShoppingCart.specb
 * automatically by looking for a .feature or .specb file with the same name
 * in the same package as this class.
 */
@Gherkin2JUnit
public abstract class ShoppingCart {
}
