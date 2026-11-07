package dev.specbinder.specreader;

import dev.specbinder.annotations.GherkinKeyword;
import dev.specbinder.annotations.KeywordLanguage;
import dev.specbinder.specreader.KeywordSynonyms.Entry;
import io.cucumber.gherkin.GherkinDialect;
import io.cucumber.gherkin.GherkinDialectProvider;

import java.util.*;

/**
 * The keywords a spec is read with: those of the language of its {@code # language:} header, which then is the only
 * one, or else those of the languages its generator options list, which the spec may mix freely; with the team's own
 * synonyms for keywords on top, added to a keyword's words or replacing them.
 */
public final class SpecKeywords {

    private final List<KeywordLanguage> languages;
    private final String headerLanguage;
    private final Map<KeywordKind, List<String>> keywords;
    private final KeywordSynonyms synonyms;

    private SpecKeywords(List<KeywordLanguage> languages, String headerLanguage,
                         Map<KeywordKind, List<String>> keywords, KeywordSynonyms synonyms) {
        this.languages = languages;
        this.headerLanguage = headerLanguage;
        this.keywords = keywords;
        this.synonyms = synonyms;
    }

    /**
     * Checks that specs can be read with the keywords of the given languages and synonyms: there must be at least one
     * language, no two languages may share a keyword that means something different in each, such as {@code Dan},
     * which means Then in Dutch and And in Indonesian, unless a synonym settles what it means, and every synonym
     * entry must be usable.
     *
     * @param keywordLanguages the languages a spec without a header may use the keywords of
     * @param synonyms         the team's own words for keywords
     * @throws IllegalArgumentException if the languages and synonyms can't be used together
     */
    public static void validate(KeywordLanguage[] keywordLanguages, KeywordSynonyms synonyms) {
        if (keywordLanguages == null || keywordLanguages.length == 0) {
            throw new IllegalArgumentException("keywordLanguages must not be empty");
        }
        validateEntries(synonyms);

        // a synonym takes its word over, so a word that is a synonym, or a word of a replaced keyword, can't clash
        Set<String> titleSynonyms = new HashSet<>();
        Set<String> stepSynonyms = new HashSet<>();
        for (KeywordKind kind : KeywordKind.values()) {
            synonyms.entryFor(kind).ifPresent(entry ->
                    (kind.isTitleKeyword() ? titleSynonyms : stepSynonyms).addAll(entry.synonyms()));
        }

        record Meaning(KeywordLanguage language, KeywordKind kind) {
        }
        // title keywords and step keywords are told apart by the colon after a title keyword, so they never clash
        Map<String, Meaning> titleMeanings = new HashMap<>();
        Map<String, Meaning> stepMeanings = new HashMap<>();

        List<GherkinDialect> dialects = new ArrayList<>();
        for (KeywordLanguage language : distinct(keywordLanguages)) {
            GherkinDialect dialect = dialectOf(language);
            dialects.add(dialect);
            for (KeywordKind kind : KeywordKind.values()) {
                if (synonyms.entryFor(kind).map(Entry::replace).orElse(false)) {
                    continue;
                }
                Map<String, Meaning> meanings = kind.isTitleKeyword() ? titleMeanings : stepMeanings;
                Set<String> settledWords = kind.isTitleKeyword() ? titleSynonyms : stepSynonyms;
                for (String keyword : kind.keywordsOf(dialect)) {
                    String word = keyword.strip();
                    if (settledWords.contains(word)) {
                        continue;
                    }
                    Meaning earlier = meanings.putIfAbsent(word, new Meaning(language, kind));
                    if (earlier != null && earlier.kind() != kind) {
                        throw new IllegalArgumentException("keywordLanguages can't combine " + earlier.language()
                                + " and " + language + ": '" + word + "' means " + earlier.kind().displayName()
                                + " in " + earlier.language() + " and " + kind.displayName() + " in " + language);
                    }
                }
            }
        }

        keywordsOf(dialects, synonyms);
    }

    /**
     * Returns the keywords a spec is read with.
     *
     * @param content          the content of the spec file
     * @param keywordLanguages the languages a spec without a header may use the keywords of
     * @param synonyms         the team's own words for keywords
     * @return the keywords the spec is read with
     * @throws IllegalArgumentException if the spec's header names a language that Gherkin doesn't have, or the
     *                                  synonyms take over the last word a keyword has in the header's language
     */
    public static SpecKeywords of(String content, KeywordLanguage[] keywordLanguages, KeywordSynonyms synonyms) {

        String[] lines = content.split("\r?\n", -1);
        Optional<String> headerLanguage = LanguageHeader.languageOf(lines);
        if (headerLanguage.isPresent()) {
            String code = headerLanguage.get();
            GherkinDialect dialect = dialectProvider().getDialect(code).orElseThrow(() -> new IllegalArgumentException(
                    "Unknown language '" + code + "' in the '# language:' header on line - "
                            + (LanguageHeader.findLine(lines) + 1)));
            List<KeywordLanguage> languages = Arrays.stream(KeywordLanguage.values())
                    .filter(language -> language.code().equals(code))
                    .toList();
            return new SpecKeywords(languages, code, keywordsOf(List.of(dialect), synonyms), synonyms);
        }

        List<KeywordLanguage> languages = distinct(keywordLanguages);
        List<GherkinDialect> dialects = languages.stream().map(SpecKeywords::dialectOf).toList();
        return new SpecKeywords(languages, null, keywordsOf(dialects, synonyms), synonyms);
    }

