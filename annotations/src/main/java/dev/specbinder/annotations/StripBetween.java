package dev.specbinder.annotations;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * A pair of regular expressions marking the two ends of a span of spec file text to strip.
 *
 * <p>Used only as a value inside {@link Gherkin2JUnitOptions#stripBetweenPatterns()}:
 * <pre>
 * &#64;Gherkin2JUnitOptions(
 *     stripBetweenPatterns = {
 *         &#64;StripBetween(start = "&lt;\\s*REMOVED\\b[^&lt;&gt;]*&gt;", end = "&lt;/\\s*REMOVED\\b[^&lt;&gt;]*&gt;")
 *     }
 * )
 * </pre>
 * Everything from the beginning of a {@code start} match to the end of the next {@code end} match is
 * removed, markers included. Neither pattern needs the {@code (?s)} flag to span lines — the span is
 * located by offset rather than by a single regex — and neither needs a reluctant quantifier, because a
 * {@code start} always pairs with the <em>nearest</em> following {@code end}.
 *
 * <p>Note: This annotation is part of an experimental option and may change in future versions.
 *
 * @see Gherkin2JUnitOptions#stripBetweenPatterns()
 */
@Retention(RetentionPolicy.RUNTIME)
@Target({})
public @interface StripBetween {

    /**
     * Regular expression matching the marker that opens the span.
     *
     * @return the opening marker pattern
     */
    String start();

    /**
     * Regular expression matching the marker that closes the span.
     *
     * @return the closing marker pattern
     */
    String end();
}
