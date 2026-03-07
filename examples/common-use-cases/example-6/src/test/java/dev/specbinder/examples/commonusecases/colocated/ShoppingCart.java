package dev.specbinder.examples.commonusecases.colocated;

import dev.specbinder.annotations.Feature2JUnit;

/**
 * No path in @Feature2JUnit — the processor discovers ShoppingCart.feature
 * automatically by looking for a .feature file with the same name
 * in the same package as this class.
 */
@Feature2JUnit
public abstract class ShoppingCart {
}
