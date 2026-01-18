package dev.specbinder.examples.featureprocessor;

import dev.specbinder.annotations.Feature2JUnit;

/**
 * Demonstrates how Gherkin Scenario Outlines are converted to JUnit @ParameterizedTest methods.
 * Examples tables are mapped to @CsvSource, enabling data-driven testing with multiple input combinations.
 */
@Feature2JUnit("features/ScenarioOutline.feature")
public abstract class ScenarioOutlineFeature {

    public void givenIHaveAProductPricedAt$p1(String p1) {
        // TODO: Implement step with parameter: p1
    }

    public void whenIApplyADiscountOf$p1Percent(String p1) {
        // TODO: Implement step with parameter: p1
    }

    public void thenTheFinalPriceShouldBe$p1(String p1) {
        // TODO: Implement step with parameter: p1
    }
}
