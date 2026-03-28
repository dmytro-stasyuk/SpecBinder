# Example 6: Convention-Based Discovery & Co-located Feature Files

Demonstrates using `@Gherkin2JUnit` without a path — the processor discovers `.feature` files automatically by convention. Feature files live alongside their marker classes in `src/test/java`.

## What this demonstrates

- `@Gherkin2JUnit` (no value) uses convention-based discovery
- The processor looks for `.feature` files in the same package as the annotated class
- Feature files placed in `src/test/java` alongside Java classes for easy navigation
- Maven `testResources` configuration to include `.feature` files from `src/test/java`

## Convention-based discovery rules

When `@Gherkin2JUnit` has no path value, the processor searches for `.feature` files in the same package directory as the annotated class. All `.feature` files found are processed.

## Directory layout

```
src/test/java/
  └── dev/specbinder/examples/commonusecases/colocated/
      ├── ShoppingCart.java        ← marker class (@Gherkin2JUnit)
      └── ShoppingCart.feature     ← co-located feature file
```

Both files are in the same package — easy to navigate between them in the IDE.

## Required Maven configuration

To make Maven treat `.feature` files in `src/test/java` as test resources:

```xml
<build>
    <testResources>
        <testResource>
            <directory>src/test/java</directory>
            <includes>
                <include>**/*.feature</include>
            </includes>
        </testResource>
        <testResource>
            <directory>src/test/resources</directory>
        </testResource>
    </testResources>
</build>
```

Without this, Maven won't copy `.feature` files from `src/test/java` to the classpath.

## Files

| File | Purpose |
|------|---------|
| `src/test/java/.../ShoppingCart.feature` | Feature file co-located with its marker class |
| `src/test/java/.../ShoppingCart.java` | Marker class with bare `@Gherkin2JUnit` (no path) |
| `pom.xml` | Includes `testResources` configuration for `.feature` files |
