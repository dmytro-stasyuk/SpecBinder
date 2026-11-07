package dev.specbinder.specreader;

import io.cucumber.gherkin.GherkinDialect;

import java.util.List;
import java.util.function.Function;

/**
 * The kinds of Gherkin keyword, each with the English keyword a spec is rewritten to before it is parsed, and the
 * name it is called by in messages. The {@code *} step keyword is not among them, since it reads the same in every
 * language.
 */
enum KeywordKind {

    FEATURE("Feature", "Feature", true, GherkinDialect::getFeatureKeywords),
    RULE("Rule", "Rule", true, GherkinDialect::getRuleKeywords),
    BACKGROUND("Background", "Background", true, GherkinDialect::getBackgroundKeywords),
    SCENARIO("Scenario", "Scenario", true, GherkinDialect::getScenarioKeywords),
    SCENARIO_OUTLINE("Scenario Outline", "Scenario Outline", true, GherkinDialect::getScenarioOutlineKeywords),
    EXAMPLES("Examples", "Examples", true, GherkinDialect::getExamplesKeywords),
    GIVEN("Given ", "Given", false, GherkinDialect::getGivenKeywords),
    WHEN("When ", "When", false, GherkinDialect::getWhenKeywords),
    THEN("Then ", "Then", false, GherkinDialect::getThenKeywords),
    AND("And ", "And", false, GherkinDialect::getAndKeywords),
    BUT("But ", "But", false, GherkinDialect::getButKeywords);

    private final String englishKeyword;
    private final String displayName;
    private final boolean titleKeyword;
    private final Function<GherkinDialect, List<String>> keywords;

    KeywordKind(String englishKeyword, String displayName, boolean titleKeyword,
                Function<GherkinDialect, List<String>> keywords) {
        this.englishKeyword = englishKeyword;
        this.displayName = displayName;
        this.titleKeyword = titleKeyword;
        this.keywords = keywords;
    }

    /**
     * The English keyword of this kind, as a spec line starts with it: followed by a space for a step keyword, and
     * by nothing for a title keyword, which the colon follows.
     */
    String englishKeyword() {
        return englishKeyword;
    }

    /**
     * The name of this kind in messages, e.g. {@code Then}.
     */
    String displayName() {
        return displayName;
    }

    /**
     * Whether a keyword of this kind starts a title line, such as {@code Feature: Checkout}, rather than a step.
     */
    boolean isTitleKeyword() {
        return titleKeyword;
    }

    /**
     * The keywords of this kind in the given language, as the parser matches them, without {@code *}.
     */
    List<String> keywordsOf(GherkinDialect dialect) {
        return keywords.apply(dialect).stream()
                .filter(keyword -> !keyword.strip().equals("*"))
                .toList();
    }

    /**
     * A word of this kind as a line starts with it, matched the way the parser matches a keyword of a language: a
     * title word as it is, since the colon follows it, and a step word followed by a space, unless it ends in an
     * apostrophe that joins it to the step text, as {@code qu'} does in French.
     */
    String asKeyword(String word) {
        if (titleKeyword || word.endsWith("'")) {
            return word;
        }
        return word + " ";
    }
}
