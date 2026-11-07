package dev.specbinder.specreader;

/**
 * A resolved {@code @StripBetween} entry — the two ends of a span of spec file text to strip.
 *
 * <p>The annotation processor and the execution reporter work with this rather than the annotation instance
 * itself, because the processor normally resolves options from {@code AnnotationMirror}s, where no annotation
 * instance exists.
 *
 * @param start regular expression matching the marker that opens the span
 * @param end   regular expression matching the marker that closes the span
 */
public record StripBetweenPattern(String start, String end) {
}
