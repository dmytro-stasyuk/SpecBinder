package dev.specbinder.examples.goingfurther.stepinterfaces.steps;

import dev.specbinder.examples.goingfurther.stepinterfaces.Cart;

import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Checkout-related step methods, grouped by domain. Implemented as {@code default}
 * methods so a marker class can pull them in simply by implementing the interface.
 * Like {@link CartSteps}, they work on the {@link Cart} returned by {@link #cart()},
 * so cart and checkout steps share the same state.
 */
public interface CheckoutSteps {

    Cart cart();

    default void iProceedToCheckout() {
        cart().startCheckout();
    }

    default void iPayWithCard$p1(String cardNumber) {
        cart().pay(cardNumber);
    }

    default void theOrderShouldBeConfirmed() {
        assertTrue(cart().isOrderConfirmed(), "The order was not confirmed");
    }
}
