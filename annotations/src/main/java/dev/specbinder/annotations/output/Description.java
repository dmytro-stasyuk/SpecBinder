package dev.specbinder.annotations.output;

import java.lang.annotation.*;

/**
 * Carries the Gherkin description text associated with a Feature, Rule, Scenario, or Background —
 * verbatim and multi-line — so downstream tooling can read it at runtime via reflection.
 * <p>
 * Emitted by the SpecBinder annotation processor when
 * {@code @Gherkin2JUnitOptions(descriptionAsAnnotation = true)} is configured on the annotated
 * class. When that option is left at its default ({@code false}), description text is rendered
 * as a JavaDoc block instead and this annotation is not emitted.
 *
 * <p>Marked {@link Inherited} on the class target so that, in abstract generation mode, a
 * user-written concrete subclass surfaces the description carried by the generated abstract
 * intermediate without callers having to walk the superclass chain themselves.
 */
@Inherited
@Target({ElementType.TYPE, ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
public @interface Description {

    /**
     * The Gherkin description text, with leading and trailing whitespace trimmed from each line.
     *
     * @return the description text
     */
    String value();
}
