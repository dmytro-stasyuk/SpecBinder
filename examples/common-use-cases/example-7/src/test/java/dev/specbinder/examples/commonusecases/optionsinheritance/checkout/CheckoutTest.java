package dev.specbinder.examples.commonusecases.optionsinheritance.checkout;

import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Concrete test for Checkout.specb. It still extends a "Spec" class
 * (classSuffixIfAbstract inherited from BaseFeature), but its step methods have
 * no keyword prefix, because CheckoutFeature overrides useStepKeywordInStepMethodName.
 */
public class CheckoutTest extends CheckoutSpec {

    private static final int CARD_NUMBER_LENGTH = 16;

    private int itemCount;
    private boolean checkoutStarted;
    private boolean orderConfirmed;

    @Override
    public void iHaveACartWith$p1Items(Integer count) {
        itemCount = count;
    }

    @Override
    public void iProceedToCheckout() {
        checkoutStarted = itemCount > 0;
    }

    @Override
    public void iPayWithCard$p1(Long cardNumber) {
        orderConfirmed = checkoutStarted && String.valueOf(cardNumber).length() == CARD_NUMBER_LENGTH;
    }

    @Override
    public void theOrderShouldBeConfirmed() {
        assertTrue(orderConfirmed, "The order was not confirmed");
    }
}
