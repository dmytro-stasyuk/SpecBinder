package dev.specbinder.examples.reporter;

/**
 * Tiny in-memory shopping cart used by the example's step implementations.
 * Tracks a single subtotal — adding an item adds {@code price × quantity}; applying
 * a known discount code reduces the subtotal by a percentage; unknown codes are no-ops.
 */
public class Cart {

    private double subtotal;

    public Cart() {
        this.subtotal = 0.0;
    }

    public void setSubtotal(double subtotal) {
        this.subtotal = subtotal;
    }

    public double subtotal() {
        return subtotal;
    }

    public void addItem(double unitPrice, int quantity) {
        subtotal += unitPrice * quantity;
    }

    public void applyDiscountCode(String code) {
        if ("SAVE10".equals(code)) {
            subtotal *= 0.9;
        }
        // any other code: no effect
    }
}
