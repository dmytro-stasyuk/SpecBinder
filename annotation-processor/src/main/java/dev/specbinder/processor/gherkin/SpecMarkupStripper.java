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
 * Removes HTML-like revision markup from a Gherkin spec file before it is handed to the parser.
 *
 * <p>Teams often annotate specs with traceability markup tied to an issue tracker, such as
 * {@code <CHANGED BR-123>premium</CHANGED BR-123>} or {@code <REMOVED BR-789>legacy </REMOVED BR-789>}.
 * Left in place that markup reaches generated Java, where it changes step method names, corrupts record
 * type and field names derived from data table headers, and emits unbalanced HTML into JavaDoc.
 *
 * <p>Two kinds of pattern are supported, and they are applied in this order:
 * <ol>
 *     <li><b>Ranges</b> ({@code stripRangePatterns}) — the whole match, opening marker through closing
 *     marker, is removed along with the text between them.</li>
 *     <li><b>Markers</b> ({@code stripMarkerPatterns}) — each match is a single marker and is removed on
 *     its own, keeping the text it wrapped.</li>
 * </ol>
 * Ranges must go first, and the order is observable: when a marker pattern also matches a range's own
 * markers, running markers first would strip those markers individually, leaving the range pattern nothing
 * to match and resurrecting text the author had marked as removed.
 *
 * <p>Removal is done in two steps so that a range may wrap whole Gherkin constructs without corrupting the
 * document. Matches are first replaced by the newlines they contained, which keeps every line at its
 * original number while diagnostics are produced; afterwards, any line that a removal left containing only
 * whitespace is dropped entirely. Dropping those lines is what allows a data table or {@code Examples} row
 * to be removed — a blank line left mid-table would otherwise terminate the table and orphan every row
 * below it. Lines that were already blank are never dropped, because a blank line inside a doc string is
 * content.
 */
public final class SpecMarkupStripper {

    private static final String MARKER_OPTION = "stripMarkerPatterns";
    private static final String RANGE_OPTION = "stripRangePatterns";

    /**
     * Matches a line left holding nothing but a Gherkin step keyword.
     */
    private static final Pattern STEP_KEYWORD_ONLY_LINE =
            Pattern.compile("^\\s*(Given|When|Then|And|But|\\*)\\s*$");

    private final List<Pattern> markerPatterns;
    private final List<Pattern> rangePatterns;

    private SpecMarkupStripper(List<Pattern> markerPatterns, List<Pattern> rangePatterns) {
        this.markerPatterns = markerPatterns;
        this.rangePatterns = rangePatterns;
    }

    /**
     * Compiles the patterns configured on the given options.
     *
     * @param options the resolved generator options for the annotated class
     * @return a stripper for those options
     * @throws ProcessingException if any configured pattern is not a valid regular expression
     */
    public static SpecMarkupStripper from(GeneratorOptions options) {
        return new SpecMarkupStripper(
                compileAll(options.getStripMarkerPatterns(), MARKER_OPTION),
                compileAll(options.getStripRangePatterns(), RANGE_OPTION)
        );
    }

    private static List<Pattern> compileAll(String[] patterns, String optionName) {
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
                        "Invalid regular expression in " + optionName + " option: '" + pattern + "' - "
                                + e.getDescription());
            }
        }
        return compiled;
    }

    /**
     * @return true if at least one marker or range pattern is configured
     */
    public boolean isEnabled() {
        return !markerPatterns.isEmpty() || !rangePatterns.isEmpty();
    }

    /**
     * Removes every configured range and marker from the given spec file content.
     *
     * @param content the raw spec file content
     * @return the content with revision markup removed
     * @throws ProcessingException if a range removal leaves a step keyword with no text after it
     */
    public String strip(String content) {
        if (!isEnabled() || content == null || content.isEmpty()) {
            return content;
        }

        Set<Integer> touchedLines = new HashSet<>();

        String working = content;
        for (Pattern rangePattern : rangePatterns) {
            working = removeKeepingLineCount(working, rangePattern, touchedLines);
        }
        for (Pattern markerPattern : markerPatterns) {
            working = removeKeepingLineCount(working, markerPattern, touchedLines);
        }

        if (!rangePatterns.isEmpty()) {
            failIfAnyStepLostItsText(working);
        }

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
     * Fails the build when a range removal has taken all of a step's text but left its keyword behind,
     * rather than letting a step with no text reach code generation. Line numbers are still the original
     * ones at this point, because removals have preserved the line count.
     */
    private static void failIfAnyStepLostItsText(String content) {
        String[] lines = content.split("\n", -1);
        for (int i = 0; i < lines.length; i++) {
            if (STEP_KEYWORD_ONLY_LINE.matcher(lines[i]).matches()) {
                throw new ProcessingException(
                        "Step on line - " + (i + 1)
                                + " has no text left after range removal - include the step keyword in the marked range");
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