    /**
     * Returns the keywords a spec is read with when nothing picks others: the English ones alone.
     *
     * @return the English keywords
     */
    public static SpecKeywords english() {
        List<GherkinDialect> english = List.of(dialectOf(KeywordLanguage.ENGLISH));
        return new SpecKeywords(List.of(KeywordLanguage.ENGLISH), null, keywordsOf(english, KeywordSynonyms.NONE),
                KeywordSynonyms.NONE);
    }

    /**
     * Returns the languages the spec is read with, in the order they are listed.
     *
     * @return the languages the spec is read with
     */
    public List<KeywordLanguage> languages() {
        return languages;
    }

    /**
     * Tells whether the spec is read with English keywords only.
     *
     * @return true if English is the only language the spec is read with
     */
    public boolean isEnglishOnly() {
        return languages.equals(List.of(KeywordLanguage.ENGLISH));
    }

    /**
     * Returns the words a spec of several Features may start each one with, e.g. {@code Feature},
     * {@code Funktionalität} or a team's {@code Story}.
     *
     * @return the Feature keywords
     */
    public List<String> featureKeywords() {
        return keywords.get(KeywordKind.FEATURE);
    }

    /**
     * Returns the words a line may start with for a keyword, longest first: those of the spec's languages and the
     * team's synonyms, less the words another keyword's synonyms take over. A title keyword's word is given without
     * the colon that follows it, e.g. {@code Funktionalität} or a team's {@code Story}; a step keyword's word with
     * the space that follows it, e.g. {@code Angenommen }, unless it ends in an apostrophe, e.g. {@code Lorsqu'}.
     * The {@code *} step keyword, which reads the same in every language, is not among them.
     *
     * @param keyword the keyword
     * @return the words of the keyword
     */
    public List<String> wordsOf(GherkinKeyword keyword) {
        return keywords.get(KeywordKind.valueOf(keyword.name())).stream()
                .filter(word -> !word.equals("* "))
                .sorted(Comparator.comparingInt(String::length).reversed())
                .toList();
    }

    /**
     * Returns the team's synonyms for a keyword that the spec can use, in the order its entry lists them, written as
     * {@link #wordsOf(GherkinKeyword)} writes words. A synonym another keyword's synonym took over is left out.
     *
     * @param keyword the keyword
     * @return the synonyms of the keyword
     */
    public List<String> synonymsOf(GherkinKeyword keyword) {
        KeywordKind kind = KeywordKind.valueOf(keyword.name());
        return synonyms.entryFor(kind).map(Entry::synonyms).orElse(List.of()).stream()
                .map(kind::asKeyword)
                .filter(keywords.get(kind)::contains)
                .toList();
    }

    /**
     * Returns the words a language gives a keyword that the spec can use, in the order the language lists them,
     * written as {@link #wordsOf(GherkinKeyword)} writes words: none for a language the spec isn't read with, nor for
     * a keyword whose synonyms replace its words; a word another keyword's synonym took over is left out.
     *
     * @param keyword  the keyword
     * @param language one of the languages the spec is read with
     * @return the words the language gives the keyword
     */
    public List<String> wordsOf(GherkinKeyword keyword, KeywordLanguage language) {
        if (!languages.contains(language)) {
            return List.of();
        }
        KeywordKind kind = KeywordKind.valueOf(keyword.name());
        return kind.keywordsOf(dialectOf(language)).stream()
                .filter(word -> !word.equals("* "))
                .map(word -> kind.isTitleKeyword() ? word.strip() : word)
                .filter(keywords.get(kind)::contains)
                .distinct()
                .toList();
    }

    /**
     * Returns the step keywords, as the parser matches them, e.g. {@code Given }, {@code Angenommen } or a team's
     * {@code Assuming }, and {@code * }.
     *
     * @return the step keywords
     */
    public List<String> stepKeywords() {
        List<String> stepKeywords = new ArrayList<>();
        for (KeywordKind kind : KeywordKind.values()) {
            if (!kind.isTitleKeyword()) {
                stepKeywords.addAll(keywords.get(kind));
            }
        }
        stepKeywords.add("* ");
        return stepKeywords.stream().distinct().toList();
    }

