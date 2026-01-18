package dev.specbinder.examples.featureprocessor;

import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import specs.ShoppingCartScenarios;

public class ShoppingCartTest extends ShoppingCartScenarios {

    @Override
    public void givenIAmNotLoggedIn() {
        // TODO: Implement step
    }

    @When("^I add (?<p1>.*) to the cart$")
    public void whenIAdd$p1ToTheCart(String p1) {
        // TODO: Implement step
    }

    @Then("^I should see (?<p1>.*) item in my cart$")
    public void thenIShouldSee$p1ItemInMyCart(String p1) {
        // TODO: Implement step
    }

    @Override
    public void givenIAmLoggedInAsAMember() {
        // TODO: Implement step
    }

    @When("^I add (?<p1>.*) priced at (?<p2>.*) to the cart$")
    public void whenIAdd$p1PricedAt$p2ToTheCart(String p1, String p2) {
        // TODO: Implement step
    }

    @Then("^the discounted price should be (?<p1>.*)$")
    public void thenTheDiscountedPriceShouldBe$p1(String p1) {
        // TODO: Implement step
    }

    @Then("^I should earn (?<p1>.*) reward points$")
    public void thenIShouldEarn$p1RewardPoints(String p1) {
        // TODO: Implement step
    }

    @Given("^I have a shopping cart$")
    public void givenIHaveAShoppingCart() {
        // TODO: Implement step
    }

    @Given("^the cart is empty$")
    public void givenTheCartIsEmpty() {
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
