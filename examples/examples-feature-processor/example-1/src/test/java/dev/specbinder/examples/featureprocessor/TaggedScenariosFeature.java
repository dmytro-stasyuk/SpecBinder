package dev.specbinder.examples.featureprocessor;

import dev.specbinder.annotations.Feature2JUnit;

/**
 * Demonstrates how Gherkin tags are converted to JUnit @Tag annotations.
 * Tags enable selective test execution and categorization (e.g., @smoke, @regression, @critical).
 */
@Feature2JUnit("features/TaggedScenarios.feature")
public abstract class TaggedScenariosFeature {

    public void givenIAmOnTheLoginPage() {
        // TODO: Implement step
    }

    public void whenIEnterValidCredentials() {
        // TODO: Implement step
    }

    public void thenIShouldBeLoggedInSuccessfully() {
        // TODO: Implement step
    }

    public void whenIClick$p1(String p1) {
        // TODO: Implement step with parameter: p1
    }

    public void thenIShouldSeeThePasswordResetPage() {
        // TODO: Implement step
    }
}
