package dev.specbinder.specreader;

import java.util.Map;
import java.util.Set;

/**
 * A spec rewritten so the Gherkin parser can read it: its keywords by {@link KeywordTranslator}, and the first rows
 * of its vertical tables by {@link VerticalTables}.
 *
 * @param originalLines      the lines of the spec as written
 * @param translatedLines    the lines of the spec as the parser reads them
 * @param originalKeywords   the keyword each rewritten line started with, as the spec spells it, by line index
 * @param headerLanguage     the language code of the spec's {@code # language:} header, or null when it has none
 * @param verticalTableLines the indexes of the lines that open a vertical table
 */
record Translation(String[] originalLines, String[] translatedLines, Map<Integer, String> originalKeywords,
                   String headerLanguage, Set<Integer> verticalTableLines) {

    /**
     * A spec the parser reads as written.
     */
    static Translation unchanged(String content) {
        String[] lines = content.split("\r?\n", -1);
        return new Translation(lines, lines.clone(), Map.of(), null, Set.of());
    }

    String content() {
        return String.join("\n", translatedLines);
    }

    boolean isChanged(int lineIndex) {
        return lineIndex >= 0 && lineIndex < originalLines.length
                && !originalLines[lineIndex].equals(translatedLines[lineIndex]);
    }

    boolean isAnyLineChanged() {
        for (int i = 0; i < originalLines.length; i++) {
            if (isChanged(i)) {
                return true;
            }
        }
        return false;
    }
}
