package dev.specbinder.reporter;

import java.nio.file.Path;

/**
 * Test-only bridge exposing {@link ReportPaths}'s package-private override hooks to
 * step definitions in {@code dev.specbinder.reporter.steps}. Lives in test sources
 * so it never ships in the production jar.
 */
public final class ReportPathsTestSeam {

    private ReportPathsTestSeam() {
    }

    /** Pin the listener's report directory to {@code dir} for the next execution. */
    public static void redirectReportsTo(Path dir) {
        ReportPaths.setOverrideForTesting(dir);
    }

    /** Restore default (build-tool walk-up) behaviour. */
    public static void clearRedirect() {
        ReportPaths.clearOverrideForTesting();
    }
}
