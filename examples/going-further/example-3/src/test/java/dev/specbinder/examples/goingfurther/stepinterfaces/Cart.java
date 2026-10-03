package dev.specbinder.examples.goingfurther.stepinterfaces;

import java.util.ArrayList;
import java.util.List;

/**
 * Tiny in-memory cart and checkout used by the step interfaces. The interfaces hold
 * the step logic but no state; the concrete test owns one Cart per test and hands it
 * to them through {@code cart()}.
 */
public class Cart {

    private static final int CARD_NUMBER_LENGTH = 16;

    private final List<String> items = new ArrayList<>();
    private boolean checkoutStarted;
    private boolean orderConfirmed;

    public void clear() {
        items.clear();
    }

    public void add(String item) {
        items.add(item);
    }

    public void startCheckout() {
        checkoutStarted = !items.isEmpty();
    }

    public void pay(String cardNumber) {
        orderConfirmed = checkoutStarted && cardNumber.length() == CARD_NUMBER_LENGTH;
    }

    public boolean isOrderConfirmed() {
        return orderConfirmed;
    }
}
