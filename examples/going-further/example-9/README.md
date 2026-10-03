# Example 9: One Spec, Multiple Test Implementations

Demonstrates running **the same specification at different application layers** — direct Java calls, a Spring-managed bean, and a Spring Boot browser UI. Each concrete test class implements the same steps and inherits the same scenarios, trading execution speed for broader stack coverage.

## What this demonstrates

- Default abstract mode generates one `CartPricingScenarios` class shared by three concrete tests
- Each concrete subclass supplies its own step implementations for a different application layer
- All three tests exercise the same pricing logic and expect identical results
- JUnit `@Tag` annotations allow each layer to run independently
- `@ExtendWith(SpecBinderReporter.class)` on the marker enables a separate execution report for each concrete test class

## Class hierarchy

```text
CartPricingFeature.java              (marker class, declares abstract step methods)
  └→ CartPricingScenarios.java        (generated, abstract, contains the scenarios)
       ├→ CartPricingUnitTest.java    (implements steps using a new Java object)
       ├→ CartPricingSpringTest.java  (implements steps using a Spring-managed bean)
       └→ CartPricingUiTest.java      (implements steps using Playwright)
```

JUnit runs all four inherited scenarios for each concrete class. Adding a scenario to `CartPricing.specb` adds it to every layer; adding a new abstract step requires an implementation in each subclass.

## Testing layers

| Test class | Entry point | Relative speed | Coverage |
|---|---|---|---|
| `CartPricingUnitTest` | `new CartPricingService()` | Fast | Pricing logic in isolation |
| `CartPricingSpringTest` | Bean from `PricingConfiguration` | Medium | Pricing logic and Spring bean configuration |
| `CartPricingUiTest` | Chromium interacting with a Spring Boot application over HTTP | Slow | Form, Spring MVC binding, Thymeleaf rendering, Spring wiring, and pricing logic |

All three use the same `CartPricingService`. The UI submits a real HTML form to an embedded Spring Boot server on a random port. The browser test provides the broadest application coverage; the direct test gives the fastest feedback on business rules. Speeds are relative, and this small application has no database or external services.

## The marker class

```java
@Gherkin2JUnit
@Gherkin2JUnitOptions(descriptionAsAnnotation = true)
@ExtendWith(SpecBinderReporter.class)
public abstract class CartPricingFeature {
    public abstract void aCartHolding$p1ItemsPriced$p2(Integer quantity, String unitPrice);

    public abstract void aDiscountOf$p1PercentIsApplied(Integer percent);

    public abstract void theCartTotalShouldBe$p1(String expected);
}
```

The marker declares the shared step signatures. Each concrete test extends the generated `CartPricingScenarios` and implements those methods with its own setup, interactions, and assertions. The bare `@Gherkin2JUnit` discovers the co-located `CartPricing.specb` by convention. `descriptionAsAnnotation` only adds the spec's descriptions to the reports; `shouldBeAbstract` needs no setting, since it defaults to `true`.

## Files

| File | Purpose |
|---|---|
| `src/test/java/.../CartPricing.specb` | Four scenarios covering quantities, discounts, and rounding |
| `src/test/java/.../CartPricingFeature.java` | Marker class with abstract steps and the reporter extension |
| `src/test/java/.../CartPricingUnitTest.java` | Direct service calls; tagged `unit` |
| `src/test/java/.../CartPricingSpringTest.java` | Spring bean calls; tagged `spring` |
| `src/test/java/.../CartPricingUiTest.java` | Browser interactions and displayed-total assertions; tagged `ui` |
| `src/main/java/.../CartPricingService.java` | Shared pricing logic |
| `src/main/java/.../PricingConfiguration.java` | Declares the pricing service bean |
| `src/main/java/.../PricingWebApplication.java` | Starts the embedded Spring Boot web application |
| `src/main/java/.../PricingController.java` | Handles form submissions through Spring MVC |
| `src/main/resources/static/index.html` | Cart form served as a static Spring Boot resource |
| `src/main/resources/static/styles.css` | Shared responsive styling for the form and result pages |
| `src/main/resources/templates/total.html` | Thymeleaf template for the calculated total |
| `pom.xml` | Spring Boot, Thymeleaf, Playwright, and execution reporter dependencies; enables test execution |

## Run it

With Java 21 or newer and the local SpecBinder snapshot installed:

```bash
cd examples/going-further/example-9
mvn clean test
```

If Playwright reports a missing browser, install Chromium:

```bash
mvn test-compile exec:java \
  -Dexec.mainClass=com.microsoft.playwright.CLI \
  -Dexec.classpathScope=test \
  -Dexec.args="install chromium"
```

All **12 scenario executions should pass**. Failures fail the build. The UI test starts its own application on a random loopback port.

To run the web application yourself:

```bash
mvn spring-boot:run
```

Select a single layer using its JUnit tag:

```bash
mvn clean test -Dgroups=unit
mvn clean test -Dgroups=spring
mvn clean test -Dgroups=ui
```

The unit and Spring tests do not require a browser. `clean` removes reports from previous runs.

## Execution reports

A full run writes three reports:

```text
target/specbinder-reports/dev/specbinder/examples/goingfurther/multipletests/
├── CartPricingUnitTest.json       4 passed
├── CartPricingSpringTest.json     4 passed
└── CartPricingUiTest.json         4 passed
```

Each report identifies `dev/specbinder/examples/goingfurther/multipletests/CartPricing.specb` as its source and records its concrete `testClass`. Naming reports after the concrete classes keeps the results for each layer separate.
