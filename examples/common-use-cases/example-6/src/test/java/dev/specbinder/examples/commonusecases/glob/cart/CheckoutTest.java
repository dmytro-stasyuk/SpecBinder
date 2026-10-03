package dev.specbinder.examples.commonusecases.glob.cart;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Concrete test for Checkout.specb, placed next to it. Steps that also appear in
 * other specs (an empty cart, a "should see" message) are declared separately by
 * each generated class, so this test implements its own copy — see the base-class
 * example (example-3) for sharing them instead.
 */
public class CheckoutTest extends CheckoutScenarios {

    private static final int CARD_NUMBER_LENGTH = 16;

    private int itemCount;
    private boolean checkoutStarted;
    private boolean orderConfirmed;
    private String message;

    @Override
    public void iHaveAnEmptyShoppingCart() {
        itemCount = 0;
    }

    @Override
    public void iHaveACartWith$p1Items(Integer count) {
        itemCount = count;
    }

    @Override
    public void iProceedToCheckout() {
        if (itemCount == 0) {
            message = "Cannot checkout with an empty cart";
            return;
        }
        checkoutStarted = true;
    }

    @Override
    public void iPayWithCard$p1(Long cardNumber) {
        orderConfirmed = checkoutStarted && String.valueOf(cardNumber).length() == CARD_NUMBER_LENGTH;
    }

    @Override
    public void theOrderShouldBeConfirmed() {
        assertTrue(orderConfirmed, "The order was not confirmed");
    }

    @Override
    public void iShouldSee$p1(String expectedMessage) {
        assertEquals(expectedMessage, message);
    }
}
