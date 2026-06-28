package dev.specbinder.examples.commonusecases.junitparameters;

import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.annotations.Gherkin2JUnitOptions;
import dev.specbinder.annotations.JUnitResolved;
import org.junit.jupiter.api.TestInfo;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.api.io.TempDir;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Clock;

import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Marker class demonstrating JUnit ParameterResolver injection in step methods.
 * <p>
 * The {@code @ExtendWith(FixedClockResolver.class)} registers a custom resolver
 * for the {@link Clock} type. SpecBinder's annotation processor sees
 * {@code @JUnitResolved Clock} on the step methods and propagates the parameter
 * to the generated {@code @Test} method, where JUnit fills it at runtime via
 * the resolver. The built-in types ({@code @TempDir Path}, {@link TestInfo})
 * are recognized implicitly and need no marker.
 */
@Gherkin2JUnit("specs/ReceiptWriter.feature")
@Gherkin2JUnitOptions(shouldBeAbstract = false)
@ExtendWith(FixedClockResolver.class)
public abstract class ReceiptWriterFeature {

    private Path receiptFile;

    /**
     * Mixes a Gherkin-derived parameter ({@code orderId}), a built-in
     * injected parameter ({@code @TempDir Path}), and a custom injected
     * parameter ({@code @JUnitResolved Clock}) on a single step.
     */
    public void anOrder$p1WithItemsHasBeenPlaced(
            String orderId,
            @TempDir Path receiptsDir,
            @JUnitResolved Clock clock) {
        receiptFile = receiptsDir.resolve(orderId + ".txt");
        try {
            Files.writeString(receiptFile, "Order " + orderId + " issued at " + clock.instant());
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    /**
     * Built-in {@link TestInfo} injection — used here only to enrich
     * the assertion failure message with the test display name.
     */
    public void theReceiptFileExists(TestInfo testInfo) {
        assertTrue(Files.exists(receiptFile),
                () -> "no receipt file for test: " + testInfo.getDisplayName());
    }

    /**
     * Custom {@code @JUnitResolved Clock} only — verifies the file content
     * carries the fixed clock's instant, proving the resolver fired.
     */
    public void theReceiptIsTimestampedWithTheTestClock(@JUnitResolved Clock clock) {
        String content;
        try {
            content = Files.readString(receiptFile);
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
        assertTrue(content.contains(clock.instant().toString()),
                () -> "receipt did not contain expected timestamp: " + content);
    }
}
