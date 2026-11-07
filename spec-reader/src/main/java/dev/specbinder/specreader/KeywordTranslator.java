package dev.specbinder.specreader;

import io.cucumber.gherkin.GherkinDialect;

import java.util.*;

/**
 * Rewrites a spec whose keywords come from several languages, or include a team's synonyms, into one the Gherkin
 * parser can read: every line starting with one of the spec's keywords gets the English keyword of the same kind
 * instead, e.g. {@code Angenommen ein Warenkorb} or {@code Assuming ein Warenkorb} becomes {@code Given ein Warenkorb}.
 * A line starting with an English keyword that isn't one of the spec's keywords is masked so the parser doesn't read
 * it as one, and a {@code # language:} header is blanked so the parser reads the English keywords. Lines inside doc
 * strings are left as they are.
 * <p>
 * The parser decides from where a line stands whether it is a keyword line or text, just as it does for a spec of
 * one language, so a rewritten line may still end up as description text; {@link FeatureRestorer} puts back the
 * original keywords and text after parsing.
 */
final class KeywordTranslator {

    /**
     * Put in front of a line to keep the parser from reading the keyword it starts with: a zero-width space, which
     * is not whitespace and so not trimmed away.
     */
    private static final char MASK = '​';

    /**
     * A keyword a line may start with, of a kind, or of no kind for {@code *}.
     */
    private record Keyword(String text, KeywordKind kind) {

        /**
         * How much of a line the keyword takes: a title keyword is followed by a colon.
         */
        int matchLength() {
            return text.length() + (kind != null && kind.isTitleKeyword() ? 1 : 0);
        }

        boolean startsLine(String trimmedLine) {
            if (kind != null && kind.isTitleKeyword()) {
                return trimmedLine.startsWith(text + ":");
            }
            return trimmedLine.startsWith(text);
        }
    }

    /**
     * The result of rewriting a spec.
     *
     * @param originalLines    the lines of the spec as written
     * @param translatedLines  the lines of the spec as the parser reads them
     * @param originalKeywords the keyword each rewritten line started with, as the spec spells it, by line index
     * @param headerLanguage   the language code of the spec's {@code # language:} header, or null when it has none
     */
    record Translation(String[] originalLines, String[] translatedLines, Map<Integer, String> originalKeywords,
                       String headerLanguage) {

        String content() {
            return String.join("\n", translatedLines);
        }

        boolean isChanged(int lineIndex) {
            return lineIndex >= 0 && lineIndex < originalLines.length
                    && !originalLines[lineIndex].equals(translatedLines[lineIndex]);
        }
    }

    private final List<Keyword> keywords;
    private final List<Keyword> maskedKeywords;
    private final String headerLanguage;

    /**
     * @param keywords       the spec's keywords of each kind, as a line starts with them
     * @param english        the English keywords, which the parser reads
     * @param headerLanguage the language code of the spec's {@code # language:} header, or null when it has none
     */
    KeywordTranslator(Map<KeywordKind, List<String>> keywords, GherkinDialect english, String headerLanguage) {
        this.keywords = longestFirst(keywords);
        // a line starting with one of the spec's keywords is rewritten before masking is considered, so only the
        // English keywords that aren't the spec's own end up masked
        Map<KeywordKind, List<String>> englishKeywords = new EnumMap<>(KeywordKind.class);
        for (KeywordKind kind : KeywordKind.values()) {
            englishKeywords.put(kind, kind.keywordsOf(english).stream()
                    .map(keyword -> kind.isTitleKeyword() ? keyword.strip() : keyword)
                    .toList());
        }
        this.maskedKeywords = longestFirst(englishKeywords);
        this.headerLanguage = headerLanguage;
    }

    private static List<Keyword> longestFirst(Map<KeywordKind, List<String>> keywordsByKind) {
        Set<Keyword> keywords = new LinkedHashSet<>();
        keywordsByKind.forEach((kind, kindKeywords) ->
                kindKeywords.forEach(keyword -> keywords.add(new Keyword(keyword, kind))));
        keywords.add(new Keyword("* ", null));

        // the longest keyword a line starts with wins, as it does in the parser
        List<Keyword> longestFirst = new ArrayList<>(keywords);
        longestFirst.sort(Comparator.comparingInt(Keyword::matchLength).reversed());
        return longestFirst;
    }

    Translation translate(String content) {

        String[] originalLines = content.split("\r?\n", -1);
        String[] translatedLines = originalLines.clone();
        Map<Integer, String> originalKeywords = new HashMap<>();

        if (headerLanguage != null) {
            int headerLine = LanguageHeader.findLine(originalLines);
            String header = originalLines[headerLine];
            translatedLines[headerLine] = header.substring(0, header.length() - header.stripLeading().length()) + "#";
        }

        String openDocStringDelimiter = null;
        for (int i = 0; i < originalLines.length; i++) {
            String line = originalLines[i];
            String trimmed = line.stripLeading();

            if (openDocStringDelimiter != null) {
                if (trimmed.startsWith(openDocStringDelimiter)) {
                    openDocStringDelimiter = null;
                }
                continue;
            }
            if (trimmed.startsWith("\"\"\"")) {
                openDocStringDelimiter = "\"\"\"";
                continue;
            }
            if (trimmed.startsWith("```")) {
                openDocStringDelimiter = "```";
                continue;
            }

            String indent = line.substring(0, line.length() - trimmed.length());
            Optional<Keyword> keyword = firstStartingLine(keywords, trimmed);
            if (keyword.isPresent()) {
                KeywordKind kind = keyword.get().kind();
                if (kind != null) {
                    translatedLines[i] = indent + kind.englishKeyword() + trimmed.substring(keyword.get().text().length());
                    originalKeywords.put(i, keyword.get().text());
                }
            } else if (firstStartingLine(maskedKeywords, trimmed).isPresent()) {
                translatedLines[i] = indent + MASK + trimmed;
            }
        }

        return new Translation(originalLines, translatedLines, originalKeywords, headerLanguage);
    }

    private static Optional<Keyword> firstStartingLine(List<Keyword> keywords, String trimmedLine) {
        for (Keyword keyword : keywords) {
            if (keyword.startsLine(trimmedLine)) {
                return Optional.of(keyword);
            }
        }
        return Optional.empty();
    }
}
