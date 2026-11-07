package dev.specbinder.processor.utils;

import dev.specbinder.processor.utils.StepKeywordUtils.ResolvedStepKeyword;

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
     * Generates a method name from the first line of a Gherkin step definition. The step keyword is left out of the
     * name however many words it has, unless {@code useStepKeywordInStepMethodName} is set, in which case the keyword
     * the step resolved to starts the name: the step's own keyword, or for And, But and * the keyword of the step
     * before it.
     *
     * @param stepFirstLine                  the first line of the Gherkin step definition, starting with its keyword
     * @param stepKeyword                    the keyword of the step, as the parser read it
     * @param resolvedStepKeyword            the keyword the step resolved to
     * @param useStepKeywordInStepMethodName if true, the resolved keyword is included as a prefix in the generated
     *                                       method name
     * @return a sanitized method name suitable for use in Java code
     */
    public static String getStepMethodName(String stepFirstLine, String stepKeyword,
                                           ResolvedStepKeyword resolvedStepKeyword,
                                           boolean useStepKeywordInStepMethodName) {

        StringBuilder methodNameBuilder = new StringBuilder();

        String stepText = StepKeywordUtils.textAfterKeyword(stepFirstLine, stepKeyword);
        String nameText = useStepKeywordInStepMethodName ? resolvedStepKeyword.spelling() + " " + stepText : stepText;

        String[] words = nameText.split("\\s+");
        for (String word : words) {

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
}
