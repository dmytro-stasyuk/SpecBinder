package dev.specbinder.processor.gherkin;

/**
 * Names the nested classes and methods generated for the specs of a spec file holding several of them.
 */
final class SpecNamingUtils {

    private SpecNamingUtils() {
    }

    /**
     * Turns a spec keyword into a Java identifier: words keep their casing and are joined by {@code _}, and
     * characters not allowed in a Java name are dropped, e.g. "Business Need" → "Business_Need",
     * "Ahoy matey!" → "Ahoy_matey".
     */
    static String toIdentifier(String keyword) {
        StringBuilder identifier = new StringBuilder();
        for (String word : keyword.trim().split("\\s+")) {
            StringBuilder cleanWord = new StringBuilder();
            for (char c : word.toCharArray()) {
                if (Character.isLetterOrDigit(c) || c == '_') {
                    cleanWord.append(c);
                }
            }
            if (cleanWord.isEmpty()) {
                continue;
            }
            if (!identifier.isEmpty()) {
                identifier.append('_');
            }
            identifier.append(cleanWord);
        }
        if (identifier.isEmpty() || !Character.isJavaIdentifierStart(identifier.charAt(0))) {
            identifier.insert(0, '_');
        }
        return identifier.toString();
    }
}
