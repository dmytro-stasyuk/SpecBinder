package dev.specbinder.annotations;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * A team's own words for one Gherkin keyword.
 *
 * <p>Used only as a value inside {@link Gherkin2JUnitOptions#keywordSynonyms()}:
 * <pre>
 * &#64;Gherkin2JUnitOptions(keywordSynonyms = {
 *     &#64;KeywordSynonym(keyword = GherkinKeyword.GIVEN, synonyms = "Assuming"),
 *     &#64;KeywordSynonym(keyword = GherkinKeyword.FEATURE, synonyms = "Story", replace = true)
 * })
 * </pre>
 * A spec then accepts {@code Assuming a cart} as a Given step, and starts with {@code Story: Checkout} instead of
 * {@code Feature: Checkout}.
 *
 * @see Gherkin2JUnitOptions#keywordSynonyms()
 */
@Retention(RetentionPolicy.RUNTIME)
@Target({})
public @interface KeywordSynonym {

    /**
     * The keyword the synonyms stand for.
     *
     * @return the keyword
     */
    GherkinKeyword keyword();

    /**
     * The words a spec may use for the keyword, as the spec spells them: without the {@code :} that follows a title
     * keyword such as {@code Story}, and without the space that follows a step keyword such as {@code Assuming}. A
     * step synonym ending in an apostrophe, such as {@code Sachant qu'}, is followed directly by the step text.
     *
     * @return the synonyms of the keyword
     */
    String[] synonyms();

    /**
     * Whether the synonyms are the only words for the keyword. By default they are accepted next to the keyword's
     * words in the languages a spec is read with; with {@code replace = true}, a line starting with one of those
     * words is no longer a keyword line.
     *
     * @return true if the synonyms replace the keyword's words in every language
     */
    boolean replace() default false;
}
