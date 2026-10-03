package dev.specbinder.examples.goingfurther.junitparameters;

import org.junit.jupiter.api.TestInfo;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.Clock;

import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Concrete test class that implements the step methods declared in ReceiptWriterFeature.
 * The JUnit-resolved values arrive as ordinary arguments: the generated @Test method
 * receives them from JUnit and passes them on to each step that declared them.
 */
public class ReceiptWriterTest extends ReceiptWriterScenarios {

    private Path receiptFile;

    @Override
    public void anOrder$p1WithItemsHasBeenPlaced(String orderId, Path receiptsDir, Clock clock) {
        receiptFile = receiptsDir.resolve(orderId + ".txt");
        try {
            Files.writeString(receiptFile, "Order " + orderId + " issued at " + clock.instant());
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    /**
     * {@link TestInfo} is used here only to enrich the assertion failure message with the
     * test display name.
     */
    @Override
    public void theReceiptFileExists(TestInfo testInfo) {
        assertTrue(Files.exists(receiptFile),
                () -> "no receipt file for test: " + testInfo.getDisplayName());
    }

    /**
     * Verifies the file content carries the fixed clock's instant, proving the resolver fired.
     */
    @Override
    public void theReceiptIsTimestampedWithTheTestClock(Clock clock) {
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
