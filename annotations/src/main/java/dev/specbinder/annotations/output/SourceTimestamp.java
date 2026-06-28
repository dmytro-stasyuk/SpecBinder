package dev.specbinder.annotations.output;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Records the newest last-modified time (epoch milliseconds) across all inputs that fed the
 * generation of the annotated test class: the spec ({@code .feature}/{@code .specb}) file, the
 * {@code @Gherkin2JUnit} marker class, and every source class in the marker's hierarchy.
 * <p>
 * Emitted only when {@code skipUnchangedSpecs} is enabled. On a later annotation-processing run the
 * generator reads this value back off the previously generated class and compares it against the
 * freshly computed newest input time; if they are equal the class is left untouched (regeneration
 * is skipped), otherwise it is regenerated and re-stamped.
 */
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface SourceTimestamp {

    /**
     * The newest last-modified time, in epoch milliseconds, across the spec file, the marker class,
     * and the marker's hierarchy at the moment the test class was generated.
     *
     * @return the recorded newest-input timestamp in epoch milliseconds
     */
    long value();
}
