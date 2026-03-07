package dev.specbinder.feature2junit.utils;

import com.squareup.javapoet.MethodSpec;
import dev.specbinder.feature2junit.exception.ProcessingException;

import java.util.List;

/**
 * Utility class for generating method names from Gherkin step definitions.
 */
public class MethodNamingUtils {

    private MethodNamingUtils() {
        /**
         * utility class
         */
    }

    /**
     * Generates a method name from the first line of a Gherkin step definition.
     *
     * @param stepFirstLine                  the first line of the Gherkin step definition
     * @param scenarioStepsMethodSpecs       a list of MethodSpec objects representing the scenario steps
     * @param stepLine                       the line number of the step in the feature file
     * @param useStepKeywordInStepMethodName if true, the step keyword (Given/When/Then) is included
     *                                       as a prefix in the generated method name
     * @return a sanitized method name suitable for use in Java code
     */
    public static String getStepMethodName(String stepFirstLine, List<MethodSpec> scenarioStepsMethodSpecs, long stepLine,
                                               boolean useStepKeywordInStepMethodName) {

        StringBuilder methodNameBuilder = new StringBuilder();

        String[] words = stepFirstLine.split("\\s+");
        for (int i = 0; i < words.length; i++) {

            String word = words[i];

            if (i == 0) {
                boolean isAndButAsterisk = word.equalsIgnoreCase("and")
                        || word.equalsIgnoreCase("but")
                        || word.equalsIgnoreCase("*");

                if (isAndButAsterisk) {
                    // Always validate that And/But/* have a previous step
                    validatePreviousStepExists(scenarioStepsMethodSpecs, stepLine);

                    if (useStepKeywordInStepMethodName) {
                        word = getPreviousGWTStepWord(scenarioStepsMethodSpecs, stepLine);
                    } else {
                        continue;
                    }
                } else {
                    // Given/When/Then keyword
                    if (!useStepKeywordInStepMethodName) {
                        continue;
                    }
                }
            }

            StringBuilder sanitizedWordBuilder = new StringBuilder();

            boolean isFirstWord = methodNameBuilder.isEmpty();

            if (isFirstWord) {
                // first word in method name - should not be capitalized and should start with
                // a character suitable for a method name
                for (char c : word.toCharArray()) {
                    if (sanitizedWordBuilder.length() == 0) {
                        // nothing added yet - so check if char is suitable as a starting char
                        if (Character.isJavaIdentifierStart(c)) {
                            char wordFirstChar = Character.toLowerCase(c);
                            sanitizedWordBuilder.append(wordFirstChar);
                        } else {
                            // skip characters that are not allowed for method name start
                        }
                    } else {
                        if (Character.isJavaIdentifierPart(c)) {
                            // always convert to lower case
                            char charInLowerCase = Character.toLowerCase(c);
                            sanitizedWordBuilder.append(charInLowerCase);
                        } else {
                            // skip
                        }
                    }
                }

            } else {
                /**
                 * all other words should be capitalized
                 */
                boolean shouldCapitalizeNext = true;
                for (char c : word.toCharArray()) {

                    if (Character.isJavaIdentifierPart(c)) {
                        char charToAppend;
                        if (sanitizedWordBuilder.isEmpty() || shouldCapitalizeNext) {
                            charToAppend = Character.toUpperCase(c);
                            shouldCapitalizeNext = false;
                        } else {
                            charToAppend = Character.toLowerCase(c);
                        }
                        sanitizedWordBuilder.append(charToAppend);
                    } else {
                        // Skip non-identifier character
                        // Apostrophes don't trigger capitalization (possessives like "user's")
                        // Other punctuation does (like @ and . in "email@domain.com")
                        if (c != '\'') {
                            shouldCapitalizeNext = true;
                        }
                    }
                }
            }

            String sanitizedWord = sanitizedWordBuilder.toString();
            methodNameBuilder.append(sanitizedWord);

        }

        String sanitizedMethodName = methodNameBuilder.toString();
        return sanitizedMethodName;
    }

    private static void validatePreviousStepExists(List<MethodSpec> scenarioStepsMethodSpecs, long stepLine) {
        if (scenarioStepsMethodSpecs.isEmpty()) {
            throw new ProcessingException(
                    "Step on line - " + stepLine
                            + " starts with 'And', but there are no previous scenario steps defined");
        }
    }

    private static String getPreviousGWTStepWord(List<MethodSpec> scenarioStepsMethodSpecs, long stepLine) {

        MethodSpec lastScenarioMethodSpec = scenarioStepsMethodSpecs.get(scenarioStepsMethodSpecs.size() - 1);
        String lastMethodName = lastScenarioMethodSpec.name;
        if (lastMethodName.startsWith("given")) {
            return "given";
        } else if (lastMethodName.startsWith("when")) {
            return "when";
        } else if (lastMethodName.startsWith("then")) {
            return "then";
        } else {
            throw new ProcessingException(
                    "Step on line - " + stepLine
                            + " starts with 'And', but there are no previous scenario steps defined that have a step annotation");
        }
    }
}
