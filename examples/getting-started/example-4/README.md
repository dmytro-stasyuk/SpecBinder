# Example 4: Rules and Nested Scenarios

Demonstrates how Gherkin `Rule` blocks map to JUnit `@Nested` test classes, grouping related scenarios under business rules.

## What this demonstrates

- `Rule` blocks become `@Nested` inner classes in the generated test
- Each Rule gets a `@DisplayName` with the rule title
- Scenarios inside a Rule become `@Test` methods within the nested class
- Scenarios outside any Rule remain at the top level
- Rule description lines become JavaDoc on the nested class
- `@Order` annotations preserve the feature file ordering

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
| `src/test/java/.../ShoppingCartFeature.java` | Marker class annotated with `@Feature2JUnit` |

## Generated structure

```java
public class ShoppingCartFeatureTest extends ShoppingCartFeature {

    @Test
    @DisplayName("Scenario: View an empty cart")
    public void scenario_1() { ... }

    @Nested
    @DisplayName("Rule: Free shipping applies to orders over 50 euros")
    public class Rule_1 {
        @Test
        @DisplayName("Scenario: Show free shipping when threshold is met")
        public void scenario_1() { ... }

        @Test
        @DisplayName("Scenario: Show shipping cost when below threshold")
        public void scenario_2() { ... }
    }

    @Nested
    @DisplayName("Rule: Discount codes apply a percentage reduction")
    public class Rule_2 {
        @Test
        @DisplayName("Scenario: Apply a valid discount code")
        public void scenario_1() { ... }

        @Test
        @DisplayName("Scenario: Reject an expired discount code")
        public void scenario_2() { ... }
    }
}
```
