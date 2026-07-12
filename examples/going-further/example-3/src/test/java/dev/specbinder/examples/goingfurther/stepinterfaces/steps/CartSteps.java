package dev.specbinder.examples.goingfurther.stepinterfaces.steps;

/**
 * Cart-related step methods, grouped by domain. Implemented as {@code default}
 * methods so a marker class can pull them in simply by implementing the interface.
 */
public interface CartSteps {

    default void iHaveAnEmptyShoppingCart() {
        // shared cart implementation
    }

    default void iAdd$p1ToTheCart(String item) {
        // shared cart implementation
    }
}