    /**
     * Whether the parser can read the spec as written: it uses no synonyms, and it has a header or is in English only.
     */
    boolean isReadAsWritten() {
        return synonyms.isEmpty() && (headerLanguage != null || isEnglishOnly());
    }

    KeywordTranslator translator() {
        return new KeywordTranslator(keywords, dialectOf(KeywordLanguage.ENGLISH), headerLanguage);
    }

    /**
     * The words of each keyword: those of the given languages, or, for a keyword whose synonyms replace them, none,
     * plus its synonyms; less the words other keywords' synonyms take over.
     */
    private static Map<KeywordKind, List<String>> keywordsOf(List<GherkinDialect> dialects, KeywordSynonyms synonyms) {

        Map<KeywordKind, LinkedHashSet<String>> words = new EnumMap<>(KeywordKind.class);
        for (KeywordKind kind : KeywordKind.values()) {
            LinkedHashSet<String> kindWords = new LinkedHashSet<>();
            Optional<Entry> entry = synonyms.entryFor(kind);
            if (entry.isEmpty() || !entry.get().replace()) {
                for (GherkinDialect dialect : dialects) {
                    for (String keyword : kind.keywordsOf(dialect)) {
                        kindWords.add(kind.isTitleKeyword() ? keyword.strip() : keyword);
                    }
                }
            }
            entry.ifPresent(e -> e.synonyms().forEach(synonym -> kindWords.add(kind.asKeyword(synonym))));
            words.put(kind, kindWords);
        }

        record Takeover(String word, KeywordKind by) {
        }
        Map<KeywordKind, Takeover> takeovers = new EnumMap<>(KeywordKind.class);
        for (KeywordKind kind : KeywordKind.values()) {
            for (String synonym : synonyms.entryFor(kind).map(Entry::synonyms).orElse(List.of())) {
                for (KeywordKind other : KeywordKind.values()) {
                    if (other != kind && other.isTitleKeyword() == kind.isTitleKeyword()
                            && words.get(other).removeIf(word -> word.strip().equals(synonym))) {
                        takeovers.putIfAbsent(other, new Takeover(synonym, kind));
                    }
                }
            }
        }

        Map<KeywordKind, List<String>> keywords = new EnumMap<>(KeywordKind.class);
        for (KeywordKind kind : KeywordKind.values()) {
            if (words.get(kind).isEmpty()) {
                Takeover takeover = takeovers.get(kind);
                if (takeover == null) {
                    throw new IllegalArgumentException("keywordSynonyms for " + kind + " lists no synonyms");
                }
                throw new IllegalArgumentException("keywordSynonyms leaves " + kind + " with no words: '"
                        + takeover.word() + "' is a synonym for " + takeover.by());
            }
            keywords.put(kind, List.copyOf(words.get(kind)));
        }
        return keywords;
    }

    private static void validateEntries(KeywordSynonyms synonyms) {
        Map<String, Entry> entryOfSynonym = new HashMap<>();
        for (Entry entry : synonyms.entries()) {
            if (entry.synonyms().isEmpty()) {
                throw new IllegalArgumentException("keywordSynonyms for " + entry.keyword() + " lists no synonyms");
            }
            for (String synonym : entry.synonyms()) {
                String described = "keywordSynonyms for " + entry.keyword() + " has the synonym '" + synonym + "'";
                if (synonym.isBlank()) {
                    throw new IllegalArgumentException(
                            "keywordSynonyms for " + entry.keyword() + " has a blank synonym");
                }
                if (!synonym.equals(synonym.strip())) {
                    throw new IllegalArgumentException(described + ", which starts or ends with a space");
                }
                if (synonym.contains(":")) {
                    throw new IllegalArgumentException(described + ", which contains ':' - write it without the ':'");
                }
                Entry earlier = entryOfSynonym.putIfAbsent(synonym, entry);
                if (earlier != null && earlier.keyword() != entry.keyword()) {
                    throw new IllegalArgumentException("keywordSynonyms lists '" + synonym + "' for both "
                            + earlier.keyword() + " and " + entry.keyword());
                }
            }
        }
    }

    private static List<KeywordLanguage> distinct(KeywordLanguage[] keywordLanguages) {
        return List.copyOf(new LinkedHashSet<>(Arrays.asList(keywordLanguages)));
    }

    private static GherkinDialect dialectOf(KeywordLanguage language) {
        return dialectProvider().getDialect(language.code()).orElseThrow(() -> new IllegalArgumentException(
                "keywordLanguages lists " + language + ", a language the Gherkin parser in use doesn't know ('"
                        + language.code() + "')"));
    }

    // GherkinDialectProvider is deprecated in newer Gherkin versions in favour of GherkinDialects, which is not
    // public in older ones; the provider works with both.
    @SuppressWarnings("deprecation")
    private static GherkinDialectProvider dialectProvider() {
        return new GherkinDialectProvider();
    }
}
