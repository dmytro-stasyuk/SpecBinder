package dev.specbinder.annotations.output;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Carries the canonical SHA-256 hash of a Gherkin scenario's executable content.
 *
 * <p>Emitted by the SpecBinder annotation processor on generated {@code @Test} and
 * {@code @ParameterizedTest} methods when
 * {@link dev.specbinder.annotations.Gherkin2JUnitOptions#emitScenarioHash()} is {@code true}.
 *
 * <p>The hash is computed from the canonical concatenation of background steps and scenario
 * steps (including DataTables and DocStrings, with the keyword stripped from each step text).
 * It therefore covers only this scenario's own executable content: renaming the scenario or
 * editing anything else in the file leaves it unchanged, while altering its steps — or the steps
 * of an enclosing Background — changes it. It is not an identity, since two scenarios with
 * identical steps hash alike.
 *
 * <p>Consumers use it to decide whether a recorded outcome still describes the scenario it came
 * from: a result whose hash no longer matches was produced against content that has since moved on.
 *
 * @see dev.specbinder.annotations.Gherkin2JUnitOptions#emitScenarioHash()
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface ScenarioHash {

    /**
     * The lowercase-hex SHA-256 of the scenario's canonical content.
     *
     * @return the canonical scenario hash as a 64-character lowercase hex string
     */
    String value();
}
