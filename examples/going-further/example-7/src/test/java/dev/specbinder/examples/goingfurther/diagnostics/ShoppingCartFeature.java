package dev.specbinder.examples.goingfurther.diagnostics;

import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.annotations.Gherkin2JUnitOptions;
import dev.specbinder.annotations.Gherkin2JUnitOptions.Verbosity;

/**
 * Marker class that turns up the annotation processor's build-log output via the
 * {@code verbosity} option. Everything the processor prints happens at
 * <em>compile time</em> — compile this module (e.g. {@code mvn test-compile}) and
 * watch the build log.
 * <p>
 * Verbosity levels are cumulative:
 * <ul>
 *     <li>{@code SILENT} — only error diagnostics (quiet CI).</li>
 *     <li>{@code NORMAL} (default) — errors, warnings, the startup banner, and the end-of-round summary.</li>
 *     <li>{@code VERBOSE} — adds per-class headers, per-feature progress, the resolved spec path,
 *     and skipped/filtered work. Set here.</li>
 *     <li>{@code DEBUG} — adds full stack traces, parsed Gherkin AST and JavaPoet code-model
 *     summaries, and per-step decisions.</li>
 * </ul>
 */
@Gherkin2JUnit("specs/ShoppingCart.specb")
@Gherkin2JUnitOptions(verbosity = Verbosity.VERBOSE)
public abstract class ShoppingCartFeature {
}
