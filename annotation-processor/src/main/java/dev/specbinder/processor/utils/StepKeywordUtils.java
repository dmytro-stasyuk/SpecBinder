package dev.specbinder.processor.utils;

import dev.specbinder.processor.exception.ProcessingException;
import io.cucumber.messages.types.Step;
import io.cucumber.messages.types.StepKeywordType;

import java.util.List;
import java.util.Locale;

/**
 * Utility class for working out what the keyword of a Gherkin step stands for, in whichever language the spec is
 * written.
 * <p>
 * Keywords are told apart by the keyword type the Gherkin parser assigns to them rather than by their text, because
 * the text depends on the language and can be several words long: {@code Given}, {@code Angenommen},
 * {@code Gegeben sei} and {@code Etant donné qu'} all start a Given step.
 */
public class StepKeywordUtils {

    /**
     * What the keyword of a step resolved to. A step starting with And, But or * takes both values from the step
     * before it.
     *
     * @param gwtKeyword the Given/When/Then meaning of the keyword: {@code given}, {@code when} or {@code then}
     * @param spelling   the keyword as the spec spells it, without surrounding whitespace, e.g. {@code Gegeben sei}
     */
    public record ResolvedStepKeyword(String gwtKeyword, String spelling) {
    }

    private StepKeywordUtils() {
        /**
         * utility class
         */
    }

    /**
     * Resolves the keyword of a step. A Given, When or Then keyword resolves to itself; an And, But or * keyword
     * resolves to the keyword of the step before it.
     *
     * @param step                 the step whose keyword to resolve
     * @param resolvedStepKeywords the keywords the steps before it resolved to, in step order
     * @return the keyword the step resolves to
     * @throws ProcessingException if the step starts with And, But or * and no step comes before it
     */
    public static ResolvedStepKeyword resolve(Step step, List<ResolvedStepKeyword> resolvedStepKeywords) {

        String spelling = step.getKeyword().strip();
        StepKeywordType keywordType = keywordTypeOf(step);

        if (keywordType == StepKeywordType.CONTEXT) {
            return new ResolvedStepKeyword("given", spelling);
        } else if (keywordType == StepKeywordType.ACTION) {
            return new ResolvedStepKeyword("when", spelling);
        } else if (keywordType == StepKeywordType.OUTCOME) {
            return new ResolvedStepKeyword("then", spelling);
        }

        if (resolvedStepKeywords.isEmpty()) {
            throw new ProcessingException(
                    "Step on line - " + step.getLocation().getLine()
                            + " starts with 'And', but there are no previous scenario steps defined");
        }
        return resolvedStepKeywords.get(resolvedStepKeywords.size() - 1);
    }

    /**
     * Removes the keyword from the start of a step's first line, e.g. {@code Gegeben sei ein Warenkorb} becomes
     * {@code ein Warenkorb}.
     *
     * @param stepFirstLine the first line of the step, starting with its keyword
     * @param stepKeyword   the keyword of the step, as the parser read it
     * @return the rest of the line, without surrounding whitespace
     */
    public static String textAfterKeyword(String stepFirstLine, String stepKeyword) {

        String keyword = stepKeyword.strip();
        String text = stepFirstLine.startsWith(keyword) ? stepFirstLine.substring(keyword.length()) : stepFirstLine;
        return text.strip();
    }

    /**
     * The keyword type the parser assigned to the step: {@code UNKNOWN} for {@code *}, which may stand for any
     * keyword, and {@code CONJUNCTION} for And and But. Gherkin versions older than keyword types assign none, in
     * which case the type is read from the English keyword text.
     */
    private static StepKeywordType keywordTypeOf(Step step) {

        if (step.getKeywordType().isPresent()) {
            return step.getKeywordType().get();
        }
        return switch (step.getKeyword().strip().toLowerCase(Locale.ROOT)) {
            case "given" -> StepKeywordType.CONTEXT;
            case "when" -> StepKeywordType.ACTION;
            case "then" -> StepKeywordType.OUTCOME;
            default -> StepKeywordType.CONJUNCTION;
        };
    }
}
