package dev.specbinder.examples.featureprocessor.steps;

public interface CheckoutSteps {

    default void givenTheUserHasItemsInTheCart() {
        // TODO: Implement step
    }

    default void givenTheUserIsOnTheCheckoutPage() {
        // TODO: Implement step
    }

    default void whenTheUserEntersShippingAddress$p1(String p1) {
        // TODO: Implement step
    }

    default void whenTheUserEntersPaymentDetails$p1(String p1) {
        // TODO: Implement step
    }

    default void whenTheUserConfirmsTheOrder() {
        // TODO: Implement step
    }

    default void thenTheOrderShouldBePlacedSuccessfully() {
        // TODO: Implement step
    }

    default void thenAnOrderConfirmationShouldBeDisplayed() {
        // TODO: Implement step
    }
}
