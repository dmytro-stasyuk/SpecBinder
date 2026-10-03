package dev.specbinder.examples.goingfurther.playwrighttrace;

import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.annotations.Gherkin2JUnitOptions;
import dev.specbinder.reporter.SpecBinderReporter;
import org.junit.jupiter.api.extension.ExtendWith;

/**
 * Marker class for the CartTrace spec. It wires up the two extensions; the step methods, which
 * drive a real browser, live in CartTraceTest.
 * <p>
 * Two extensions, in this order:
 * <ul>
 *     <li>{@link SpecBinderReporter} — writes the JSON execution report, and raises the execution
 *     boundaries the trace listener subscribes to.</li>
 *     <li>{@link PlaywrightTracing} — owns the browser and registers that listener.</li>
 * </ul>
 * Both are {@code @Inherited}, so putting them on this abstract marker covers the concrete
 * CartTraceTest that JUnit actually runs.
 * <p>
 * Nothing about tracing depends on a generation option — the per-step trace paths ride on the
 * report's published-entry mechanism, and {@code emitScenarioHash}, which also gives the report
 * each step's verbatim Gherkin text, is on by default. {@code descriptionAsAnnotation} only adds
 * the Gherkin descriptions to the report.
 * <p>
 * No path in @Gherkin2JUnit — the processor discovers the co-located CartTrace.specb in this
 * package by convention.
 */
@Gherkin2JUnit
@Gherkin2JUnitOptions(descriptionAsAnnotation = true)
@ExtendWith({SpecBinderReporter.class, PlaywrightTracing.class})
public abstract class CartTraceFeature {
}
