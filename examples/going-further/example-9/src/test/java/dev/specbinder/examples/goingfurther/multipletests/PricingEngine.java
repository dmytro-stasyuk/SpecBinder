package dev.specbinder.examples.goingfurther.multipletests;

import java.math.BigDecimal;

/**
 * How a configuration turns an exact amount into the amount actually charged.
 *
 * <p>The two implementations differ only in rounding, which is enough for the same spec to pass under
 * one and fail under the other — the situation this example exists to show.
 */
public interface PricingEngine {

    /** The charged amount for {@code exact}, in whole cents. */
    BigDecimal charge(BigDecimal exact);
}
