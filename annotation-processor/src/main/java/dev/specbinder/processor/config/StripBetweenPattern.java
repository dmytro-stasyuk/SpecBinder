package dev.specbinder.processor.config;

/**
 * A resolved {@code @StripBetween} entry — the two ends of a span of spec file text to strip.
 *
 * <p>The processor works with this rather than the annotation instance itself, because options are
 * normally resolved from {@code AnnotationMirror}s (where no annotation instance exists) and only fall
 * back to reading real annotations in test environments with mocked elements.
 *
 * @param start regular expression matching the marker that opens the span
 * @param end   regular expression matching the marker that closes the span
 */
public record StripBetweenPattern(String start, String end) {
}
