package dev.specbinder.examples.commonusecases.glob;

import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.examples.commonusecases.glob.steps.CartSteps;
import dev.specbinder.examples.commonusecases.glob.steps.CheckoutSteps;
import dev.specbinder.examples.commonusecases.glob.steps.LoginSteps;
import dev.specbinder.examples.commonusecases.glob.steps.RegistrationSteps;

/**
 * Single marker class that discovers all feature files recursively
 * using a glob pattern. Step methods are organized in separate
 * interfaces by domain area.
 */
@Gherkin2JUnit("specs/**/*.feature")
public abstract class AllFeatures implements CartSteps, CheckoutSteps, LoginSteps, RegistrationSteps {
}
