package dev.specbinder.examples.featureprocessor;

import dev.specbinder.annotations.Feature2JUnit;

/**
 * Demonstrates the simplest example of Gherkin-to-JUnit conversion.
 * Shows how basic Given/When/Then steps are converted to abstract method calls in a generated test class.
 */
@Feature2JUnit("features/SimpleScenario.feature")
public abstract class SimpleScenarioFeature {

    public void givenIHaveACalculator() {
        // TODO: Implement step
    }

    public void givenIHaveEntered$p1IntoTheCalculator(String p1) {
        // TODO: Implement step with parameter: p1
    }

    public void whenIPressAdd() {
        // TODO: Implement step
    }

    public void thenTheResultShouldBe$p1(String p1) {
        // TODO: Implement step with parameter: p1
    }
}
