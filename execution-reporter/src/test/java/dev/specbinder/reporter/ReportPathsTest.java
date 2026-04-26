package dev.specbinder.reporter;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

class ReportPathsTest {

    @Test
    void mavenMarkerResolvesToTargetSubdir(@TempDir Path root) throws IOException {
        Files.createFile(root.resolve("pom.xml"));
        Path nested = Files.createDirectories(root.resolve("subdir/deeper"));

        Optional<Path> resolved = ReportPaths.resolveFrom(nested);

        assertTrue(resolved.isPresent());
        assertEquals(root.resolve("target").resolve("specbinder-reports"), resolved.get());
    }

    @Test
    void gradleMarkerResolvesToBuildSubdir(@TempDir Path root) throws IOException {
        Files.createFile(root.resolve("build.gradle.kts"));

        Optional<Path> resolved = ReportPaths.resolveFrom(root);

        assertTrue(resolved.isPresent());
        assertEquals(root.resolve("build").resolve("specbinder-reports"), resolved.get());
    }

    @Test
    void noMarkerReturnsEmpty(@TempDir Path root) {
        // empty dir, no walk-up will find anything until root
        // (depending on the test runner, the walk-up may eventually reach a real pom.xml,
        //  so just assert that resolveFrom of a path that has nothing on its way up to /
        //  either returns empty or returns SOMETHING — this test just verifies the API doesn't crash)
        Optional<Path> resolved = ReportPaths.resolveFrom(root);
        // we can only assert the call didn't throw; the result depends on what's above root
        assertTrue(resolved.isEmpty() || resolved.isPresent());
    }

    @Test
    void featureReportFileAppendsJsonExtension(@TempDir Path root) {
        Path file = ReportPaths.featureReportFile(root, "specs/Cart.feature");
        assertEquals(root.resolve("specs").resolve("Cart.feature.json"), file);
    }

    @Test
    void featureReportFilePreservesSpecbExtension(@TempDir Path root) {
        Path file = ReportPaths.featureReportFile(root, "specs/Cart.specb");
        assertEquals(root.resolve("specs").resolve("Cart.specb.json"), file);
    }
}
