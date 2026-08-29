package dev.specbinder.processor.gherkin;

import dev.specbinder.processor.config.GeneratorOptions;
import dev.specbinder.processor.config.StripBetweenPattern;
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
 * <p>Two options feed this, and both reduce to the same rule — <b>every span they identify is removed</b>:
 * <ul>
 *     <li>{@code stripBetweenPatterns} declares the two ends of a span separately. Each {@code start}
 *     pairs with the <em>nearest</em> following {@code end}, and the span is located by offset, so neither
 *     pattern needs a DOTALL flag to cross lines and neither needs a reluctant quantifier. A {@code start}
 *     with no following {@code end} leaves the text untouched.</li>
 *     <li>{@code stripPatterns} removes each match of a single regex. What that regex matches decides what
 *     disappears — match only a marker and the text it wrapped survives.</li>
 * </ul>
 *
 * <p>Between-pairs are applied first, then patterns. The order is observable: a marker-only pattern
 * applied first could strip the markers a between-pair was relying on, leaving text the author had marked
 * as removed.
 *
 * <p>Removal happens in two steps so that a span may wrap whole Gherkin constructs without corrupting the
 * document. Matches are first replaced by the newlines they contained, which keeps every line at its
 * original number while diagnostics are produced; afterwards, any line that a removal left containing only
 * whitespace is dropped entirely. Dropping those lines is what allows a data table or {@code Examples} row
 * to be removed — a blank line left mid-table would otherwise terminate the table and orphan every row
 * below it. Lines that were already blank are never dropped, because a blank line inside a doc string is
 * content.
 */
public final class SpecTextStripper {

    private static final String OPTION_NAME = "stripPatterns";
    private static final String BETWEEN_OPTION_NAME = "stripBetweenPatterns";

    /**
     * Matches a line left holding nothing but a Gherkin step keyword.
     */
    private static final Pattern STEP_KEYWORD_ONLY_LINE =
            Pattern.compile("^\\s*(Given|When|Then|And|But|\\*)\\s*$");

    private final List<CompiledBetweenPattern> betweenPatterns;
    private final List<Pattern> stripPatterns;

    /**
     * A {@code stripBetweenPatterns} entry with both ends compiled.
     */
    private record CompiledBetweenPattern(Pattern start, Pattern end) {
    }

    private SpecTextStripper(List<CompiledBetweenPattern> betweenPatterns, List<Pattern> stripPatterns) {
        this.betweenPatterns = betweenPatterns;
        this.stripPatterns = stripPatterns;
    }

    /**
     * Compiles the patterns configured on the given options.
     *
     * @param options the resolved generator options for the annotated class
     * @return a stripper for those options
     * @throws ProcessingException if any configured pattern is not a valid regular expression, or a
     *                             between-pair is missing one of its two ends
     */
    public static SpecTextStripper from(GeneratorOptions options) {
        return new SpecTextStripper(
                compileBetweenPatterns(options.getStripBetweenPatterns()),
                compileAll(options.getStripPatterns())
        );
    }

    private static List<CompiledBetweenPattern> compileBetweenPatterns(StripBetweenPattern[] betweenPatterns) {
        List<CompiledBetweenPattern> compiled = new ArrayList<>();
        if (betweenPatterns == null) {
            return compiled;
        }
        for (StripBetweenPattern betweenPattern : betweenPatterns) {
            if (betweenPattern == null) {
                continue;
            }
            String start = betweenPattern.start();
            String end = betweenPattern.end();
            if (start == null || start.isBlank() || end == null || end.isBlank()) {
                throw new ProcessingException(
                        "Invalid " + BETWEEN_OPTION_NAME + " entry: both start and end must be set");
            }
            compiled.add(new CompiledBetweenPattern(
                    compile(start, BETWEEN_OPTION_NAME),
                    compile(end, BETWEEN_OPTION_NAME)));
        }
        return compiled;
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
            compiled.add(compile(pattern, OPTION_NAME));
        }
        return compiled;
    }

    private static Pattern compile(String pattern, String optionName) {
        try {
            return Pattern.compile(pattern);
        } catch (PatternSyntaxException e) {
            throw new ProcessingException(
                    "Invalid regular expression in " + optionName + " option: '" + pattern + "' - "
                            + e.getDescription());
        }
    }

    /**
     * Enabled or not.
     * @return true if at least one pattern is configured
     */
    public boolean isEnabled() {
        return !betweenPatterns.isEmpty() || !stripPatterns.isEmpty();
    }

    /**
     * Removes every span identified by the configured options from the given spec file content.
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
        for (CompiledBetweenPattern betweenPattern : betweenPatterns) {
            working = removeSpansKeepingLineCount(working, findSpansBetween(working, betweenPattern), touchedLines);
        }
        for (Pattern stripPattern : stripPatterns) {
            working = removeSpansKeepingLineCount(working, findSpansMatching(working, stripPattern), touchedLines);
        }

        failIfAnyStepLostItsText(working);

        return dropEmptiedLines(working, touchedLines);
    }

    /**
     * Collects the span of every match of the pattern.
     */
    private static List<int[]> findSpansMatching(String content, Pattern pattern) {
        List<int[]> spans = new ArrayList<>();
        Matcher matcher = pattern.matcher(content);
        while (matcher.find()) {
            if (matcher.end() > matcher.start()) {
                // a zero-length match removes nothing - skip it rather than record a phantom span
                spans.add(new int[]{matcher.start(), matcher.end()});
            }
        }
        return spans;
    }

    /**
     * Collects the span from each start marker to the nearest end marker that follows it. A start with no
     * following end leaves the text untouched, and ends the scan — any later end would already have been
     * found by this start, so no later start can pair either.
     */
    private static List<int[]> findSpansBetween(String content, CompiledBetweenPattern betweenPattern) {
        List<int[]> spans = new ArrayList<>();
        Matcher startMatcher = betweenPattern.start().matcher(content);
        Matcher endMatcher = betweenPattern.end().matcher(content);

        int scanFrom = 0;
        while (scanFrom <= content.length() && startMatcher.find(scanFrom)) {
            if (!endMatcher.find(startMatcher.end())) {
                break;
            }
            int spanEnd = endMatcher.end();
            if (spanEnd <= scanFrom) {
                // no forward progress - stop rather than spin on zero-length matches
                break;
            }
            spans.add(new int[]{startMatcher.start(), spanEnd});
            scanFrom = spanEnd;
        }
        return spans;
    }

    /**
     * Removes each span, replacing it with the newlines it contained so that all following lines keep
     * their original line number, and records which lines the removal touched. Spans must be
     * non-overlapping and in ascending order, which is how both finders produce them.
     */
    private static String removeSpansKeepingLineCount(String content, List<int[]> spans, Set<Integer> touchedLines) {

        if (spans.isEmpty()) {
            return content;
        }

        StringBuilder result = new StringBuilder(content.length());
        int copiedUpTo = 0;
        int lineAtCopiedUpTo = 1;

        for (int[] span : spans) {
            int spanStart = span[0];
            int spanEnd = span[1];

            result.append(content, copiedUpTo, spanStart);

            int firstLineOfSpan = lineAtCopiedUpTo + countNewlines(content, copiedUpTo, spanStart);
            int newlinesInSpan = countNewlines(content, spanStart, spanEnd);
            for (int i = 0; i <= newlinesInSpan; i++) {
                touchedLines.add(firstLineOfSpan + i);
            }

            result.append("\n".repeat(newlinesInSpan));

            copiedUpTo = spanEnd;
            lineAtCopiedUpTo = firstLineOfSpan + newlinesInSpan;
        }

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
