package dev.specbinder.examples.goingfurther.junitparameters;

import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.annotations.JUnitResolved;
import org.junit.jupiter.api.TestInfo;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.api.io.TempDir;

import java.nio.file.Path;
import java.time.Clock;

/**
 * Marker class demonstrating JUnit parameter resolution in step methods.
 * <p>
 * The step methods that need JUnit-resolved parameters are declared here, abstract, with
 * their full signatures. The generator only propagates resolved parameters for step methods
 * it finds in the marker's hierarchy — it cannot see a subclass of the generated class — so
 * the declarations live here while ReceiptWriterTest supplies the implementations.
 * <p>
 * The {@code @ExtendWith(FixedClockResolver.class)} registers a custom resolver for the
 * {@link Clock} type. The generator sees {@code @JUnitResolved Clock} on the step methods and
 * propagates the parameter to the generated {@code @Test} method, where JUnit fills it at
 * runtime via the resolver. The built-in types ({@code @TempDir Path}, {@link TestInfo}) are
 * recognized implicitly and need no marker.
 * <p>
 * No path in @Gherkin2JUnit — the processor discovers the co-located ReceiptWriter.specb in
 * this package by convention.
 */
@Gherkin2JUnit
@ExtendWith(FixedClockResolver.class)
public abstract class ReceiptWriterFeature {

    /**
     * Mixes a Gherkin-derived parameter ({@code orderId}), a built-in resolved parameter
     * ({@code @TempDir Path}), and a custom resolved parameter ({@code @JUnitResolved Clock}).
     */
    public abstract void anOrder$p1WithItemsHasBeenPlaced(
            String orderId,
            @TempDir Path receiptsDir,
            @JUnitResolved Clock clock);

    /**
     * Built-in {@link TestInfo} resolution.
     */
    public abstract void theReceiptFileExists(TestInfo testInfo);

    /**
     * Custom {@code @JUnitResolved Clock} only.
     */
    public abstract void theReceiptIsTimestampedWithTheTestClock(@JUnitResolved Clock clock);
}
