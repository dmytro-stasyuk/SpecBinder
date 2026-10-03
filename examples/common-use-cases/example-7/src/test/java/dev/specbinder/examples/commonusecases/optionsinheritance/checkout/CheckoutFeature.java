package dev.specbinder.examples.commonusecases.optionsinheritance.checkout;

import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.annotations.Gherkin2JUnitOptions;
import dev.specbinder.examples.commonusecases.optionsinheritance.BaseFeature;

/**
 * Inherits options from BaseFeature but overrides one of them:
 * - useStepKeywordInStepMethodName = false  ← overridden here: iHaveACartWith$p1Items, no keyword prefix
 * - classSuffixIfAbstract = "Spec"          ← still inherited: generates CheckoutSpec
 *
 * No path in @Gherkin2JUnit — the processor discovers the co-located
 * Checkout.specb in this package by convention.
 */
@Gherkin2JUnitOptions(useStepKeywordInStepMethodName = false)
@Gherkin2JUnit
public abstract class CheckoutFeature extends BaseFeature {
}
