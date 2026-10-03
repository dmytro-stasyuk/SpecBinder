# Example 4: Rules and Nested Scenarios

Demonstrates how Gherkin `Rule` blocks map to JUnit `@Nested` test classes, grouping related scenarios under business rules.

## What this demonstrates

- `Rule` blocks become `@Nested` inner classes in the generated test
- Each Rule gets a `@DisplayName` with the rule title
- Scenarios inside a Rule become `@Test` methods within the nested class
- Scenarios outside any Rule remain at the top level
- Rule description lines become JavaDoc on the nested class
- `@Order` annotations preserve the feature file ordering
- Step methods are implemented once in a concrete subclass (`ShoppingCartTest`); the `@Nested` rule classes call the
  same implementations on the outer instance, so top-level and rule scenarios share one set of steps and state

## Gherkin → JUnit mapping

| Gherkin | JUnit |
|---------|-------|
| `Feature:` | Outer test class |
| `Scenario:` (top-level) | `@Test` method on outer class |
| `Rule:` | `@Nested` inner class |
| `Scenario:` (inside Rule) | `@Test` method on nested class |
| Rule title | `@DisplayName` on nested class |
| Rule description | JavaDoc on nested class |

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/ShoppingCart.feature` | Feature with a top-level scenario and two rules, each containing two scenarios |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class annotated with `@Gherkin2JUnit` |
| `src/test/java/.../ShoppingCartTest.java` | Concrete subclass implementing the step methods with assertions |

## Class hierarchy

```
ShoppingCartFeature.java          (marker class, @Gherkin2JUnit)
  └→ ShoppingCartScenarios.java   (generated, abstract, contains @Test methods and @Nested rule classes)
      └→ ShoppingCartTest.java    (your concrete class, implements step methods)
```

## Generated structure

```java
public abstract class ShoppingCartScenarios extends ShoppingCartFeature {

    @Test
    @DisplayName("Scenario: View an empty cart")
    public void scenario_1() { ... }

    @Nested
    @DisplayName("Rule: Free shipping applies to orders over 50 euros")
    public class Rule_1 {
        @Test
        @DisplayName("Scenario: Show free shipping when threshold is met")
        public void rule_1_scenario_1() { ... }

        @Test
        @DisplayName("Scenario: Show shipping cost when below threshold")
        public void rule_1_scenario_2() { ... }
    }

    @Nested
    @DisplayName("Rule: Discount codes apply a percentage reduction")
    public class Rule_2 {
        @Test
        @DisplayName("Scenario: Apply a valid discount code")
        public void rule_2_scenario_1() { ... }

        @Test
        @DisplayName("Scenario: Reject an expired discount code")
        public void rule_2_scenario_2() { ... }
    }
}
```
