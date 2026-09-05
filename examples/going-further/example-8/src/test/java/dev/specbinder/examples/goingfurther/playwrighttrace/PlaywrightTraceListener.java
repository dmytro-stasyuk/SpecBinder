package dev.specbinder.examples.goingfurther.playwrighttrace;

import com.microsoft.playwright.BrowserContext;
import com.microsoft.playwright.Tracing;
import dev.specbinder.reporter.ExecutionBoundaryListener;
import dev.specbinder.reporter.SpecBinderReporter;

import java.nio.file.Path;
import java.time.Instant;
import java.util.Map;

/**
 * The whole integration, in one class: it turns SpecBinder's execution boundaries into
 * Playwright trace chunks, one self-contained zip per Gherkin step, and records each zip's
 * path onto that step in the JSON execution report.
 * <p>
 * Tracing is started once for the whole feature by {@link PlaywrightTracing}. This listener
 * then rides Playwright's <em>chunked</em> tracing on top of it:
 * <ul>
 *     <li>{@code scenarioStarted} — pick the output folder for the scenario about to run and
 *     reset the step counter.</li>
 *     <li>{@code stepStarted} — open a chunk and tell the report where its zip will land.</li>
 *     <li>{@code stepFinished} — close the chunk, writing the zip to that path.</li>
 * </ul>
 * The result is {@code target/playwright-traces/<testMethod>/<NN>_<stepMethod>.zip} — one file
 * per step, each openable on its own.
 * <p>
 * <strong>Single-threaded on purpose.</strong> The mutable fields below assume one feature
 * recording at a time, which is what this example does. A suite that runs test classes
 * concurrently needs this state scoped per thread (a {@code ThreadLocal}), or chunks from
 * different features will interleave into the wrong trace.
 */
public final class PlaywrightTraceListener implements ExecutionBoundaryListener {

    private final BrowserContext browserContext;
    private final Path baseDir;

    private String scenarioFolder;
    private int stepOrdinal;
    private Path currentChunk;

    public PlaywrightTraceListener(BrowserContext browserContext, Path baseDir) {
        this.browserContext = browserContext;
        this.baseDir = baseDir;
    }

    @Override
    public void scenarioStarted(ScenarioBoundary scenario) {
        /*
         * testMethodName is already rule-qualified and unique within the test class (e.g.
         * "rule_1_scenario_2"), so it needs no extra rule segment. Scenario Outline rows share one
         * method name, so the 1-based row index disambiguates them.
         */
        String folder = scenario.testMethodName() != null ? scenario.testMethodName() : "scenario";
        if (scenario.exampleRowIndex() != null) {
            folder += String.format("_ex_%02d", scenario.exampleRowIndex());
        }
        scenarioFolder = folder;
        stepOrdinal = 0;
    }

    @Override
    public void stepStarted(StepBoundary step) {
        if (scenarioFolder == null) {
            return;
        }
        currentChunk = baseDir.resolve(scenarioFolder)
                .resolve(String.format("%02d_%s.zip", ++stepOrdinal, step.methodName()));

        /*
         * Record the path now, at stepStarted, not at stepFinished: recordPublishedEntry attaches to
         * whichever step is in flight, and the reporter has already cleared that by the time the step
         * finishes. The zip itself does not exist yet — stopChunk writes it moments later, well before
         * anything reads the report.
         *
         * PLAYWRIGHT_TRACE_ENTRY_KEY is defined by the reporter rather than by us, so that this
         * producer and its consumers (the SpecBinder IntelliJ plugin) agree on one name.
         */
        SpecBinderReporter.recordPublishedEntry(
                Map.of(PLAYWRIGHT_TRACE_ENTRY_KEY, currentChunk.toString()), Instant.now());

        browserContext.tracing().startChunk();
    }

    @Override
    public void stepFinished(StepBoundary step) {
        if (currentChunk == null) {
            return;
        }
        Path chunk = currentChunk;
        currentChunk = null;
        // Playwright creates the parent directories for the chunk path itself.
        browserContext.tracing().stopChunk(new Tracing.StopChunkOptions().setPath(chunk));
    }
}
