package dev.specbinder.examples.featureprocessor;

import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import specs.SimpleCalculatorScenarios;

public class SimpleCalculatorTest extends SimpleCalculatorScenarios {

    @Override
    @Given("^I have a calculator$")
    public void givenIHaveACalculator() {
        // TODO: Implement step
    }

    @Override
    @Given("^I have entered (?<p1>.*) into the calculator$")
    public void givenIHaveEntered$p1IntoTheCalculator(String p1) {
        // TODO: Implement step
    }

    @Override
    @When("^I press add$")
    public void whenIPressAdd() {
        // TODO: Implement step
    }

    @Override
    @Then("^the result should be (?<p1>.*)$")
    public void thenTheResultShouldBe$p1(String p1) {
        // TODO: Implement step
    }
}
