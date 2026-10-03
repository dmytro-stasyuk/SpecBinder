package dev.specbinder.examples.migratingfromcucumber.cucumberannotations;

import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.annotations.Gherkin2JUnitOptions;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;

/**
 * Demonstrates addCucumberStepAnnotations option and annotation-based step matching.
 *
 * With useCucumberAnnotationsForStepMatching enabled, the generator matches the step methods
 * declared here by their Cucumber annotation pattern — NOT by method name. This means you can
 * use any method name you like, as long as the annotation pattern matches the Gherkin step text.
 * The declarations are abstract: ShoppingCartTest implements them.
 *
 * Both Cucumber expressions (e.g. {string}) and regular expressions (e.g. ^...$) are supported
 * for annotation-based matching. This example mixes both styles.
 *
 * One step — "the cart subtotal should be ..." — is deliberately not declared here. The generator
 * emits it itself, and addCucumberStepAnnotations puts a generated @Then annotation on it. And/But
 * steps inherit the keyword from the preceding Given/When/Then step.
 *
 * No path in @Gherkin2JUnit — the processor discovers the co-located ShoppingCart.feature in this
 * package by convention.
 */
@Gherkin2JUnitOptions(addCucumberStepAnnotations = true, useCucumberAnnotationsForStepMatching = true)
@Gherkin2JUnit
public abstract class ShoppingCartFeature {

    /**
     * Matched using a Cucumber expression pattern.
     * Method name is "startWithEmptyCart" — NOT the default "iHaveAnEmptyShoppingCart".
     */
    @Given("I have an empty shopping cart")
    public abstract void startWithEmptyCart();

    /**
     * Matched using a regular expression pattern (^...$).
     * Named capture group (?&lt;p1&gt;.*) matches the parameter.
     */
    @When("^I add (?<p1>.*) to the cart$")
    public abstract void addItemToCart(String item);

    /**
     * Matched using a regular expression pattern (^...$).
     */
    @Then("^the cart should contain (?<p1>.*) items$")
    public abstract void verifyCartSize(Integer expectedCount);

    /**
     * Matched using a regular expression pattern (^...$).
     */
    @Given("^I have a cart with subtotal (?<p1>.*)$")
    public abstract void setupCartWithSubtotal(Double amount);

    /**
     * Matched using a Cucumber expression pattern.
     */
    @When("I apply discount code {string}")
    public abstract void applyDiscount(String code);
}
