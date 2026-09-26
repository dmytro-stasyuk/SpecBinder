# Example 8: Convention-Based Discovery & Co-located Spec Files

Demonstrates using `@Gherkin2JUnit` without a path — the processor discovers spec files (`.feature` or `.specb`) automatically by convention. Spec files live alongside their marker classes in `src/test/java`. This example co-locates a `.specb` file.

## What this demonstrates

- `@Gherkin2JUnit` (no value) uses convention-based discovery
- The processor looks for `.feature` and `.specb` files in the same package as the annotated class
- Spec files placed in `src/test/java` alongside Java classes for easy navigation
- A concrete test beside the spec implements the generated `ShoppingCartScenarios` class
- Maven `testResources` configuration to include `.feature` / `.specb` files from `src/test/java`

## Convention-based discovery rules

When `@Gherkin2JUnit` has no path value, the processor searches for `.feature` and `.specb` files in the same package directory as the annotated class. All spec files found are processed.

## Directory layout

```
src/test/java/
  └── dev/specbinder/examples/gettingstarted/colocated/
      ├── ShoppingCart.java        ← marker class (@Gherkin2JUnit)
      ├── ShoppingCart.specb       ← co-located spec file
      └── ShoppingCartTest.java    ← runnable scenario implementation
```

The marker, spec, and runnable test are in the same package — easy to navigate between them in the IDE.

## The runnable test

SpecBinder generates `ShoppingCartScenarios` in the same package. The concrete test extends it and
implements the generated step methods with ordinary Java and JUnit assertions:

```java
public class ShoppingCartTest extends ShoppingCartScenarios {
    private final List<String> items = new ArrayList<>();

    @Override
    public void iHaveAnEmptyShoppingCart() {
        items.clear();
    }

    @Override
    public void iAdd$p1ToTheCart(String item) {
        items.add(item);
    }

    @Override
    public void theCartShouldContain$p1Item(Integer expectedCount) {
        assertEquals(expectedCount, items.size());
    }

    // The remaining generated step methods are implemented in the same way.
}
```

## Required Maven configuration

To make Maven treat co-located spec files in `src/test/java` as test resources:

```xml
<build>
    <testResources>
        <testResource>
            <directory>src/test/java</directory>
            <includes>
                <include>**/*.feature</include>
                <include>**/*.specb</include>
            </includes>
        </testResource>
        <testResource>
            <directory>src/test/resources</directory>
        </testResource>
    </testResources>
</build>
```

Without this, Maven won't copy the co-located spec files from `src/test/java` to the classpath.

## Files

| File | Purpose |
|------|---------|
| `src/test/java/.../ShoppingCart.specb` | Spec file co-located with its marker class |
| `src/test/java/.../ShoppingCart.java` | Marker class with bare `@Gherkin2JUnit` (no path) |
| `src/test/java/.../ShoppingCartTest.java` | Concrete test implementing the generated `ShoppingCartScenarios` class |
| `pom.xml` | Includes `testResources` configuration for co-located spec files |

## Run it

```bash
cd examples/getting-started/example-8
mvn test
```

Both scenarios should pass.
