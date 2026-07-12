# Example 5: TDD Workflow — Iterative Red-Green Development

Demonstrates how Spec Binder supports test-first development by generating failing tests from incomplete feature files.

## What this demonstrates

- Empty Rules (no scenarios) generate a failing `noScenariosInRule()` test
- Empty Scenarios (no steps) generate a failing `Assertions.fail("Scenario has no steps")` test
- Both are tagged `@new` by default for easy filtering
- Scenarios with steps generate normal tests with step method stubs
- Mix of complete and incomplete specifications in the same feature

## TDD iteration cycle

1. **List Rules** — write just the rule titles to outline the business domain
2. **Compile** — each empty rule becomes a failing `@Test` tagged `@new`
3. **Add Scenario titles** under the first rule — still no steps
4. **Compile** — each empty scenario becomes a failing `@Test` tagged `@new`
5. **Add steps** to one scenario — it now generates step method stubs
6. **Implement** step methods in the marker class
7. **Green** — that scenario passes
8. **Repeat** for the next scenario, then the next rule

## Generated output for this example

```java
public class ShoppingCartFeatureTest extends ShoppingCartFeature {

    // Rule with no scenarios — fails immediately
    @Nested
    @Tag("new")
    @DisplayName("Rule: Cannot checkout with an empty cart")
    public class Rule_1 {
        @Test
        public void noScenariosInRule() {
            Assertions.fail("Rule doesn't have any scenarios");
        }
    }

    @Nested
    @DisplayName("Rule: Free shipping applies to orders over 50 euros")
    public class Rule_2 {
        // Scenario with no steps — fails immediately
        @Test
        @Tag("new")
        @DisplayName("Scenario: Free shipping when subtotal exceeds threshold")
        public void scenario_1() {
            Assertions.fail("Scenario has no steps");
        }

        @Test
        @Tag("new")
        @DisplayName("Scenario: Shipping fee when subtotal is below threshold")
        public void scenario_2() {
            Assertions.fail("Scenario has no steps");
        }
    }

    @Nested
    @DisplayName("Rule: Discount codes apply a percentage reduction")
    public class Rule_3 {
        // Scenario with steps — normal test with step calls
        @Test
        @DisplayName("Scenario: Apply a valid discount code")
        public void scenario_1() {
            myCartSubtotalIs$p1(100.00);
            iApplyDiscountCode$p1("SAVE10");
            theCartSubtotalShouldBe$p1(90.00);
        }

        // Scenario with no steps — still failing
        @Test
        @Tag("new")
        @DisplayName("Scenario: Reject an expired discount code")
        public void scenario_2() {
            Assertions.fail("Scenario has no steps");
        }
    }
}
```

## Configuration options

| Option | Default | Description |
|--------|---------|-------------|
| `emptyScenarioBehavior` | `FAIL` | `FAIL`, `SKIP`, or `NONE` for stepless scenarios |
| `emptyRuleBehavior` | `FAIL` | `FAIL`, `SKIP`, or `NONE` for scenarioless rules |
| `tagForEmptyScenarios` | `"new"` | Tag added to empty scenarios (set to `""` to disable) |
| `tagForEmptyRules` | `"new"` | Tag added to empty rules (set to `""` to disable) |

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/ShoppingCart.feature` | Feature with a mix of empty rules, empty scenarios, and one fully specified scenario |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class annotated with `@Gherkin2JUnit` |
