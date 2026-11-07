package dev.specbinder.examples.goingfurther.localization.synonyms;

import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.annotations.Gherkin2JUnitOptions;
import dev.specbinder.annotations.GherkinKeyword;
import dev.specbinder.annotations.KeywordSynonym;
import dev.specbinder.examples.goingfurther.localization.Kasse;

/**
 * Marker class adding a team's own words to the German keywords it inherits from {@link Kasse}; the step methods live
 * in KasseMitSynonymenTest.
 * <p>
 * Only {@code keywordSynonyms} is set here, so {@code keywordLanguages = GERMAN} still comes from Kasse. The two
 * entries show both ways a synonym can work:
 * <ul>
 *     <li>{@code Vorausgesetzt} is added next to the usual German Given words, so {@code Angenommen} and
 *     {@code Gegeben sei} would still work.</li>
 *     <li>{@code replace = true} makes {@code Geschäftsregel} the only Rule word, so {@code Regel:} no longer starts
 *     a Rule in this marker's specs.</li>
 * </ul>
 * <p>
 * No path in @Gherkin2JUnit — the processor discovers the co-located KasseMitSynonymen.specb in this package by
 * convention.
 */
@Gherkin2JUnit
@Gherkin2JUnitOptions(keywordSynonyms = {
        @KeywordSynonym(keyword = GherkinKeyword.RULE, synonyms = "Geschäftsregel", replace = true),
        @KeywordSynonym(keyword = GherkinKeyword.GIVEN, synonyms = "Vorausgesetzt")
})
public abstract class KasseMitSynonymen extends Kasse {
}
