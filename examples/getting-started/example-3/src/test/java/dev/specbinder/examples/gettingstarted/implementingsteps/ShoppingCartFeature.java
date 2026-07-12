package dev.specbinder.examples.gettingstarted.implementingsteps;

import dev.specbinder.annotations.Gherkin2JUnit;

/**
 * Marker class. Abstract mode is the default, so the generator emits an
 * abstract class (ShoppingCartScenarios) with one abstract method per step
 * and one @Test method per scenario. You implement those step methods in a
 * concrete subclass — see ShoppingCartTest.
 */
@Gherkin2JUnit("specs/ShoppingCart.feature")
public abstract class ShoppingCartFeature {
}
