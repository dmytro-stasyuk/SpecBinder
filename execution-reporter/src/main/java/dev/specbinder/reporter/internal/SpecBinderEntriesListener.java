package dev.specbinder.reporter.internal;

import dev.specbinder.reporter.SpecBinderReporter;
import org.junit.platform.engine.reporting.ReportEntry;
import org.junit.platform.launcher.TestExecutionListener;
import org.junit.platform.launcher.TestIdentifier;

import java.time.ZoneId;

/**
 * JUnit Platform {@code TestExecutionListener} that bridges
 * {@link org.junit.jupiter.api.TestReporter#publishEntry} calls made inside SpecBinder
 * step bodies into the per-step report. Registered via {@code ServiceLoader}
 * (see {@code META-INF/services/org.junit.platform.launcher.TestExecutionListener})
 * so the JUnit Platform Launcher picks it up automatically on any classpath that
 * has {@code execution-reporter} on it.
 * <p>
 * Kept as a separate class — not folded into {@link SpecBinderReporter} — so the
 * Launcher SPI registration is a self-contained aspect and {@code SpecBinderReporter}
 * stays focused on the Jupiter Extension surface that consumers configure via
 * {@code @ExtendWith}.
 * <p>
 * Outside an active SpecBinder scenario (i.e. when no scenario step buffer is on the
 * current thread) the bridge silently no-ops, so non-SpecBinder tests that publish
 * entries are unaffected.
 */
public final class SpecBinderEntriesListener implements TestExecutionListener {

    @Override
    public void reportingEntryPublished(TestIdentifier testIdentifier, ReportEntry entry) {
        SpecBinderReporter.recordPublishedEntry(
                entry.getKeyValuePairs(),
                entry.getTimestamp().atZone(ZoneId.systemDefault()).toInstant());
    }
}
