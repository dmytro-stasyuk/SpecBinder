# Example 6: Scenario Outline with Examples

Demonstrates how `Scenario Outline` with `Examples` tables maps to JUnit `@ParameterizedTest` with `@CsvSource`.

## What this demonstrates

- `Scenario Outline` → `@ParameterizedTest` (instead of `@Test`)
- `Examples` table rows → `@CsvSource(textBlock = ...)` data
- Placeholders (`<name>`, `<price>`) → test method parameters
- Column headers → parameter names (sanitized to valid Java identifiers, e.g. `expected subtotal` → `expectedSubtotal`)
- Type inference from cell values across all rows
- Multiple `Examples` blocks → separate repeatable `@CsvSource` annotations

## Gherkin → JUnit mapping

| Gherkin | JUnit |
|---------|-------|
| `Scenario Outline:` | `@ParameterizedTest` |
| `Examples:` table | `@CsvSource(textBlock = ...)` |
| `<placeholder>` in steps | Method parameter variable |
| Column header | Parameter name |
| Table rows | Test iterations |

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/ShoppingCart.feature` | Two scenario outlines — one with a single Examples block, one with two Examples blocks |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class annotated with `@Gherkin2JUnit` |

## Generated output

```java
@ParameterizedTest(name = "Example {index}: [{arguments}]")
@CsvSource(
        useHeadersInDisplayName = true,
        delimiter = '|',
        textBlock = """
                name                | start qty | price | new qty | expected subtotal
                Wireless Headphones | 1         | 60.00 | 2       | 120.00
                Coffee Beans 1kg    | 2         | 15.50 | 3       | 46.50
                USB-C Cable         | 1         | 8.99  | 5       | 44.95
                """
)
@DisplayName("Scenario Outline: Subtotal updates when quantity changes")
public void scenario_1(String name, Integer startQty, Double price,
                       Integer newQty, Double expectedSubtotal) {
    myCartContains$p1WithQuantity$p2AndUnitPrice$p3(name, startQty, price);
    iChangeTheQuantityTo$p1(newQty);
    theCartSubtotalShouldBe$p1(expectedSubtotal);
}
```

When multiple `Examples` blocks are present, each block generates a separate repeatable `@CsvSource` annotation on the same test method.
