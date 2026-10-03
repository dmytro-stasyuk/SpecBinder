package dev.specbinder.examples.goingfurther.multipletests;

import java.math.BigDecimal;
import java.math.RoundingMode;

/** The business logic used by every entry point, including the web application. */
public final class CartPricingService {

    /** Creates the pricing service; it holds no state. */
    public CartPricingService() {
    }

    /**
     * Calculates the cart total after the discount, rounded half-up to two decimal places.
     *
     * @param quantity        number of items in the cart; must not be negative
     * @param unitPrice       price of a single item; must not be negative
     * @param discountPercent discount to apply, from 0 to 100
     * @return the discounted total, with a scale of 2
     * @throws IllegalArgumentException if any argument is out of range
     */
    public BigDecimal total(int quantity, BigDecimal unitPrice, int discountPercent) {
        if (quantity < 0 || unitPrice.signum() < 0 || discountPercent < 0 || discountPercent > 100) {
            throw new IllegalArgumentException("Invalid quantity, price or discount");
        }
        return unitPrice.multiply(BigDecimal.valueOf(quantity))
                .multiply(BigDecimal.valueOf(100 - discountPercent))
                .movePointLeft(2)
                .setScale(2, RoundingMode.HALF_UP);
    }
}
