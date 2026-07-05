package dev.specbinder.processor.utils;

import org.apache.commons.lang3.StringUtils;

/**
 * Utility class for generating JavaDoc comments.
 */
public class JavaDocUtils {

    private JavaDocUtils() {
        /**
         * utility class
         */
    }

    /**
     * Escapes dollar signs in a string for use in JavaPoet format strings.
     * JavaPoet treats {@code $} as a format specifier (e.g., {@code $T}, {@code $S}, {@code $L}).
     * Literal dollar signs must be escaped as {@code $$}.
     *
     * @param text the text to escape
     * @return the text with all {@code $} replaced by {@code $$}
     */
    public static String escapeForJavaPoet(String text) {
        if (text == null) {
            return null;
        }
        return text.replace("$", "$$");
    }

    /**
     * Escapes text for inclusion inside a JavaDoc block comment. In addition to the JavaPoet
     * {@code $} escaping performed by {@link #escapeForJavaPoet(String)}, this neutralizes any
     * asterisk-slash sequence, which would otherwise prematurely close the surrounding block comment
     * and produce uncompilable code. The slash is replaced with its HTML entity {@code &#47;}, so the
     * text still renders as a literal slash in generated documentation while no longer forming a
     * comment-terminator sequence.
     *
     * @param text the text to escape, can be null
     * @return the JavaDoc-safe text, or {@code null} if {@code text} is {@code null}
     */
    public static String escapeForJavaDoc(String text) {
        if (text == null) {
            return null;
        }
        String commentSafe = text.replace("*/", "*&#47;");
        return escapeForJavaPoet(commentSafe);
    }

    /**
     * Trims leading and trailing whitespace from each line in a multi-line string.
     *
     * @param multiLineString the multi-line string to trim
     * @return a new string with each line trimmed of leading and trailing whitespace
     */
    public static String trimLeadingAndTrailingWhitespace(String multiLineString) {

        String[] lines = multiLineString.split("\n");
        for (int i = 0; i < lines.length; i++) {
            String line = lines[i];
            String trimmedLine = line.trim();
            lines[i] = trimmedLine;
        }
        String trimmedLines = StringUtils.join(lines, "\n");
        return trimmedLines;
    }

}
