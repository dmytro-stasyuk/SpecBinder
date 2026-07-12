# Example 8: Convention-Based Discovery & Co-located Spec Files

Demonstrates using `@Gherkin2JUnit` without a path — the processor discovers spec files (`.feature` or `.specb`) automatically by convention. Spec files live alongside their marker classes in `src/test/java`. This example co-locates a `.specb` file.

## What this demonstrates

- `@Gherkin2JUnit` (no value) uses convention-based discovery
- The processor looks for `.feature` and `.specb` files in the same package as the annotated class
- Spec files placed in `src/test/java` alongside Java classes for easy navigation
- Maven `testResources` configuration to include `.feature` / `.specb` files from `src/test/java`

## Convention-based discovery rules

When `@Gherkin2JUnit` has no path value, the processor searches for `.feature` and `.specb` files in the same package directory as the annotated class. All spec files found are processed.

## Directory layout

```
src/test/java/
  └── dev/specbinder/examples/gettingstarted/colocated/
      ├── ShoppingCart.java        ← marker class (@Gherkin2JUnit)
      └── ShoppingCart.specb       ← co-located spec file
```

Both files are in the same package — easy to navigate between them in the IDE.

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
| `pom.xml` | Includes `testResources` configuration for co-located spec files |
