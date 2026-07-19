package dev.specbinder.reporter;

/**
 * SPI for observing SpecBinder execution boundaries — feature, rule, scenario, and step —
 * as they happen at runtime, in strict nesting order.
 * <p>
 * {@link SpecBinderReporter} already brackets every level while it captures its JSON report:
 * feature via {@code beforeAll}/{@code afterAll}, rule via each {@code @Nested} class's
 * {@code beforeAll}/{@code afterAll}, scenario via {@code beforeEach}/{@code afterEach}, and
 * step via its ByteBuddy interception hooks. Implementations registered through
 * {@link SpecBinderReporter#addBoundaryListener(ExecutionBoundaryListener)} receive those
 * boundaries without the reporter taking on any dependency of its own — the intended consumer
 * is an external adapter (e.g. one that maps boundaries onto Playwright's
 * {@code tracing.group()} / {@code tracing.groupEnd()} so a captured trace timeline reads
 * like the feature file).
 * <p>
 * <strong>Ordering &amp; nesting.</strong> For a given run the callbacks fire in strict
 * last-in-first-out order, so an implementation can safely maintain a group/frame stack:
 * <pre>
 *   featureStarted
 *     ruleStarted                 (only for scenarios under a Gherkin Rule)
 *       scenarioStarted
 *         stepStarted / stepFinished   (background steps first, then scenario steps)
 *       scenarioFinished
 *     ruleFinished
 *   featureFinished
 * </pre>
 * Every {@code *Started} is paired with exactly one {@code *Finished}, including when a step,
 * scenario, or rule fails or is aborted — so a stack of open groups always unwinds cleanly.
 * <p>
 * <strong>Threading.</strong> Callbacks fire on the thread executing the test. The reporter
 * does not serialize them across threads, so an implementation shared by tests that run in
 * parallel must key any per-run state (such as the target browser context) by thread or by
 * the run it belongs to. The step callbacks are static-hook driven and carry no owning
 * feature/rule/scenario identity; an implementation that needs it should track it from the
 * enclosing {@code scenarioStarted}/{@code ruleStarted} events.
 * <p>
 * All methods are {@code default} no-ops so implementations override only what they need.
 * A listener that throws is logged and skipped by the reporter; it never fails the test run
 * or corrupts the JSON report.
 */
public interface ExecutionBoundaryListener {

    /**
     * Reserved {@link org.junit.jupiter.api.TestReporter#publishEntry publishEntry} key under which a
     * boundary adapter records a per-step Playwright trace-chunk zip path onto the running step (via
     * {@link SpecBinderReporter#recordPublishedEntry}). It surfaces in the JSON report on
     * {@code StepReport.publishedReporterEntries}; tooling that consumes the report — notably the
     * SpecBinder IntelliJ plugin — keys off this exact name to find a step's trace. Defined here so the
     * producing adapter and the consuming tool share one authoritative constant rather than duplicating a
     * magic string across repositories.
     */
    String PLAYWRIGHT_TRACE_ENTRY_KEY = "specbinder.playwright.trace";

    /** A feature (one SpecBinder test class) began executing. */
    default void featureStarted(FeatureBoundary feature) {
    }

    /** A feature finished executing (fires once, from the outer class only). */
    default void featureFinished(FeatureBoundary feature) {
    }

    /** A Gherkin Rule (a {@code @Nested} class) began executing. */
    default void ruleStarted(RuleBoundary rule) {
    }

    /** A Gherkin Rule finished executing. */
    default void ruleFinished(RuleBoundary rule) {
    }

    /**
     * A scenario began executing. Fires once per {@code @Test} method, and once per row of a
     * Scenario Outline (each parameterized invocation is its own scenario boundary).
     */
    default void scenarioStarted(ScenarioBoundary scenario) {
    }

    /** A scenario finished executing. */
    default void scenarioFinished(ScenarioBoundary scenario) {
    }

    /** A step method began executing (fires for both background and scenario steps). */
    default void stepStarted(StepBoundary step) {
    }

    /** A step method finished executing, carrying its outcome in {@link StepBoundary#status()}. */
    default void stepFinished(StepBoundary step) {
    }

    /**
     * Feature-boundary payload.
     *
     * @param displayName    the Gherkin Feature title
     * @param sourceFilePath the spec file path recorded on the generated class
     */
    record FeatureBoundary(String displayName, String sourceFilePath) {
    }

    /**
     * Rule-boundary payload.
     *
     * @param displayName the Gherkin Rule title
     */
    record RuleBoundary(String displayName) {
    }

    /**
     * Scenario-boundary payload.
     *
     * @param displayName     the scenario (or example-row) display name
     * @param testMethodName  the generated JUnit test method name — already rule-qualified and unique
     *                        within the test class (e.g. {@code "rule_1_scenario_2"}), so it needs no
     *                        separate rule segment; {@code null} if no test method is resolvable
     * @param exampleRowIndex the 1-based row number for a Scenario Outline invocation, or {@code null}
     *                        for a plain scenario — disambiguates rows that share {@code testMethodName}
     */
    record ScenarioBoundary(String displayName, String testMethodName, Integer exampleRowIndex) {
    }

    /**
     * Step-boundary payload.
     *
     * @param methodName the generated step method name (e.g. {@code iAddAnItemToTheCart}),
     *                   always present — a stable identity and fallback label
     * @param text       the verbatim Gherkin step line including its keyword (e.g.
     *                   {@code "Given I add an item to the cart"}), resolved from the spec at
     *                   scenario start. {@code null} only when it can't be resolved — the spec
     *                   isn't on the classpath, or the scenario carries no {@code @ScenarioHash}
     *                   integrity anchor, or its hash no longer matches the spec (drift). For a
     *                   Scenario Outline the text is the template line with {@code <>}
     *                   placeholders intact.
     * @param status     the step outcome — {@code null} on {@link #stepStarted}, set on
     *                   {@link #stepFinished}
     */
    record StepBoundary(String methodName, String text, Status status) {
    }
}
