package dev.specbinder.processor.gherkin;

import dev.specbinder.specreader.LanguageHeader;

import java.util.ArrayList;
import java.util.List;

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

    private SpecFileSplitter() {
    }

    /**
     * Returns one document per spec, or a single-element list holding the unchanged content when the file holds
     * at most one spec.
     *
     * @param content         the content of the spec file
     * @param featureKeywords the Feature keywords the spec file is read with, a team's synonyms included
     */
    static List<String> split(String content, List<String> featureKeywords) {

        String[] lines = content.split("\n", -1);

        int languageLine = LanguageHeader.findLine(lines);

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
