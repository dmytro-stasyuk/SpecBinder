package dev.specbinder.examples.goingfurther.cucumberannotations;

import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.annotations.Gherkin2JUnitOptions;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;

import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Demonstrates addCucumberStepAnnotations option and annotation-based step matching.
 *
 * The generator adds @Given/@When/@Then annotations to step methods with a pattern
 * matching the original Gherkin step text. And/But steps inherit the keyword from the
 * preceding Given/When/Then step.
 *
 * With useCucumberAnnotationsForStepMatching enabled, the generator matches
 * inherited step methods by their Cucumber annotation pattern — NOT by method name.
 * This means you can use any method name you like, as long as the annotation pattern
 * matches the Gherkin step text.
 *
 * Both Cucumber expressions (e.g. {string}) and regular expressions (e.g. ^...$)
 * are supported for annotation-based matching. This example mixes both styles.
 */
@Gherkin2JUnitOptions(addCucumberStepAnnotations = true, useCucumberAnnotationsForStepMatching = true)
@Gherkin2JUnit("specs/ShoppingCart.feature")
public abstract class ShoppingCartFeature {

    private final List<String> cart = new ArrayList<>();
    private double subtotal;

    /**
     * Matched using a Cucumber expression pattern.
     * Method name is "startWithEmptyCart" — NOT the default "iHaveAnEmptyShoppingCart".
     */
    @Given("I have an empty shopping cart")
    public void startWithEmptyCart() {
        cart.clear();
    }

    /**
     * Matched using a regular expression pattern (^...$).
     * Named capture group (?&lt;p1&gt;.*) matches the parameter.
     */
    @When("^I add (?<p1>.*) to the cart$")
    public void addItemToCart(String item) {
        cart.add(item);
    }

    /**
     * Matched using a regular expression pattern (^...$).
     */
    @Then("^the cart should contain (?<p1>.*) items$")
    public void verifyCartSize(Integer expectedCount) {
        assertEquals(expectedCount, cart.size());
    }

    /**
     * Matched using a regular expression pattern (^...$).
     */
    @Given("^I have a cart with subtotal (?<p1>.*)$")
    public void setupCartWithSubtotal(Double amount) {
        subtotal = amount;
    }

    /**
     * Matched using a Cucumber expression pattern.
     */
    @When("I apply discount code {string}")
    public void applyDiscount(String code) {
        if ("SAVE10".equals(code)) {
            subtotal *= 0.9;
        }
    }

    /**
     * Matched using a Cucumber expression pattern.
     */
    @Then("the cart subtotal should be {string}")
    public void verifySubtotal(Double expected) {
        assertEquals(expected, subtotal, 0.001);
    }
}
