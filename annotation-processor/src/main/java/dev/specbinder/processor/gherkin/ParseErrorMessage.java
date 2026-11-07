package dev.specbinder.processor.gherkin;

import io.cucumber.messages.types.Location;
import io.cucumber.messages.types.ParseError;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Turns a parse error reported by the Gherkin parser into a message in plain words, naming the line that can't be
 * read, what was found on it and what was expected there, e.g. {@code Line - 4 can't be read: found 'Invalid user
 * clicks button', but expected a step, a table, a doc string, tags, or an Examples, Scenario or Rule line}.
 */
final class ParseErrorMessage {

    /**
     * The parser's text for a line it can't read: the types of line expected there, then the line found.
     */
    private static final Pattern UNEXPECTED_LINE =
            Pattern.compile("^expected: (?<expected>[#\\w, ]+), got '(?<found>.*)'$", Pattern.DOTALL);

    /**
     * The parser's text for a spec that ends where more lines are expected.
     */
    private static final Pattern UNEXPECTED_END =
            Pattern.compile("^unexpected end of file, expected: (?<expected>[#\\w, ]+)$", Pattern.DOTALL);

    /**
     * The location prefix the parser puts in front of its text, e.g. {@code (4:5): }.
     */
    private static final Pattern LOCATION_PREFIX = Pattern.compile("^\\(\\d+:\\d+\\): ");

    /**
     * Line types named in plain words, in the order they are listed in a message.
     */
    private static final Map<String, String> LINE_NAMES = new LinkedHashMap<>();

    static {
        LINE_NAMES.put("#Language", "a '# language:' header");
        LINE_NAMES.put("#StepLine", "a step");
        LINE_NAMES.put("#TableRow", "a table");
        LINE_NAMES.put("#DocStringSeparator", "a doc string");
        LINE_NAMES.put("#TagLine", "tags");
        LINE_NAMES.put("#Other", "text");
    }

    /**
     * Keyword lines, named by their keyword and listed together as one "Examples, Scenario or Rule line".
     */
    private static final Map<String, String> KEYWORD_LINE_NAMES = Map.of(
            "#FeatureLine", "Feature",
            "#BackgroundLine", "Background",
            "#RuleLine", "Rule",
            "#ScenarioLine", "Scenario",
            "#ExamplesLine", "Examples"
    );

    /**
     * Lines allowed nearly everywhere, which naming would not help with.
     */
    private static final Set<String> ALWAYS_ALLOWED = Set.of("#EOF", "#Comment", "#Empty");

    private ParseErrorMessage() {
    }

    /**
     * Returns the message for a parse error in plain words. A message the parser words in a way this class doesn't
     * know is passed on as it is, after the line number.
     *
     * @param parseError the parse error reported by the Gherkin parser
     * @return the message in plain words
     */
    static String of(ParseError parseError) {

        String message = LOCATION_PREFIX.matcher(parseError.getMessage()).replaceFirst("");

        Matcher unexpectedEnd = UNEXPECTED_END.matcher(message);
        if (unexpectedEnd.matches()) {
            List<String> expected = lineTypes(unexpectedEnd.group("expected"));
            if (expected.contains("#DocStringSeparator")) {
                return "The spec ends inside a doc string that is never closed";
            }
            return "The spec ends too early: expected " + describe(expected);
        }

        long line = parseError.getSource().getLocation().map(Location::getLine).orElse(0L);

        Matcher unexpectedLine = UNEXPECTED_LINE.matcher(message);
        if (unexpectedLine.matches()) {
            return "Line - " + line + " can't be read: found '" + unexpectedLine.group("found").strip()
                    + "', but expected " + describe(lineTypes(unexpectedLine.group("expected")));
        }
        return "Line - " + line + " can't be read: " + message;
    }

    private static List<String> lineTypes(String expected) {
        return Arrays.stream(expected.split(",")).map(String::strip).toList();
    }

    /**
     * Names the expected line types in plain words, e.g. {@code a step, a table, a doc string, tags, or an Examples,
     * Scenario or Rule line}. A line type this class doesn't know is named as the parser names it.
     */
    private static String describe(List<String> lineTypes) {

        List<String> names = new ArrayList<>();
        for (Map.Entry<String, String> lineName : LINE_NAMES.entrySet()) {
            if (lineTypes.contains(lineName.getKey())) {
                names.add(lineName.getValue());
            }
        }

        List<String> keywords = new ArrayList<>();
        for (String lineType : lineTypes) {
            if (KEYWORD_LINE_NAMES.containsKey(lineType)) {
                keywords.add(KEYWORD_LINE_NAMES.get(lineType));
            } else if (!LINE_NAMES.containsKey(lineType) && !ALWAYS_ALLOWED.contains(lineType)) {
                names.add(lineType.replace("#", ""));
            }
        }
        if (!keywords.isEmpty()) {
            String article = "AEIOU".indexOf(keywords.get(0).charAt(0)) >= 0 ? "an " : "a ";
            names.add(article + joinWithOr(keywords, false) + " line");
        }
        if (names.isEmpty()) {
            // only blank lines, comments or the end of the spec are allowed there
            names.add("the end of the spec");
        }

        return joinWithOr(names, true);
    }

    /**
     * Joins words with commas and a final "or": {@code a or b}, and {@code a, b, or c} with a comma before the "or"
     * when asked for.
     */
    private static String joinWithOr(List<String> words, boolean commaBeforeOr) {
        if (words.size() == 1) {
            return words.get(0);
        }
        String allButLast = String.join(", ", words.subList(0, words.size() - 1));
        String separator = commaBeforeOr && words.size() > 2 ? ", or " : " or ";
        return allButLast + separator + words.get(words.size() - 1);
    }
}
