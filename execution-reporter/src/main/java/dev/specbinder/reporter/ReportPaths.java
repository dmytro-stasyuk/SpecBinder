package dev.specbinder.reporter;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Optional;

/**
 * Resolves the directory under which per-feature JSON reports are written.
 * <p>
 * Convention (no overrides in Phase 1):
 * <ul>
 *     <li>Walk up from {@code user.dir} until a directory containing a build-tool marker is found.</li>
 *     <li>If the marker is {@code pom.xml}, write under {@code <dir>/target/specbinder-reports}.</li>
 *     <li>If the marker is a Gradle file, write under {@code <dir>/build/specbinder-reports}.</li>
 *     <li>Otherwise return {@link Optional#empty()} — the caller skips writing and logs once.</li>
 * </ul>
 * <p>
 * The package-private {@link #resolveFrom(Path)} is exposed only for unit tests
 * to drive the algorithm from a chosen root rather than the JVM's working directory.
 */
public final class ReportPaths {

    static final String REPORTS_DIR_NAME = "specbinder-reports";
    private static final List<String> MAVEN_MARKERS = List.of("pom.xml");
    private static final List<String> GRADLE_MARKERS = List.of(
            "build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts"
    );

    /**
     * Test-only override. When non-null, {@link #resolve()} returns this path verbatim,
     * bypassing the build-tool-marker walk-up. Set/cleared via the package-local seam
     * methods below; production code never touches it.
     */
    private static volatile Path overrideForTesting;

    private ReportPaths() {
    }

    /**
     * Resolves the report directory using the JVM's current working directory as the starting point.
     */
    public static Optional<Path> resolve() {
        Path override = overrideForTesting;
        if (override != null) {
            return Optional.of(override);
        }
        String userDir = System.getProperty("user.dir");
        if (userDir == null) {
            return Optional.empty();
        }
        return resolveFrom(Paths.get(userDir));
    }

    /** Test seam — sets a fixed report directory, bypassing the build-tool walk-up. */
    static void setOverrideForTesting(Path dir) {
        overrideForTesting = dir;
    }

    /** Test seam — clears the fixed report directory set by {@link #setOverrideForTesting(Path)}. */
    static void clearOverrideForTesting() {
        overrideForTesting = null;
    }

    /**
     * Walks up from {@code start} looking for a build-tool marker. Test seam.
     */
    static Optional<Path> resolveFrom(Path start) {
        Path current = start.toAbsolutePath().normalize();
        while (current != null) {
            if (containsAny(current, MAVEN_MARKERS)) {
                return Optional.of(current.resolve("target").resolve(REPORTS_DIR_NAME));
            }
            if (containsAny(current, GRADLE_MARKERS)) {
                return Optional.of(current.resolve("build").resolve(REPORTS_DIR_NAME));
            }
            current = current.getParent();
        }
        return Optional.empty();
    }

    /**
     * Builds the per-feature report file path. Appends {@code .json} to the source path so that
     * {@code specs/Cart.feature} → {@code <reportDir>/specs/Cart.feature.json} (extension preserved
     * to avoid collisions when both {@code .feature} and {@code .specb} share a directory).
     */
    public static Path featureReportFile(Path reportDir, String sourceFilePath) {
        Path relative = Paths.get(sourceFilePath + ".json");
        return reportDir.resolve(relative).normalize();
    }

    private static boolean containsAny(Path dir, List<String> fileNames) {
        for (String name : fileNames) {
            if (Files.isRegularFile(dir.resolve(name))) {
                return true;
            }
        }
        return false;
    }
}
