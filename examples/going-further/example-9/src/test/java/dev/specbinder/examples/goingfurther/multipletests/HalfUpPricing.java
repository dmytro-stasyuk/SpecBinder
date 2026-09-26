package dev.specbinder.examples.goingfurther.multipletests;

import java.math.BigDecimal;
import java.math.RoundingMode;

/** Rounds to the nearest cent, half a cent going up — what most storefronts do. */
public final class HalfUpPricing implements PricingEngine {

    @Override
    public BigDecimal charge(BigDecimal exact) {
        return exact.setScale(2, RoundingMode.HALF_UP);
    }
}
