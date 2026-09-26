package dev.specbinder.examples.goingfurther.multipletests;

import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Always rounds up to the next cent — a configuration that never charges less than the exact amount.
 *
 * <p>It agrees with {@link HalfUpPricing} on every amount that already lands on a cent, so only the
 * scenario whose discount falls between cents tells the two apart.
 */
public final class RoundUpPricing implements PricingEngine {

    @Override
    public BigDecimal charge(BigDecimal exact) {
        return exact.setScale(2, RoundingMode.CEILING);
    }
}
