package dev.specbinder.examples.commonusecases.optionsinheritance;

import dev.specbinder.annotations.Gherkin2JUnitOptions;

/**
 * Shared base class with @Gherkin2JUnitOptions.
 * All marker classes extending this class inherit these options.
 * Individual marker classes can selectively override specific options.
 */
@Gherkin2JUnitOptions(
        useStepKeywordInStepMethodName = true,
        tagForEmptyScenarios = "todo",
        tagForEmptyRules = "todo"
)
public abstract class BaseFeature {
}
