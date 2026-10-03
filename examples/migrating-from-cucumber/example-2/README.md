# Example 2: Cucumber Step Annotations & Annotation-Based Step Matching

Demonstrates two related features: generating `@Given`/`@When`/`@Then` Cucumber annotations on step methods, and using those annotations for step matching when inheriting methods from the marker class.

## What this demonstrates

### 1. Generating Cucumber annotations (`addCucumberStepAnnotations`)

- `@Gherkin2JUnitOptions(addCucumberStepAnnotations = true)` adds Cucumber annotations
- Each step method gets a `@Given`, `@When`, or `@Then` annotation with a pattern matching the original Gherkin step text
- `And`/`But` steps inherit the keyword from the preceding `Given`/`When`/`Then` step
- Requires `cucumber-java` dependency

### 2. Annotation-based step matching (`useCucumberAnnotationsForStepMatching`)

- `useCucumberAnnotationsForStepMatching` defaults to `false`; this example opts in with `@Gherkin2JUnitOptions(..., useCucumberAnnotationsForStepMatching = true)`
- When the generator looks for steps already declared in the marker class, it matches by **Cucumber annotation pattern** — not by method name
- This means you can use **any method name** you like, as long as the `@Given`/`@When`/`@Then` annotation pattern matches the Gherkin step text
- The generator recognises the declared method, calls it from the scenario, and does not emit its own declaration
- The declarations can be abstract — here the marker declares them and the concrete `ShoppingCartTest` implements them

### 3. Both Cucumber expressions and regular expressions are supported

The annotation-based matching mechanism supports two pattern styles:

- **Cucumber expressions** — e.g. `@When("I apply discount code {string}")`
- **Regular expressions** — e.g. `@When("^I add \"([^\"]*)\" to the cart$")`

Both are equally valid for matching. This example mixes both styles to demonstrate that either can be used.

## Custom method names with annotation matching

In this example, the marker class declares five of the six steps, as abstract methods with descriptive names instead of
the default generated names:

| Gherkin step | Custom method name | Pattern style | Annotation |
|---|---|---|---|
| `Given I have an empty shopping cart` | `startWithEmptyCart()` | Cucumber expression | `@Given("I have an empty shopping cart")` |
| `When I add "..." to the cart` | `addItemToCart()` | Regular expression | `@When("^I add (?<p1>.*) to the cart$")` |
| `Then the cart should contain "..." items` | `verifyCartSize()` | Regular expression | `@Then("^the cart should contain (?<p1>.*) items$")` |
| `Given I have a cart with subtotal "..."` | `setupCartWithSubtotal()` | Regular expression | `@Given("^I have a cart with subtotal (?<p1>.*)$")` |
| `When I apply discount code "..."` | `applyDiscount()` | Cucumber expression | `@When("I apply discount code {string}")` |

The generator detects these methods via their annotation patterns and calls them from the scenarios — it emits no
declarations of its own for them:

```java
@Gherkin2JUnitOptions(addCucumberStepAnnotations = true, useCucumberAnnotationsForStepMatching = true)
@Gherkin2JUnit
public abstract class ShoppingCartFeature {

    @Given("I have an empty shopping cart")
    public abstract void startWithEmptyCart();

    @When("^I add (?<p1>.*) to the cart$")
    public abstract void addItemToCart(String item);

    // ...
}
```

## Generated output

The sixth step, `Then the cart subtotal should be "..."`, is deliberately not declared in the marker. The generator
emits it itself — and because `addCucumberStepAnnotations` is on, with a generated `@Then` annotation:

```java
public abstract class ShoppingCartScenarios extends ShoppingCartFeature {

    @Test
    @DisplayName("Scenario: Add item and verify cart")
    public void scenario_1() {
        startWithEmptyCart();
        addItemToCart("Wireless Headphones");
        addItemToCart("Coffee Beans");
        verifyCartSize(2);
    }

    @Then("^the cart subtotal should be (?<p1>.*)$")
    public abstract void theCartSubtotalShouldBe$p1(Double p1);

    @Test
    @DisplayName("Scenario: Apply discount code")
    public void scenario_2() {
        setupCartWithSubtotal(100.00);
        applyDiscount("SAVE10");
        theCartSubtotalShouldBe$p1(90.00);
    }
}
```

The concrete `ShoppingCartTest` implements all six: the five custom-named declarations and the generated one.

## Class hierarchy

```
ShoppingCartFeature.java          (marker — custom-named, annotated step declarations)
  └→ ShoppingCartScenarios.java   (generated, abstract — calls them, adds the one missing step)
      └→ ShoppingCartTest.java    (your concrete class, implements all steps)
```

## Files

| File | Purpose |
|------|---------|
| `src/test/java/.../ShoppingCart.feature` | Feature with Given/When/And/Then steps, co-located with its marker |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class declaring custom-named step methods matched by both Cucumber expression and regex annotation patterns |
| `src/test/java/.../ShoppingCartTest.java` | Concrete test implementing the declared steps and the generated one |
| `pom.xml` | Includes `cucumber-java` dependency |
