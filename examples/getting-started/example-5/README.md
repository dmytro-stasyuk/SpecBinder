# Example 5: Background — Feature-level and Rule-level

Demonstrates how Gherkin `Background` blocks map to JUnit `@BeforeEach` methods at both the feature and rule levels.

## What this demonstrates

- Feature-level `Background` → `@BeforeEach` on the outer test class
- Rule-level `Background` → `@BeforeEach` on the `@Nested` rule class
- Background title → `@DisplayName` on the `@BeforeEach` method
- Background description → JavaDoc on the `@BeforeEach` method
- Both backgrounds run before each scenario inside a rule

## Execution order

When both a feature-level and a rule-level background exist, JUnit 5 runs them in this order for each scenario inside the rule:

1. **Feature `@BeforeEach`** — `featureBackground()` (signed in, empty cart)
2. **Rule `@BeforeEach`** — `ruleBackground()` (rule-specific setup)
3. **Scenario `@Test`** — the actual test

Scenarios at the top level (outside any rule) only run the feature-level background.

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/ShoppingCart.feature` | Feature with a feature-level background, a top-level scenario, and two rules each with their own background |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class annotated with `@Gherkin2JUnit` |

## Generated structure

```java
public class ShoppingCartFeatureTest extends ShoppingCartFeature {

    @BeforeEach
    @DisplayName("Background: Start with a signed-in shopper")
    public void featureBackground(TestInfo testInfo) {
        iAmSignedInAs$p1("alice@example.com");
        iHaveAnEmptyShoppingCart();
    }

    @Test
    @DisplayName("Scenario: View empty cart message")
    public void scenario_1() { ... }

    @Nested
    @DisplayName("Rule: Free shipping applies to orders over 50 euros")
    public class Rule_1 {
        @BeforeEach
        @DisplayName("Background: Cart near the shipping threshold")
        public void ruleBackground(TestInfo testInfo) {
            myCartSubtotalIs$p1(45.00);
        }

        @Test
        public void scenario_1() { ... }
        @Test
        public void scenario_2() { ... }
    }

    @Nested
    @DisplayName("Rule: Loyalty points are earned on every purchase")
    public class Rule_2 {
        @BeforeEach
        public void ruleBackground(TestInfo testInfo) {
            iHave$p1LoyaltyPoints(100);
        }

        @Test
        public void scenario_1() { ... }
    }
}
```
