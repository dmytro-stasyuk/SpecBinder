package dev.specbinder.examples.goingfurther.localization.narrative;

import dev.specbinder.examples.goingfurther.localization.Checkout;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class CheckoutNarrativeTest extends CheckoutNarrativeScenarios {

    private Checkout checkout;

    @Override
    public void aCartWith$p1Items(Integer itemCount) {
        checkout = new Checkout(itemCount);
    }

    @Override
    public void iPayByCard() {
        checkout.payByCard();
    }

    @Override
    public void theOrderStatusIs$p1(String expectedStatus) {
        assertEquals(expectedStatus, checkout.isPaid() ? "paid" : "open");
    }

    @Override
    public void theCartIsEmpty() {
        assertEquals(0, checkout.itemCount());
    }
}
