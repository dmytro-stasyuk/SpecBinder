package dev.specbinder.examples.goingfurther.stepinterfaces.steps;

/**
 * Checkout-related step methods, grouped by domain. Implemented as {@code default}
 * methods so a marker class can pull them in simply by implementing the interface.
 */
public interface CheckoutSteps {

    default void iProceedToCheckout() {
        // shared checkout implementation
    }

    default void iPayWithCard$p1(String cardNumber) {
        // shared checkout implementation
    }

    default void theOrderShouldBeConfirmed() {
        // shared checkout implementation
    }
}
