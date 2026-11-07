package dev.specbinder.examples.goingfurther.localization;

/**
 * Tiny in-memory checkout shared by every test in this example, whatever language its spec is written in. Paying by
 * card marks a non-empty cart as paid and empties it; paying for an empty cart has no effect.
 */
public final class Checkout {

    private int itemCount;
    private boolean paid;

    public Checkout(int itemCount) {
        this.itemCount = itemCount;
    }

    public void payByCard() {
        if (itemCount > 0) {
            paid = true;
            itemCount = 0;
        }
    }

    public boolean isPaid() {
        return paid;
    }

    public int itemCount() {
        return itemCount;
    }
}
