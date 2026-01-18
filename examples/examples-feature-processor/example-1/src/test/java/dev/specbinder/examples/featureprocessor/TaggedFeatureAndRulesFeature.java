package dev.specbinder.examples.featureprocessor;

import dev.specbinder.annotations.Feature2JUnit;

/**
 * Demonstrates how Gherkin tags can be applied at multiple levels: Feature, Rule, and Scenario.
 * Feature-level tags apply to the entire test class, Rule-level tags apply to nested classes,
 * and Scenario-level tags apply to individual test methods.
 */
@Feature2JUnit("features/TaggedFeatureAndRules.feature")
public abstract class TaggedFeatureAndRulesFeature {

    public void givenIHaveAValidCreditCard() {
        // TODO: Implement step
    }

    public void whenIProcessAPaymentOf$p1(String p1) {
        // TODO: Implement step with parameter: p1
    }

    public void thenThePaymentShouldBeSuccessful() {
        // TODO: Implement step
    }

    public void givenIHaveAPaymentRequest() {
        // TODO: Implement step
    }

    public void whenIValidateThePayment() {
        // TODO: Implement step
    }

    public void thenValidationShouldCompleteQuickly() {
        // TODO: Implement step
    }

    public void givenIHaveADomesticAddress() {
        // TODO: Implement step
    }

    public void whenICalculateShippingCost() {
        // TODO: Implement step
    }

    public void thenTheCostShouldBe$p1(String p1) {
        // TODO: Implement step with parameter: p1
    }

    public void givenIHaveAnInternationalAddress() {
        // TODO: Implement step
    }
}
