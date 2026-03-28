package dev.specbinder.annotations;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Annotation to specify a Gherkin feature file path for JUnit test generation.
 * <p>
 * RUNTIME retention is used to ensure compatibility with incremental build systems.
 * SOURCE retention does not work well with incremental compilation, notably with IntelliJ IDEA's incremental build system.
 */
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface Gherkin2JUnit {

    /**
     * Path to the feature file or glob pattern for multiple feature files.
     * <p>
     * Supports three usage patterns:
     * <ul>
     *   <li><b>Specific file path:</b> {@code @Gherkin2JUnit("path/to/MyFeature.feature")} -
     *       Generates a single test class from the specified feature file.
     *       Both {@code .feature} and {@code .specb} extensions are supported.</li>
     *   <li><b>Convention-based discovery:</b> {@code @Gherkin2JUnit} or {@code @Gherkin2JUnit()} -
     *       Automatically finds all {@code .feature} and {@code .specb} files in the same package directory
     *       as the annotated class. For example, a class in package {@code com.example.features} will use
     *       the pattern {@code com/example/features/*.{feature,specb}} to find matching files.
     *       Generates a separate test class for each feature file found.</li>
     *   <li><b>Glob pattern:</b> {@code @Gherkin2JUnit("features/**​/*.feature")} -
     *       Finds all feature files matching the glob pattern.
     *       Generates a separate test class for each matching file.</li>
     * </ul>
     *
     * @return the path to the Gherkin feature file or glob pattern, relative to the classpath
     */
    String value() default "";
}