package dev.specbinder.specreader;

import dev.specbinder.annotations.KeywordLanguage;
import io.cucumber.gherkin.GherkinDialect;
import io.cucumber.gherkin.GherkinDialects;
import org.junit.jupiter.api.Test;

import java.util.Locale;
import java.util.Map;
import java.util.TreeMap;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Keeps {@link KeywordLanguage} in step with the languages the Gherkin parser supports, so that upgrading Cucumber
 * fails this test until the enum is updated in the same release.
 */
class KeywordLanguageTest {

    @Test
    void hasOneConstantForEveryLanguageOfTheGherkinParser() {

        Map<String, String> expected = new TreeMap<>();
        for (GherkinDialect dialect : GherkinDialects.getDialects()) {
            expected.put(dialect.getLanguage(), constantNameOf(dialect));
        }

        Map<String, String> actual = new TreeMap<>();
        for (KeywordLanguage language : KeywordLanguage.values()) {
            actual.put(language.code(), language.name());
        }

        assertEquals(expected, actual, "KeywordLanguage constants by Gherkin code");
    }

    /**
     * The constant name for a language: its English name in UPPER_SNAKE, except that a language in more than one
     * script names its script, and the English variants start with ENGLISH_.
     */
    private static String constantNameOf(GherkinDialect dialect) {
        String code = dialect.getLanguage();
        if (code.startsWith("en-")) {
            return "ENGLISH_" + upperSnake(dialect.getName().replace("English", ""));
        }
        String constantName = upperSnake(dialect.getName());
        if (code.endsWith("-Cyrl")) {
            constantName += "_CYRILLIC";
        }
        return constantName;
    }

    private static String upperSnake(String words) {
        return words.replaceAll("[^A-Za-z]+", "_").replaceAll("^_|_$", "").toUpperCase(Locale.ROOT);
    }
}
