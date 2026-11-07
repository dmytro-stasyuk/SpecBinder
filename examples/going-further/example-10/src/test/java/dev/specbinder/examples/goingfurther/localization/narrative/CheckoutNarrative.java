package dev.specbinder.examples.goingfurther.localization.narrative;

import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.annotations.Gherkin2JUnitOptions;
import dev.specbinder.annotations.GherkinKeyword;
import dev.specbinder.annotations.KeywordSynonym;

/**
 * Marker class adding {@code Narrative} as a Feature keyword next to English {@code Feature}; the step methods live
 * in CheckoutNarrativeTest.
 * <p>
 * The spec keeps the default English keywords and opens with a user story under a {@code Narrative:} heading. The
 * generated class keeps that word in its display name, {@code @DisplayName("Narrative: Pay by card at checkout")}.
 * <p>
 * No path in @Gherkin2JUnit — the processor discovers the co-located CheckoutNarrative.specb in this package by
 * convention.
 */
@Gherkin2JUnit
@Gherkin2JUnitOptions(keywordSynonyms = {
        @KeywordSynonym(keyword = GherkinKeyword.FEATURE, synonyms = "Narrative")
})
public abstract class CheckoutNarrative {
}
