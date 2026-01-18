package dev.specbinder.examples.featureprocessor;

import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import specs.ScenarioWithBackgroundScenarios;

public class ScenarioWithBackgroundTest extends ScenarioWithBackgroundScenarios {

    @Given("^I have a shopping cart$")
    public void givenIHaveAShoppingCart() {
        // TODO: Implement step
    }

    @Given("^the cart is empty$")
    public void givenTheCartIsEmpty() {
        // TODO: Implement step
    }

    @When("^I add (?<p1>.*) to the cart$")
    public void whenIAdd$p1ToTheCart(String p1) {
        // TODO: Implement step
    }

    @Then("^the cart should contain (?<p1>.*) item$")
    public void thenTheCartShouldContain$p1Item(String p1) {
        // TODO: Implement step
    }

    @Then("^the cart should contain (?<p1>.*) items$")
    public void thenTheCartShouldContain$p1Items(String p1) {
        // TODO: Implement step
    }
}
