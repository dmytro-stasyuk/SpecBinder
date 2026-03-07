package dev.specbinder.examples.commonusecases.optionsinheritance;

import dev.specbinder.annotations.Feature2JUnit;
import dev.specbinder.annotations.Feature2JUnitOptions;

/**
 * Inherits options from BaseFeature but overrides shouldBeAbstract.
 * - useStepKeywordInStepMethodName = true   ← inherited from BaseFeature
 * - tagForEmptyScenarios = "todo"           ← inherited from BaseFeature
 * - shouldBeAbstract = true                 ← overridden here
 */
@Feature2JUnitOptions(shouldBeAbstract = true)
@Feature2JUnit("specs/Checkout.feature")
public abstract class CheckoutFeature extends BaseFeature {
}
