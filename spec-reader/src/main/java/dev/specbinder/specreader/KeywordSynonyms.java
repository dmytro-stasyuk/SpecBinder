package dev.specbinder.specreader;

import dev.specbinder.annotations.GherkinKeyword;

import java.util.*;

/**
 * The keyword synonyms a spec is read with: at most one entry per keyword, merged keyword by keyword from the
 * {@code keywordSynonyms} of the classes that declare them.
 */
public final class KeywordSynonyms {

    /**
     * A team's own words for one keyword.
     *
     * @param keyword  the keyword the synonyms stand for
     * @param synonyms the words a spec may use for the keyword
     * @param replace  whether the synonyms are the only words for the keyword
     */
    public record Entry(GherkinKeyword keyword, List<String> synonyms, boolean replace) {

        /**
         * Creates an entry, keeping its own copy of the synonyms, so a later change to the list passed in does not
         * reach it.
         *
         * @param keyword  the keyword the synonyms stand for
         * @param synonyms the words a spec may use for the keyword
         * @param replace  whether the synonyms are the only words for the keyword
         */
        public Entry {
            synonyms = List.copyOf(synonyms);
        }
    }

    /**
     * No synonyms: every keyword keeps the words of the languages a spec is read with.
     */
    public static final KeywordSynonyms NONE = new KeywordSynonyms(new EnumMap<>(GherkinKeyword.class));

    private final Map<GherkinKeyword, Entry> entries;

    private KeywordSynonyms(Map<GherkinKeyword, Entry> entries) {
        this.entries = Collections.unmodifiableMap(entries);
    }

    /**
     * Merges the entries the classes of a hierarchy declare, keyword by keyword: an entry for a keyword replaces the
     * entry for the same keyword of a class further up, and the other entries of that class still apply.
     *
     * @param declaredBaseFirst the entries each class declares, the class furthest up first
     * @return the merged synonyms
     * @throws IllegalArgumentException if a class declares two entries for one keyword
     */
    public static KeywordSynonyms merge(List<List<Entry>> declaredBaseFirst) {
        Map<GherkinKeyword, Entry> merged = new EnumMap<>(GherkinKeyword.class);
        for (List<Entry> declared : declaredBaseFirst) {
            Set<GherkinKeyword> declaredKeywords = EnumSet.noneOf(GherkinKeyword.class);
            for (Entry entry : declared) {
                if (!declaredKeywords.add(entry.keyword())) {
                    throw new IllegalArgumentException("keywordSynonyms has two entries for " + entry.keyword());
                }
                merged.put(entry.keyword(), entry);
            }
        }
        return new KeywordSynonyms(merged);
    }

    /**
     * Returns the entries, one per keyword at most, in the order the keywords are declared in {@link GherkinKeyword}.
     *
     * @return the entries
     */
    public List<Entry> entries() {
        return List.copyOf(entries.values());
    }

    /**
     * Tells whether there are no synonyms.
     *
     * @return true if no keyword has an entry
     */
    public boolean isEmpty() {
        return entries.isEmpty();
    }

    /**
     * Returns the entry for one kind of keyword.
     *
     * @param kind the kind of keyword
     * @return the entry, or empty if the keyword has no synonyms
     */
    Optional<Entry> entryFor(KeywordKind kind) {
        return Optional.ofNullable(entries.get(GherkinKeyword.valueOf(kind.name())));
    }
}
