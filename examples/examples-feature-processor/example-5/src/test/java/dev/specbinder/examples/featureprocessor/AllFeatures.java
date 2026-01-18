package dev.specbinder.examples.featureprocessor;

import dev.specbinder.annotations.Feature2JUnit;
import dev.specbinder.examples.featureprocessor.steps.*;
import org.junit.jupiter.api.Assertions;

/**
 * Demonstrates using glob patterns in {@code @Feature2JUnit} annotation to match multiple feature files.
 * The pattern "specs/**" will match all .feature files in the specs directory and its subdirectories.
 * For each matching feature file, the processor generates a separate test class named after the feature file.
 * All generated classes share the same package and extend this base class.
 */
@Feature2JUnit("specs/**/*.feature")
public abstract class AllFeatures implements CheckoutSteps, DashboardSteps, LoginSteps,
        PasswordSteps, ProfileSteps, EmailSteps, UserManagementSteps, RegistrationSteps {

    public void givenTheUserIsOnTheHomePage() {
        Assertions.fail("Step is not yet implemented");
    }

    public void whenTheUserEnters$p1InTheSearchBox(String p1) {
        Assertions.fail("Step is not yet implemented");
    }

    public void whenTheUserClicksTheSearchButton() {
        Assertions.fail("Step is not yet implemented");
    }
}
