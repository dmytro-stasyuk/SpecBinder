package dev.specbinder.examples.goingfurther.multipletests;

import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.annotations.Gherkin2JUnitOptions;
import dev.specbinder.reporter.SpecBinderReporter;
import org.junit.jupiter.api.extension.ExtendWith;

/**
 * One behavioural contract. Each concrete test implements these steps at its own application layer.
 * SpecBinder generates the abstract CartPricingScenarios class; all three tests inherit its scenarios.
 */
@Gherkin2JUnit("specs/CartPricing.specb")
@Gherkin2JUnitOptions(descriptionAsAnnotation = true)
@ExtendWith(SpecBinderReporter.class)
public abstract class CartPricingFeature {
    public abstract void aCartHolding$p1ItemsPriced$p2(Integer quantity, String unitPrice);

    public abstract void aDiscountOf$p1PercentIsApplied(Integer percent);

    public abstract void theCartTotalShouldBe$p1(String expected);
}
