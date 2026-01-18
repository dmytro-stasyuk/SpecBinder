package dev.specbinder.examples.featureprocessor;

import dev.specbinder.annotations.Feature2JUnit;

/**
 * Illustrates the mapping of Gherkin Rules to JUnit @Nested test classes, enabling hierarchical grouping
 * of related scenarios.
 * Each Rule's Background section becomes a @BeforeEach method within its corresponding nested class.
 */
@Feature2JUnit("features/FeatureWithRules.feature")
public abstract class FeatureWithRulesFeature {

    public void givenIAmNotLoggedIn() {
        // TODO: Implement step
    }

    public void whenIAdd$p1ToTheCart(String p1) {
        // TODO: Implement step with parameter: p1
    }

    public void thenIShouldSee$p1ItemInMyCart(String p1) {
        // TODO: Implement step with parameter: p1
    }

    public void givenIAmLoggedInAsAMember() {
        // TODO: Implement step
    }

    public void whenIAdd$p1PricedAt$p2ToTheCart(String p1, String p2) {
        // TODO: Implement step with parameters: p1, p2
    }

    public void thenTheDiscountedPriceShouldBe$p1(String p1) {
        // TODO: Implement step with parameter: p1
    }

    public void thenIShouldEarn$p1RewardPoints(String p1) {
        // TODO: Implement step with parameter: p1
    }
}
