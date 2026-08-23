package dev.specbinder.processor.gherkin;

import dev.specbinder.processor.config.GeneratorOptions;
import dev.specbinder.processor.exception.ProcessingException;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

/**
 * Strips configured text from a Gherkin spec file before it is handed to the parser.
 *
 * <p>Teams often annotate specs with revision markers tying wording back to an issue tracker, such as
 * {@code <CHANGED BR-123>premium</CHANGED BR-123>} or {@code <REMOVED BR-789>legacy </REMOVED BR-789>}.
 * Left in place those markers reach generated Java, where they change step method names, corrupt record
 * type and field names derived from data table headers, and emit unbalanced HTML into JavaDoc.
 *
 * <p>There is a single rule: <b>every match of every configured pattern is removed</b>. What a pattern
 * matches therefore decides what disappears — a pattern matching only a marker keeps the text that marker
 * wrapped, while a pattern matching an opening marker through a closing marker takes the wrapped text with
 * it. No separate configuration distinguishes the two shapes.
 *
 * <p>Patterns are applied in declaration order, and the order is observable when they overlap: a
 * marker-only pattern applied first can strip the markers a wrapping pattern was relying on, leaving text
 * the author had marked as removed. Wrapping patterns should be listed first.
 *
 * <p>Removal happens in two steps so that a pattern may wrap whole Gherkin constructs without corrupting
 * the document. Matches are first replaced by the newlines they contained, which keeps every line at its
 * original number while diagnostics are produced; afterwards, any line that a removal left containing only
 * whitespace is dropped entirely. Dropping those lines is what allows a data table or {@code Examples} row
 * to be removed — a blank line left mid-table would otherwise terminate the table and orphan every row
 * below it. Lines that were already blank are never dropped, because a blank line inside a doc string is
 * content.
 */
public final class SpecTextStripper {

    private static final String OPTION_NAME = "stripPatterns";

    /**
     * Matches a line left holding nothing but a Gherkin step keyword.
     */
    private static final Pattern STEP_KEYWORD_ONLY_LINE =
            Pattern.compile("^\\s*(Given|When|Then|And|But|\\*)\\s*$");

    private final List<Pattern> stripPatterns;

    private SpecTextStripper(List<Pattern> stripPatterns) {
        this.stripPatterns = stripPatterns;
    }

    /**
     * Compiles the patterns configured on the given options.
     *
     * @param options the resolved generator options for the annotated class
     * @return a stripper for those options
     * @throws ProcessingException if any configured pattern is not a valid regular expression
     */
    public static SpecTextStripper from(GeneratorOptions options) {
        return new SpecTextStripper(compileAll(options.getStripPatterns()));
    }

    private static List<Pattern> compileAll(String[] patterns) {
        List<Pattern> compiled = new ArrayList<>();
        if (patterns == null) {
            return compiled;
        }
        for (String pattern : patterns) {
            if (pattern == null || pattern.isEmpty()) {
                continue;
            }
            try {
                compiled.add(Pattern.compile(pattern));
            } catch (PatternSyntaxException e) {
                throw new ProcessingException(
                        "Invalid regular expression in " + OPTION_NAME + " option: '" + pattern + "' - "
                                + e.getDescription());
            }
        }
        return compiled;
    }

    /**
     * Enabled or not.
     * @return true if at least one pattern is configured
     */
    public boolean isEnabled() {
        return !stripPatterns.isEmpty();
    }

    /**
     * Removes every match of every configured pattern from the given spec file content.
     *
     * @param content the raw spec file content
     * @return the content with the configured text removed
     * @throws ProcessingException if a removal leaves a step keyword with no text after it
     */
    public String strip(String content) {
        if (!isEnabled() || content == null || content.isEmpty()) {
            return content;
        }

        Set<Integer> touchedLines = new HashSet<>();

        String working = content;
        for (Pattern stripPattern : stripPatterns) {
            working = removeKeepingLineCount(working, stripPattern, touchedLines);
        }

        failIfAnyStepLostItsText(working);

        return dropEmptiedLines(working, touchedLines);
    }

    /**
     * Removes every match of the pattern, replacing it with the newlines it contained so that all
     * following lines keep their original line number, and records which lines the removal touched.
     */
    private static String removeKeepingLineCount(String content, Pattern pattern, Set<Integer> touchedLines) {

        Matcher matcher = pattern.matcher(content);
        if (!matcher.find()) {
            return content;
        }

        StringBuilder result = new StringBuilder(content.length());
        int copiedUpTo = 0;
        int lineAtCopiedUpTo = 1;

        do {
            if (matcher.end() == matcher.start()) {
                // a zero-length match removes nothing - skip it rather than record a phantom touch
                continue;
            }

            result.append(content, copiedUpTo, matcher.start());

            int firstLineOfMatch = lineAtCopiedUpTo + countNewlines(content, copiedUpTo, matcher.start());
            int newlinesInMatch = countNewlines(content, matcher.start(), matcher.end());
            for (int i = 0; i <= newlinesInMatch; i++) {
                touchedLines.add(firstLineOfMatch + i);
            }

            result.append("\n".repeat(newlinesInMatch));

            copiedUpTo = matcher.end();
            lineAtCopiedUpTo = firstLineOfMatch + newlinesInMatch;

        } while (matcher.find());

        result.append(content, copiedUpTo, content.length());
        return result.toString();
    }

    /**
     * Fails the build when a removal has taken all of a step's text but left its keyword behind, rather
     * than letting a step with no text reach code generation. Line numbers are still the original ones at
     * this point, because removals have preserved the line count.
     */
    private static void failIfAnyStepLostItsText(String content) {
        String[] lines = content.split("\n", -1);
        for (int i = 0; i < lines.length; i++) {
            if (STEP_KEYWORD_ONLY_LINE.matcher(lines[i]).matches()) {
                throw new ProcessingException(
                        "Step on line - " + (i + 1)
                                + " has no text left after pattern removal - include the step keyword in the"
                                + " matched text");
            }
        }
    }

    /**
     * Drops every line that a removal left containing only whitespace. Lines that were already blank are
     * kept, because a blank line inside a doc string is content rather than an artefact of stripping.
     */
    private static String dropEmptiedLines(String content, Set<Integer> touchedLines) {
        if (touchedLines.isEmpty()) {
            return content;
        }

        String[] lines = content.split("\n", -1);
        List<String> keptLines = new ArrayList<>(lines.length);
        for (int i = 0; i < lines.length; i++) {
            boolean emptiedByRemoval = touchedLines.contains(i + 1) && lines[i].isBlank();
            if (!emptiedByRemoval) {
                keptLines.add(lines[i]);
            }
        }
        return String.join("\n", keptLines);
    }

    private static int countNewlines(String text, int fromIndex, int toIndex) {
        int newlines = 0;
        for (int i = fromIndex; i < toIndex; i++) {
            if (text.charAt(i) == '\n') {
                newlines++;
            }
        }
        return newlines;
    }
}
