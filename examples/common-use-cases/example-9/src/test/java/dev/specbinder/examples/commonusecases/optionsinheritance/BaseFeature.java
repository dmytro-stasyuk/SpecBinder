package dev.specbinder.examples.commonusecases.optionsinheritance;

import dev.specbinder.annotations.Feature2JUnitOptions;

/**
 * Shared base class with @Feature2JUnitOptions.
 * All marker classes extending this class inherit these options.
 * Individual marker classes can selectively override specific options.
 */
@Feature2JUnitOptions(
        useStepKeywordInStepMethodName = true,
        tagForEmptyScenarios = "todo",
        tagForEmptyRules = "todo"
)
public abstract class BaseFeature {
}
