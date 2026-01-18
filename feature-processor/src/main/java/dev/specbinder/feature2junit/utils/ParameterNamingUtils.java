package dev.specbinder.feature2junit.utils;

/**
 * Utility class for generating method parameter names from Gherkin scenario parameters.
 */
public class ParameterNamingUtils {

    private ParameterNamingUtils() {
        /**
         * utility class
         */
    }

    /**
     * Generates a method parameter name from a Gherkin scenario parameter.
     * @param scenarioParameter the scenario parameter to convert
     * @return a sanitized method parameter name suitable for use in Java code
     */
    public static String toMethodParameterName(String scenarioParameter) {

        StringBuilder parameterNameBuilder = new StringBuilder();

        String[] words = scenarioParameter.split("[\\s.]+");

        for (int i = 0; i < words.length; i++) {

            String word = words[i];

            // Check if the entire word is uppercase (all letter characters are uppercase)
            boolean isAllUppercase = word.chars()
                .filter(Character::isLetter)
                .allMatch(Character::isUpperCase)
                && word.chars().anyMatch(Character::isLetter); // must have at least one letter

            // Remove invalid characters
            StringBuilder sanitizedWordBuilder = new StringBuilder();
            for (char c : word.toCharArray()) {

                if (sanitizedWordBuilder.length() == 0) {
                    // nothing added yet - so check if char is suitable as a starting char
                    if (Character.isJavaIdentifierStart(c)) {
                        char wordFirstChar;
                        if (isAllUppercase) {
                            // If the whole word is uppercase, preserve it as-is
                            wordFirstChar = c;
                        } else if (parameterNameBuilder.length() == 0) {
                            // first word in method name - so use lower case
                            wordFirstChar = Character.toLowerCase(c);
                        } else {
                            // not the first word - so use upper case
                            wordFirstChar = Character.toUpperCase(c);
                        }
                        sanitizedWordBuilder.append(wordFirstChar);
                    } else if (Character.isJavaIdentifierPart(c) && parameterNameBuilder.length() > 0) {
                        // It's a digit or other valid identifier part, and we already have something in the parameter name
                        sanitizedWordBuilder.append(c);
                    } else {
                        // skip - can't use this character
                    }

                } else {

                    if (Character.isJavaIdentifierPart(c)) {
                        // Preserve the original casing of all characters except the first character of each word
                        sanitizedWordBuilder.append(c);
                    } else {
                        // skip
                    }
                }

            }

            String sanitizedWord = sanitizedWordBuilder.toString();
            parameterNameBuilder.append(sanitizedWord);

        }

        String sanitizedMethodName = parameterNameBuilder.toString();
        return sanitizedMethodName;
    }
}
