package dev.specbinder.examples.featureprocessor;

import dev.specbinder.annotations.Feature2JUnit;

/**
 * Demonstrates how Gherkin Background sections are converted to JUnit @BeforeEach methods.
 * The Background steps execute before each scenario in the feature, providing common setup logic.
 */
@Feature2JUnit("features/ScenarioWithBackground.feature")
public abstract class ScenarioWithBackgroundFeature {

    public void givenIHaveAShoppingCart() {
        // TODO: Implement step
    }

    public void givenTheCartIsEmpty() {
        // TODO: Implement step
    }

    public void whenIAdd$p1ToTheCart(String p1) {
        // TODO: Implement step with parameter: p1
    }

    public void thenTheCartShouldContain$p1Item(String p1) {
        // TODO: Implement step with parameter: p1
    }

    public void thenTheCartShouldContain$p1Items(String p1) {
        // TODO: Implement step with parameter: p1
    }
}
