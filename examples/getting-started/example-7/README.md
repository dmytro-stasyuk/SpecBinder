# Example 7: Tags for Test Filtering

Demonstrates how Gherkin tags (`@smoke`, `@regression`, etc.) map to JUnit `@Tag` annotations for selective test execution.

## What this demonstrates

- Feature-level tags → `@Tag` on the generated outer test class
- Rule-level tags → `@Tag` on the `@Nested` rule class
- Scenario-level tags → `@Tag` on the `@Test` method
- Multiple tags → `@Tags` container annotation
- Tags enable filtering in IDEs, Maven Surefire, and CI pipelines

## Gherkin → JUnit mapping

| Gherkin | JUnit |
|---------|-------|
| `@cart @regression` on Feature | `@Tags({@Tag("cart"), @Tag("regression")})` on outer class |
| `@ui @shipping` on Rule | `@Tags({@Tag("ui"), @Tag("shipping")})` on `@Nested` class |
| `@smoke` on Scenario | `@Tag("smoke")` on `@Test` method |
| `@smoke @happy-path` on Scenario | `@Tags({@Tag("smoke"), @Tag("happy-path")})` on `@Test` method |

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/ShoppingCart.feature` | Feature with tags at feature, rule, and scenario levels |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class annotated with `@Feature2JUnit` |

## Running filtered tests

With JUnit tags in place, you can filter test execution:

**IntelliJ IDEA:** Right-click a tag in the test class → "Run tests tagged..."

**Maven Surefire:**
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-surefire-plugin</artifactId>
    <configuration>
        <groups>smoke</groups>           <!-- include only @smoke -->
        <excludedGroups>edge-case</excludedGroups> <!-- exclude @edge-case -->
    </configuration>
</plugin>
```
