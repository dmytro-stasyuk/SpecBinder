package dev.specbinder.examples.commonusecases.junitparameters;

import org.junit.jupiter.api.extension.ExtensionContext;
import org.junit.jupiter.api.extension.ParameterContext;
import org.junit.jupiter.api.extension.ParameterResolver;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;

/**
 * Custom JUnit 5 {@link ParameterResolver} that supplies a fixed {@link Clock}
 * for deterministic timestamps in tests.
 * <p>
 * Registered on the marker class via {@code @ExtendWith(FixedClockResolver.class)}.
 * Step methods opt into receiving the resolved {@code Clock} by annotating the
 * parameter with {@code @JUnitInject} — this is what tells the SpecBinder
 * processor to propagate the parameter from the base step method through to
 * the generated {@code @Test} method.
 */
public class FixedClockResolver implements ParameterResolver {

    private static final Clock FIXED = Clock.fixed(
            Instant.parse("2024-01-15T10:00:00Z"),
            ZoneOffset.UTC);

    @Override
    public boolean supportsParameter(ParameterContext parameterContext, ExtensionContext extensionContext) {
        return parameterContext.getParameter().getType().equals(Clock.class);
    }

    @Override
    public Object resolveParameter(ParameterContext parameterContext, ExtensionContext extensionContext) {
        return FIXED;
    }
}
