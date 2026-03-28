package dev.specbinder.examples.commonusecases.abstractmode;

import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.annotations.Gherkin2JUnitOptions;

/**
 * Marker class with abstract mode enabled.
 * The generator produces an abstract class (ShoppingCartScenarios)
 * with abstract step methods — but any step methods already implemented
 * here in the marker class are inherited directly (no abstract declaration generated).
 */
@Gherkin2JUnitOptions(shouldBeAbstract = true)
@Gherkin2JUnit("specs/ShoppingCart.feature")
public abstract class ShoppingCartFeature {

    protected double subtotal;
    protected String banner;

    /**
     * This step method is implemented in the marker class.
     * The generator detects it and does NOT generate an abstract declaration —
     * the generated class simply inherits this method.
     */
    public void myCartSubtotalIs$p1(Double amount) {
        subtotal = amount;
    }

    /**
     * Another step method implemented in the marker class.
     * Also inherited — no abstract declaration generated.
     */
    public void iViewTheCart() {
        banner = subtotal >= 50.0 ? "Free shipping" : "Shipping: 5.99";
    }
}
