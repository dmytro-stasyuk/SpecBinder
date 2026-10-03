package dev.specbinder.examples.goingfurther.reporter;

import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.annotations.Gherkin2JUnitOptions;
import dev.specbinder.reporter.SpecBinderReporter;

import org.junit.jupiter.api.extension.ExtendWith;

/**
 * Marker class for the ShoppingCart spec. It switches on the execution reporter and the one
 * generation option that enriches the report; the step methods live in ShoppingCartTest.
 * <p>
 * {@code @ExtendWith} is {@code @Inherited}, so placing the reporter here covers the concrete
 * ShoppingCartTest that JUnit actually runs.
 * <p>
 * What enriches the report beyond statuses and timings:
 * <ul>
 *     <li>{@code descriptionAsAnnotation = true} emits Gherkin description text (under Feature,
 *     Rule, Scenario) as runtime-retained {@code @Description} annotations, which the reporter
 *     surfaces as {@code description} fields in the JSON at each level. It defaults to
 *     {@code false}, so it is set here.</li>
 *     <li>{@code emitScenarioHash} stamps each scenario with a {@code @ScenarioHash} of its
 *     executable steps, letting tooling detect when a scenario has drifted from the recorded
 *     run, and carrying the report's verbatim Gherkin step {@code text} and typed
 *     {@code arguments} (both gated on the hash matching live source). It is on by default,
 *     so it needs no entry above.</li>
 * </ul>
 * <p>
 * No path in @Gherkin2JUnit — the processor discovers the co-located ShoppingCart.specb in
 * this package by convention.
 */
@Gherkin2JUnit
@Gherkin2JUnitOptions(descriptionAsAnnotation = true)
@ExtendWith(SpecBinderReporter.class)
public abstract class ShoppingCartFeature {
}
