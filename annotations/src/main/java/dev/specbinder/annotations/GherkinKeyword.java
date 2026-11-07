package dev.specbinder.annotations;

/**
 * The Gherkin keywords a team can give synonyms with {@link KeywordSynonym}. Each constant stands for a keyword with
 * all its synonyms in every language, e.g. {@link #SCENARIO} for both {@code Scenario} and {@code Example} in English
 * and for {@code Szenario} in German. The {@code *} step keyword is not among them, since it reads the same in every
 * language.
 *
 * @see Gherkin2JUnitOptions#keywordSynonyms()
 */
public enum GherkinKeyword {

    /** {@code Feature}, with its English synonyms {@code Ability} and {@code Business Need}. */
    FEATURE,

    /** {@code Rule}. */
    RULE,

    /** {@code Background}. */
    BACKGROUND,

    /** {@code Scenario}, with its English synonym {@code Example}. */
    SCENARIO,

    /** {@code Scenario Outline}, with its English synonym {@code Scenario Template}. */
    SCENARIO_OUTLINE,

    /** {@code Examples}, with its English synonym {@code Scenarios}. */
    EXAMPLES,

    /** {@code Given}. */
    GIVEN,

    /** {@code When}. */
    WHEN,

    /** {@code Then}. */
    THEN,

    /** {@code And}. */
    AND,

    /** {@code But}. */
    BUT
}
