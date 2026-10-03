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
5. **Add steps** to one scenario — it now generates abstract step methods
6. **Implement** step methods in the concrete subclass (`ShoppingCartTest`)
7. **Green** — that scenario passes
8. **Repeat** for the next scenario, then the next rule

## Generated output for this example

```java
public abstract class ShoppingCartScenarios extends ShoppingCartFeature {

    // Abstract step methods — only for the scenario that has steps
    public abstract void myCartSubtotalIs$p1(Double p1);
    public abstract void iApplyDiscountCode$p1(String p1);
    public abstract void theCartSubtotalShouldBe$p1(Double p1);

    @Nested
    @DisplayName("Rule: Discount codes apply a percentage reduction")
    public class Rule_1 {
        // Scenario with steps — normal test with step calls
        @Test
        @DisplayName("Scenario: Apply a valid discount code")
        public void rule_1_scenario_1() {
            myCartSubtotalIs$p1(100.00);
            iApplyDiscountCode$p1("SAVE10");
            theCartSubtotalShouldBe$p1(90.00);
        }

        // Scenario with no steps — still failing
        @Test
        @Tag("new")
        @DisplayName("Scenario: Reject an expired discount code")
        public void rule_1_scenario_2() {
            Assertions.fail("Scenario has no steps");
        }
    }

    @Nested
    @DisplayName("Rule: Free shipping applies to orders over 50 euros")
    public class Rule_2 {
        // Scenarios with no steps — fail immediately
        @Test
        @Tag("new")
        @DisplayName("Scenario: Free shipping when subtotal exceeds threshold")
        public void rule_2_scenario_1() {
            Assertions.fail("Scenario has no steps");
        }

        @Test
        @Tag("new")
        @DisplayName("Scenario: Shipping fee when subtotal is below threshold")
        public void rule_2_scenario_2() {
            Assertions.fail("Scenario has no steps");
        }
    }

    // Rule with no scenarios — fails immediately
    @Nested
    @Tag("new")
    @DisplayName("Rule: Cannot checkout with an empty cart")
    public class Rule_3 {
        @Test
        public void noScenariosInRule() {
            Assertions.fail("Rule doesn't have any scenarios");
        }
    }
}
```

## Configuration options

| Option | Default | Description |
|--------|---------|-------------|
| `emptyScenarioBehavior` | `FAIL` | `FAIL`, `ABORT`, or `COMPILATION_ERROR` for stepless scenarios |
| `emptyRuleBehavior` | `FAIL` | `FAIL`, `ABORT`, or `COMPILATION_ERROR` for scenarioless rules |
| `tagForEmptyScenarios` | `"new"` | Tag added to empty scenarios (set to `""` to disable) |
| `tagForEmptyRules` | `"new"` | Tag added to empty rules (set to `""` to disable) |

## Files

| File | Purpose |
|------|---------|
| `src/test/java/.../ShoppingCart.specb` | Feature with a mix of empty rules, empty scenarios, and one fully specified scenario |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class with bare `@Gherkin2JUnit` — discovers the co-located spec by convention |
| `src/test/java/.../ShoppingCartTest.java` | Concrete subclass implementing the steps of the one fully specified scenario |

## Class hierarchy

```
ShoppingCartFeature.java          (marker class, @Gherkin2JUnit)
  └→ ShoppingCartScenarios.java   (generated, abstract, contains @Test methods and @Nested rule classes)
      └→ ShoppingCartTest.java    (your concrete class, implements step methods)
```

Running `ShoppingCartTest` gives one passing test (*Apply a valid discount code*) and four failing ones tagged `@new` —
the empty rule and the three empty scenarios. That red list is the backlog for the next TDD iterations.
