package dev.specbinder.reporter.internal;

import dev.specbinder.annotations.Gherkin2JUnitOptions;
import dev.specbinder.annotations.KeywordLanguage;
import dev.specbinder.annotations.KeywordSynonym;
import dev.specbinder.annotations.StripBetween;
import dev.specbinder.annotations.output.SourceFilePath;
import dev.specbinder.specreader.KeywordSynonyms;
import dev.specbinder.specreader.StripBetweenPattern;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * The generator options that decide how the spec behind a SpecBinder-generated test class is read: the
 * languages whose keywords a spec without a {@code # language:} header may use, a team's own synonyms for
 * keywords, and the text stripped from the spec before it is parsed.
 *
 * <p>They are read from the {@link Gherkin2JUnitOptions} declared on the generated class's superclasses —
 * the {@code @Gherkin2JUnit} marker class and the classes it extends — and merged the way the annotation
 * processor merges them: an option a subclass sets replaces the one its base class sets, and
 * {@code keywordSynonyms} are merged keyword by keyword. Options declared on a class extending the generated
 * class are left out, since the processor never saw them.
 *
 * <p>The processor tells an option a class sets from one it leaves out; at runtime only the values are left,
 * so an option is taken as set when its value differs from the default. An override back to the default, such
 * as {@code stripPatterns = {}} under a base class that strips markers, therefore keeps the base class's value.
 * The spec is then read differently from how it was generated, and the scenario-hash gate leaves the affected
 * scenarios without step text rather than pairing the wrong lines with the steps that ran.
 *
 * @param keywordLanguages     the languages whose keywords a spec without a {@code # language:} header may use
 * @param keywordSynonyms      a team's own words for keywords
 * @param stripPatterns        regexes whose every match is stripped from the spec before it is parsed
 * @param stripBetweenPatterns the two ends of each span stripped from the spec before it is parsed
 */
public record SpecReadingOptions(
        KeywordLanguage[] keywordLanguages,
        KeywordSynonyms keywordSynonyms,
        String[] stripPatterns,
        StripBetweenPattern[] stripBetweenPatterns) {

    private static final KeywordLanguage[] DEFAULT_KEYWORD_LANGUAGES = {KeywordLanguage.ENGLISH};

    /** The options of a spec configured with none: English keywords only, nothing stripped. */
    public static final SpecReadingOptions DEFAULTS =
            new SpecReadingOptions(DEFAULT_KEYWORD_LANGUAGES, KeywordSynonyms.NONE, new String[0],
                    new StripBetweenPattern[0]);

    /**
     * Returns the options the spec behind a test class was generated with. The generated class is the first
     * class carrying {@link SourceFilePath} up the {@code @Nested} enclosing-class and superclass chain of
     * {@code testClass}; without one, the defaults apply.
     */
    public static SpecReadingOptions of(Class<?> testClass) {
        Class<?> generatedClass = generatedClassOf(testClass);
        if (generatedClass == null) {
            return DEFAULTS;
        }

        List<Gherkin2JUnitOptions> declaredOptions = new ArrayList<>();
        for (Class<?> cls = generatedClass; cls != null && cls != Object.class; cls = cls.getSuperclass()) {
            Gherkin2JUnitOptions options = cls.getDeclaredAnnotation(Gherkin2JUnitOptions.class);
            if (options != null) {
                declaredOptions.add(options);
            }
        }

        KeywordLanguage[] keywordLanguages = DEFAULTS.keywordLanguages();
        List<List<KeywordSynonyms.Entry>> declaredKeywordSynonyms = new ArrayList<>();
        String[] stripPatterns = DEFAULTS.stripPatterns();
        StripBetweenPattern[] stripBetweenPatterns = DEFAULTS.stripBetweenPatterns();

        // Base class first, so that what a subclass sets replaces what its base class sets
        for (int i = declaredOptions.size() - 1; i >= 0; i--) {
            Gherkin2JUnitOptions options = declaredOptions.get(i);
            if (!Arrays.equals(options.keywordLanguages(), DEFAULT_KEYWORD_LANGUAGES)) {
                keywordLanguages = options.keywordLanguages();
            }
            declaredKeywordSynonyms.add(toKeywordSynonymEntries(options.keywordSynonyms()));
            if (options.stripPatterns().length > 0) {
                stripPatterns = options.stripPatterns();
            }
            if (options.stripBetweenPatterns().length > 0) {
                stripBetweenPatterns = toStripBetweenPatterns(options.stripBetweenPatterns());
            }
        }
        return new SpecReadingOptions(
                keywordLanguages, keywordSynonymsOf(declaredKeywordSynonyms), stripPatterns, stripBetweenPatterns);
    }

    /**
     * Merges the declared synonyms keyword by keyword. Two entries for one keyword on a class fail the build, so they
     * never reach a test run; should they still, the spec is read without synonyms.
     */
    private static KeywordSynonyms keywordSynonymsOf(List<List<KeywordSynonyms.Entry>> declaredBaseFirst) {
        try {
            return KeywordSynonyms.merge(declaredBaseFirst);
        } catch (IllegalArgumentException e) {
            return KeywordSynonyms.NONE;
        }
    }

    private static List<KeywordSynonyms.Entry> toKeywordSynonymEntries(KeywordSynonym[] synonymAnnotations) {
        List<KeywordSynonyms.Entry> entries = new ArrayList<>(synonymAnnotations.length);
        for (KeywordSynonym synonym : synonymAnnotations) {
            entries.add(new KeywordSynonyms.Entry(synonym.keyword(), List.of(synonym.synonyms()), synonym.replace()));
        }
        return entries;
    }

    private static Class<?> generatedClassOf(Class<?> testClass) {
        Class<?> cls = testClass;
        while (cls != null) {
            if (cls.getAnnotation(SourceFilePath.class) != null) {
                return cls;
            }
            Class<?> next = cls.getEnclosingClass();
            if (next == null) {
                next = cls.getSuperclass();
            }
            cls = next;
        }
        return null;
    }

    private static StripBetweenPattern[] toStripBetweenPatterns(StripBetween[] betweenAnnotations) {
        StripBetweenPattern[] pairs = new StripBetweenPattern[betweenAnnotations.length];
        for (int i = 0; i < betweenAnnotations.length; i++) {
            pairs[i] = new StripBetweenPattern(betweenAnnotations[i].start(), betweenAnnotations[i].end());
        }
        return pairs;
    }
}
