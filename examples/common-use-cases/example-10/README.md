# Example 10: Cucumber Step Annotations & Annotation-Based Step Matching

Demonstrates two related features: generating `@Given`/`@When`/`@Then` Cucumber annotations on step methods, and using those annotations for step matching when inheriting methods from the marker class.

## What this demonstrates

### 1. Generating Cucumber annotations (`addCucumberStepAnnotations`)

- `@Gherkin2JUnitOptions(addCucumberStepAnnotations = true)` adds Cucumber annotations
- Each step method gets a `@Given`, `@When`, or `@Then` annotation with a pattern matching the original Gherkin step text
- `And`/`But` steps inherit the keyword from the preceding `Given`/`When`/`Then` step
- Requires `cucumber-java` dependency

### 2. Annotation-based step matching (`useCucumberAnnotationsForStepMatching`)

- `useCucumberAnnotationsForStepMatching` defaults to `false`; this example opts in with `@Gherkin2JUnitOptions(..., useCucumberAnnotationsForStepMatching = true)`
- When the generator looks for already-implemented steps in the marker class, it matches by **Cucumber annotation pattern** — not by method name
- This means you can use **any method name** you like, as long as the `@Given`/`@When`/`@Then` annotation pattern matches the Gherkin step text
- The generator recognises the inherited method and does not emit a stub for it

### 3. Both Cucumber expressions and regular expressions are supported

The annotation-based matching mechanism supports two pattern styles:

- **Cucumber expressions** — e.g. `@When("I apply discount code {string}")`
- **Regular expressions** — e.g. `@When("^I add \"([^\"]*)\" to the cart$")`

Both are equally valid for matching. This example mixes both styles to demonstrate that either can be used.

## Custom method names with annotation matching

In this example, all step methods in the marker class use descriptive names instead of the default generated names:

| Gherkin step | Custom method name | Pattern style | Annotation |
|---|---|---|---|
| `Given I have an empty shopping cart` | `startWithEmptyCart()` | Cucumber expression | `@Given("I have an empty shopping cart")` |
| `When I add "..." to the cart` | `addItemToCart()` | Regular expression | `@When("^I add (?<p1>.*) to the cart$")` |
| `Then the cart should contain "..." items` | `verifyCartSize()` | Regular expression | `@Then("^the cart should contain (?<p1>.*) items$")` |
| `Given I have a cart with subtotal "..."` | `setupCartWithSubtotal()` | Regular expression | `@Given("^I have a cart with subtotal (?<p1>.*)$")` |
| `When I apply discount code "..."` | `applyDiscount()` | Cucumber expression | `@When("I apply discount code {string}")` |
| `Then the cart subtotal should be "..."` | `verifySubtotal()` | Cucumber expression | `@Then("the cart subtotal should be {string}")` |

The generator detects these methods via their annotation patterns and inherits them — no stubs are generated.

## Generated output (without inherited methods)

Since all step methods are already implemented in the marker class with matching annotations, the generated test class contains **no step methods at all** — only the `@Test` scenario methods that call the inherited implementations.

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/ShoppingCart.feature` | Feature with Given/When/And/Then steps |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class with custom-named step methods matched by both Cucumber expression and regex annotation patterns |
| `pom.xml` | Includes `cucumber-java` dependency |
