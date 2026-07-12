package dev.specbinder.examples.commonusecases.optionsinheritance;

import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.annotations.Gherkin2JUnitOptions;

/**
 * Inherits options from BaseFeature but overrides shouldBeAbstract.
 * - useStepKeywordInStepMethodName = true   ← inherited from BaseFeature
 * - tagForEmptyScenarios = "todo"           ← inherited from BaseFeature
 * - shouldBeAbstract = true                 ← overridden here
 */
@Gherkin2JUnitOptions(shouldBeAbstract = true)
@Gherkin2JUnit("specs/Checkout.feature")
public abstract class CheckoutFeature extends BaseFeature {
}
