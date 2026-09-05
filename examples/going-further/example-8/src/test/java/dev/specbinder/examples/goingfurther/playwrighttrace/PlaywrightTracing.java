package dev.specbinder.examples.goingfurther.playwrighttrace;

import com.microsoft.playwright.*;
import dev.specbinder.reporter.SpecBinderReporter;
import org.junit.jupiter.api.extension.AfterAllCallback;
import org.junit.jupiter.api.extension.BeforeAllCallback;
import org.junit.jupiter.api.extension.ExtensionContext;

import java.nio.file.Path;

/**
 * Browser lifecycle for the feature: launches Chromium, starts one trace for the whole run, and
 * registers the {@link PlaywrightTraceListener} that slices that trace into per-step chunks.
 * <p>
 * Ordinary JUnit plumbing — nothing here is SpecBinder-specific except the two lines that add and
 * remove the boundary listener. Keeping the browser open for the whole feature rather than
 * per-scenario is what makes chunked tracing possible: {@code tracing().start()} runs once, and each
 * step is a {@code startChunk()} / {@code stopChunk()} pair inside it.
 * <p>
 * The page is exposed through a static accessor for brevity. That is safe here because this example
 * runs one feature at a time; see {@link PlaywrightTraceListener} on what parallel execution needs.
 */
public class PlaywrightTracing implements BeforeAllCallback, AfterAllCallback {

    private static Playwright playwright;
    private static Browser browser;
    private static BrowserContext browserContext;
    private static Page page;

    private PlaywrightTraceListener traceListener;

    /** The live page, for step methods to drive. */
    public static Page page() {
        return page;
    }

    @Override
    public void beforeAll(ExtensionContext context) {
        playwright = Playwright.create();
        browser = playwright.chromium().launch();
        browserContext = browser.newContext();
        page = browserContext.newPage();

        // sources=true makes the trace viewer show the Java frame that issued each action.
        browserContext.tracing().start(new Tracing.StartOptions()
                .setScreenshots(true)
                .setSnapshots(true)
                .setSources(true));

        Path baseDir = Path.of("target", "playwright-traces");
        traceListener = new PlaywrightTraceListener(browserContext, baseDir);
        SpecBinderReporter.addBoundaryListener(traceListener);
    }

    @Override
    public void afterAll(ExtensionContext context) {
        SpecBinderReporter.removeBoundaryListener(traceListener);

        /*
         * stop() without a path deliberately: the per-step chunks already own the output, so there is
         * no monolithic feature-wide zip to write. This just switches the tracer off.
         */
        browserContext.tracing().stop();

        page.close();
        browserContext.close();
        browser.close();
        playwright.close();
    }
}
