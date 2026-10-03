package dev.specbinder.examples.commonusecases.optionsinheritance;

import dev.specbinder.annotations.Gherkin2JUnitOptions;

/**
 * Shared base class with @Gherkin2JUnitOptions.
 * All marker classes extending this class inherit these options.
 * Individual marker classes can selectively override specific options.
 */
@Gherkin2JUnitOptions(
        useStepKeywordInStepMethodName = true,
        classSuffixIfAbstract = "Spec"
)
public abstract class BaseFeature {
}
