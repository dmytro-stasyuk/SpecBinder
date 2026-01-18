package dev.specbinder.examples.featureprocessor;

import dev.specbinder.annotations.Feature2JUnit;
import dev.specbinder.annotations.Feature2JUnitOptions;

/**
 * Demonstrates the {@code shouldBeAbstract = true} option for generating abstract test classes.
 * <p>
 * When {@code shouldBeAbstract = true}, the processor generates abstract test classes with abstract
 * step methods. The generated class declares each step as an abstract method that must be implemented
 * by the annotated base class or through interface default methods.
 * <p>
 * This approach enforces compile-time verification that all steps are implemented. If a step method
 * is missing, the code won't compile. Step implementations can reside either in the annotated class
 * itself or in interfaces it implements using default methods.
 * <p>
 * In contrast, the default behavior ({@code shouldBeAbstract = false}) generates concrete test classes
 * with failing assumption statements as placeholders for missing steps, allowing tests to compile and
 * run even when step implementations are incomplete.
 * <p>
 */
@Feature2JUnitOptions(
        shouldBeAbstract = true
)
@Feature2JUnit("specs/*.feature")
public abstract class GeneratedClassIsConcreteExample {

}