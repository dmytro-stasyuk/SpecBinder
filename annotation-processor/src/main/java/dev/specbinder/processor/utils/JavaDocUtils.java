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
     * Generates a JavaDoc comment for a given keyword, name, and description.
     *
     * @param keyword     the keyword to include in the JavaDoc
     * @param name        the name to include in the JavaDoc, can be null
     * @param description the description to include in the JavaDoc, can be null
     * @return a formatted JavaDoc comment as a string
     */
    public static String toJavaDoc(String keyword, String name, String description) {

        StringBuilder javaDocSB = new StringBuilder()
                .append("/**")
                .append("\n * ").append(keyword).append(":");

        if (StringUtils.isNotBlank(name)) {
            javaDocSB
                    .append(" ")
                    .append(name);
        }

        if (StringUtils.isNotBlank(description)) {
            String[] lines = description.split("\n");
            for (String line : lines) {
                javaDocSB.append("\n * ").append(line);
            }
        }
        javaDocSB.append("\n */\n");

        return javaDocSB.toString();
    }

    /**
     * Generates a JavaDoc content string for a given keyword, name, and description. Similar to
     * {@link #toJavaDoc(String, String, String)} but doesn't include the JavaDoc comment syntax (i.e., no "/**" or " * ").
     *
     * @param keyword the keyword of the element
     * @param name the name of the element, i.e. part of text that's on the same line as the keyword
     * @param description the description of the element
     * @return JavaDoc content comprised of the keyword, name, and description formatted as a string.
     */
    public static String toJavaDocContent(String keyword, String name, String description) {

        StringBuilder javaDocSB = new StringBuilder()
                .append(escapeForJavaPoet(keyword)).append(":");

        if (StringUtils.isNotBlank(name)) {
            javaDocSB.append(" ").append(escapeForJavaPoet(name));
        }

        if (StringUtils.isNotBlank(description)) {
            String[] lines = description.split("\n");
            for (String line : lines) {
                line = line.trim();
                javaDocSB.append("\n  ").append(escapeForJavaPoet(line));
            }
        }

        return javaDocSB.toString();
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

    /**
     * Formats a multi-line string as a JavaDoc comment.
     *
     * @param multiLineString the multi-line string to format
     * @return a formatted JavaDoc comment as a string
     */
    public static String multiLineStringAsJavaDoc(String multiLineString) {

        StringBuilder sb = new StringBuilder();
        sb.append("/**\n");
        for (String line : multiLineString.split("\n")) {
            sb.append(" * ").append(line).append("\n");
        }
        sb.append(" */\n");
        return sb.toString();
    }

}
