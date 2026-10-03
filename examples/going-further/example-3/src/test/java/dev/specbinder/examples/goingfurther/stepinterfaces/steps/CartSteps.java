package dev.specbinder.examples.goingfurther.stepinterfaces.steps;

import dev.specbinder.examples.goingfurther.stepinterfaces.Cart;

/**
 * Cart-related step methods, grouped by domain. Implemented as {@code default}
 * methods so a marker class can pull them in simply by implementing the interface.
 * An interface can't hold state, so the steps work on the {@link Cart} returned by
 * {@link #cart()} — whoever runs the scenarios supplies it.
 */
public interface CartSteps {

    Cart cart();

    default void iHaveAnEmptyShoppingCart() {
        cart().clear();
    }

    default void iAdd$p1ToTheCart(String item) {
        cart().add(item);
    }
}
