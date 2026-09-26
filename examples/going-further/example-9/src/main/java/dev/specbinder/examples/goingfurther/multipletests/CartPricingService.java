package dev.specbinder.examples.goingfurther.multipletests;

import java.math.BigDecimal;
import java.math.RoundingMode;

/** The business logic used by every entry point, including the web application. */
public final class CartPricingService {

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
