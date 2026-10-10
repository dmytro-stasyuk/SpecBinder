package dev.specbinder.processor.gherkin;

import io.cucumber.gherkin.GherkinDialectProvider;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Splits the content of a spec file holding several top-level Feature keywords (or their synonyms, in the file's
 * language) into one Gherkin document per spec, since a Gherkin document may only hold a single Feature.
 * <p>
 * Each returned document keeps the full line count of the original file: lines that belong to other specs are
 * blanked rather than removed, so line numbers reported by the parser still point into the original file. The
 * {@code # language:} header is kept in every document. Keyword lines inside doc strings do not start a new spec,
 * and the tag and comment lines directly above a keyword line belong to the spec that keyword starts.
 */
final class SpecFileSplitter {

    private static final Pattern LANGUAGE_PATTERN = Pattern.compile("^\\s*#\\s*language\\s*:\\s*([a-zA-Z\\-_]+)\\s*$");
    private static final String DEFAULT_LANGUAGE = "en";

    private SpecFileSplitter() {
    }

    /**
     * Returns one document per spec, or a single-element list holding the unchanged content when the file holds
     * at most one spec.
     */
    static List<String> split(String content) {

        String[] lines = content.split("\n", -1);

        int languageLine = findLanguageLine(lines);
        List<String> featureKeywords = featureKeywords(languageLine < 0 ? DEFAULT_LANGUAGE
                : languageOf(lines[languageLine]));

        List<Integer> keywordLines = findFeatureKeywordLines(lines, featureKeywords);
        if (keywordLines.size() < 2) {
            return List.of(content);
        }

        List<Integer> specStarts = new ArrayList<>();
        specStarts.add(0);
        for (int i = 1; i < keywordLines.size(); i++) {
            specStarts.add(startOfSpec(lines, keywordLines.get(i), keywordLines.get(i - 1)));
        }

        List<String> documents = new ArrayList<>();
        for (int i = 0; i < specStarts.size(); i++) {
            int start = specStarts.get(i);
            int end = i + 1 < specStarts.size() ? specStarts.get(i + 1) : lines.length;
            documents.add(documentOf(lines, start, end, languageLine));
        }
        return documents;
    }

    private static int findLanguageLine(String[] lines) {
        for (int i = 0; i < lines.length; i++) {
            String trimmed = lines[i].strip();
            if (trimmed.isEmpty()) {
                continue;
            }
            if (!trimmed.startsWith("#")) {
                return -1;
            }
            if (LANGUAGE_PATTERN.matcher(lines[i]).matches()) {
                return i;
            }
        }
        return -1;
    }

    private static String languageOf(String line) {
        Matcher matcher = LANGUAGE_PATTERN.matcher(line);
        return matcher.matches() ? matcher.group(1) : DEFAULT_LANGUAGE;
    }

    // GherkinDialectProvider is deprecated in newer Gherkin versions in favour of GherkinDialects, which is not
    // public in older ones; the provider works with both.
    @SuppressWarnings("deprecation")
    private static List<String> featureKeywords(String language) {
        GherkinDialectProvider dialectProvider = new GherkinDialectProvider(DEFAULT_LANGUAGE);
        return dialectProvider.getDialect(language)
                .orElseGet(dialectProvider::getDefaultDialect)
                .getFeatureKeywords();
    }

    private static List<Integer> findFeatureKeywordLines(String[] lines, List<String> featureKeywords) {
        List<Integer> keywordLines = new ArrayList<>();
        String openDocStringDelimiter = null;
        for (int i = 0; i < lines.length; i++) {
            String trimmed = lines[i].strip();
            if (openDocStringDelimiter != null) {
                if (trimmed.startsWith(openDocStringDelimiter)) {
                    openDocStringDelimiter = null;
                }
                continue;
            }
            if (trimmed.startsWith("\"\"\"")) {
                openDocStringDelimiter = "\"\"\"";
            } else if (trimmed.startsWith("```")) {
                openDocStringDelimiter = "```";
            } else if (isFeatureKeywordLine(trimmed, featureKeywords)) {
                keywordLines.add(i);
            }
        }
        return keywordLines;
    }

    private static boolean isFeatureKeywordLine(String trimmedLine, List<String> featureKeywords) {
        for (String keyword : featureKeywords) {
            if (trimmedLine.startsWith(keyword + ":")) {
                return true;
            }
        }
        return false;
    }

    /**
     * A spec starts at the first of the tag and comment lines directly above its keyword line.
     */
    private static int startOfSpec(String[] lines, int keywordLine, int previousKeywordLine) {
        int start = keywordLine;
        while (start - 1 > previousKeywordLine) {
            String trimmed = lines[start - 1].strip();
            if (trimmed.startsWith("@") || trimmed.startsWith("#")) {
                start--;
            } else {
                break;
            }
        }
        return start;
    }

    private static String documentOf(String[] lines, int start, int end, int languageLine) {
        StringBuilder document = new StringBuilder();
        for (int i = 0; i < lines.length; i++) {
            if (i > 0) {
                document.append('\n');
            }
            if ((i >= start && i < end) || i == languageLine) {
                document.append(lines[i]);
            }
        }
        return document.toString();
    }
}
