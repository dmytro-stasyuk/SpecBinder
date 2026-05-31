package dev.specbinder.annotations;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Marks a step method parameter (or a type used as one) as a JUnit-injected parameter
 * to be filled at test execution time by a registered {@code org.junit.jupiter.api.extension.ParameterResolver}.
 * <p>
 * Built-in JUnit-resolved types ({@code TestInfo}, {@code TestReporter}, {@code @TempDir Path}/{@code File})
 * are recognized implicitly and do not require this annotation. {@code @JUnitInject} exists so the SpecBinder
 * annotation processor can distinguish, on a base step method, between Gherkin-derived parameters and
 * user-supplied custom-resolver parameters.
 * <p>
 * Placement options:
 * <ul>
 *   <li><b>On the parameter:</b> {@code void user(@JUnitInject MyType ctx)} — per-parameter opt-in.</li>
 *   <li><b>On the type's class declaration:</b> {@code @JUnitInject class MyType { ... }} — every parameter
 *       of that type is implicitly opted in; useful for user-controlled types that are always JUnit-resolved.</li>
 * </ul>
 * <p>
 * The annotation is a SpecBinder-internal marker only and is <b>not</b> emitted on the generated
 * {@code @Test} / {@code @BeforeEach} / {@code @ParameterizedTest} method parameter. All other annotations
 * on the source parameter are preserved verbatim so the user's {@code ParameterResolver} can observe them
 * via {@code ParameterContext.findAnnotation(...)} at runtime.
 */
@Target({ElementType.PARAMETER, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
public @interface JUnitInject {
}
