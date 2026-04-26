package dev.specbinder.reporter.steps;

import io.cucumber.java.Scenario;

import java.io.IOException;
import java.net.URI;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Comparator;
import java.util.stream.Stream;

/**
 * Per-scenario working directory that mirrors the annotation-processor's convention:
 * <pre>
 *   target/feature-tests-output/&lt;feature-package-path&gt;/&lt;FeatureName&gt;/Scenario_line_&lt;N&gt;/
 *     &lt;input&gt;     ← fixture .java + .class produced by the Given step
 *     &lt;output&gt;    ← copy of the listener-produced JSON report for post-mortem
 * </pre>
 * Cleared and re-created at the start of each scenario so failures leave the
 * exact inputs and outputs that triggered them on disk.
 */
final class ScenarioWorkspace {

    private static final Path BASE = Paths.get("target", "feature-tests-output");

    private ScenarioWorkspace() {
    }

    /**
     * Resolve the per-scenario directory from the cucumber {@link Scenario}, clear any
     * previous contents, and return the absolute path.
     */
    static Path prepare(Scenario scenario) throws IOException {
        Path dir = BASE.resolve(scenarioRelativePath(scenario));
        deleteRecursively(dir);
        Files.createDirectories(dir);
        return dir;
    }

    private static Path scenarioRelativePath(Scenario scenario) {
        String featureRelative = featurePackagePath(scenario.getUri());
        Path featurePath = Paths.get(featureRelative);
        Path parent = featurePath.getParent();
        String filename = featurePath.getFileName().toString();
        String featureNameNoExt = stripExtension(filename);

        Path dir = (parent == null) ? Paths.get(featureNameNoExt) : parent.resolve(featureNameNoExt);
        return dir.resolve("Scenario_line_" + scenario.getLine());
    }

    /**
     * Strip the {@code classpath:} or {@code .../src/test/resources/} prefix from a
     * cucumber scenario URI, leaving the feature's path relative to the resources root
     * (e.g. {@code features/listener/PassingScenario.feature}).
     */
    private static String featurePackagePath(URI uri) {
        String full = uri.toString();
        if (full.startsWith("classpath:")) {
            return full.substring("classpath:".length());
        }
        String marker = "src/test/resources/";
        int idx = full.indexOf(marker);
        return idx >= 0 ? full.substring(idx + marker.length()) : full;
    }

    private static String stripExtension(String filename) {
        int dot = filename.lastIndexOf('.');
        return dot > 0 ? filename.substring(0, dot) : filename;
    }

    private static void deleteRecursively(Path root) throws IOException {
        if (!Files.exists(root)) {
            return;
        }
        try (Stream<Path> walk = Files.walk(root)) {
            walk.sorted(Comparator.reverseOrder())
                    .map(Path::toFile)
                    .forEach(java.io.File::delete);
        }
    }
}
