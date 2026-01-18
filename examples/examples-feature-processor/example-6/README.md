# Spec Binder Advanced Examples - Abstract Test Classes with Compile-Time Safety

This module demonstrates generating abstract test classes using the `shouldBeAbstract = true` option, which enforces compile-time verification that all step methods are implemented.

## Core Concepts

### 1. Abstract Test Class Generation
With `@Feature2JUnitOptions(shouldBeAbstract = true)`, the processor generates abstract test classes with abstract step methods. This is in contrast to the default behavior (`shouldBeAbstract = false`), which generates concrete classes with failing assumption statements as placeholders for missing steps.

### 2. Step Method Resolution Workflow
When the processor encounters a step from a feature file with `shouldBeAbstract = true`:
- It first searches the annotated class hierarchy for a matching method implementation
- If found, the generated class delegates to that existing method (concrete implementation)
- If not found, it declares the method as abstract in the generated class

The annotated base class must then provide implementations for all abstract step methods, either directly or through interface default methods. If any step method is missing an implementation, the code will not compile - providing compile-time safety.

### 3. Interface-Based Step Implementation
Step methods can be implemented as default methods in interfaces that the annotated class implements. The annotated class `GeneratedClassIsConcreteExample` can implement step interfaces to provide implementations for the abstract methods declared in the generated test classes.

### 4. Glob Pattern Matching with Test Suites
This example uses `@Feature2JUnit("specs/*.feature")` to match multiple feature files. When using glob patterns, it's recommended to create a JUnit suite class (like `TestSuite.java`) that explicitly references each generated test class. This provides:
- Better organization for running tests in logical groups
- An early warning system for generation failures (missing generated classes trigger compile-time errors)

## Project Structure

```
src/test/
├── resources/specs/                              # Feature files
│   ├── SimpleCalculator.feature
│   ├── ScenarioWithBackground.feature
│   └── ShoppingCart.feature
└── java/.../featureprocessor/
    ├── GeneratedClassIsConcreteExample.java      # Abstract base class with @Feature2JUnit
    ├── SimpleCalculatorTest.java                 # Concrete test implementation
    ├── ScenarioWithBackgroundTest.java           # Concrete test implementation
    ├── ShoppingCartTest.java                     # Concrete test implementation
    └── TestSuite.java                            # JUnit suite referencing test implementations
```

## Generated Files

The annotation processor generates abstract test classes in:
```
target/generated-test-sources/test-annotations/.../featureprocessor/
├── SimpleCalculatorScenarios.java                # Abstract generated test class
├── ScenarioWithBackgroundScenarios.java          # Abstract generated test class
└── ShoppingCartScenarios.java                    # Abstract generated test class
```

Each generated class:
- Extends `GeneratedClassIsConcreteExample`
- Is an abstract class due to `shouldBeAbstract = true`
- Declares abstract step methods for steps not implemented in the base class hierarchy
- Cannot be executed directly - requires a concrete subclass implementation

Developers must create concrete test classes that extend the generated abstract classes:
```
src/test/java/.../featureprocessor/
├── SimpleCalculatorTest.java                     # extends SimpleCalculatorScenarios
├── ScenarioWithBackgroundTest.java               # extends ScenarioWithBackgroundScenarios
└── ShoppingCartTest.java                         # extends ShoppingCartScenarios
```

These concrete implementations provide the missing step method implementations, making the tests executable.

## Configuration

The example uses the following annotation configuration:
```java
@Feature2JUnitOptions(shouldBeAbstract = true)
@Feature2JUnit("specs/*.feature")
public abstract class GeneratedClassIsConcreteExample {
}
```

## Benefits

1. **Compile-Time Safety**: Missing step implementations cause compilation errors, not runtime failures
2. **Early Detection**: Unimplemented steps are caught during compilation, before tests run
3. **Explicit Contract**: Generated abstract methods clearly define which steps need implementation
4. **Type Safety**: No assumptions or runtime fallbacks - all steps must be properly implemented
5. **Clean Separation**: Generated test structure (abstract) separate from implementation (concrete)
6. **IDE Support**: IDEs highlight missing implementations and provide quick-fix actions
7. **Explicit Test Organization**: Test suite provides clear structure and catches generation issues early

## Dependencies

This example does **not** require a dependency on the `cucumber-java` library.
The feature2junit processor generates pure JUnit 5 test classes that are independent
of Cucumber's runtime.

## Running

This module is configured to skip test execution (`skipTests=true`) as it serves
as a reference implementation demonstrating code generation patterns.
