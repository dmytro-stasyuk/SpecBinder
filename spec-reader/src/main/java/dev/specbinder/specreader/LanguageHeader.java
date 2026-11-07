package dev.specbinder.specreader;

import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Reads the {@code # language:} header of a spec file, which picks the language of every keyword in the spec, e.g.
 * {@code # language: de} for German. The header is a comment line above the first keyword line.
 */
public final class LanguageHeader {

    private static final Pattern LANGUAGE_PATTERN = Pattern.compile("^\\s*#\\s*language\\s*:\\s*([a-zA-Z\\-_]+)\\s*$");

    private LanguageHeader() {
    }

    /**
     * Returns the index of the header line, or -1 when the spec has none. Only the blank and comment lines at the top
     * of the spec are looked at, since a language comment further down is an ordinary comment.
     *
     * @param lines the lines of the spec file
     * @return the index of the header line, or -1
     */
    public static int findLine(String[] lines) {
        for (int i = 0; i < lines.length; i++) {
            String trimmed = lines[i].strip();
            if (trimmed.isEmpty()) {
                continue;
            }
            if (!trimmed.startsWith("#")) {
                return -1;
            }
            if (LANGUAGE_PATTERN.matcher(lines[i]).matches()) {
                return i;
            }
        }
        return -1;
    }

    /**
     * Returns the language code the header names, e.g. {@code de}, or nothing when the spec has no header.
     *
     * @param lines the lines of the spec file
     * @return the language code of the header
     */
    static Optional<String> languageOf(String[] lines) {
        int languageLine = findLine(lines);
        if (languageLine < 0) {
            return Optional.empty();
        }
        Matcher matcher = LANGUAGE_PATTERN.matcher(lines[languageLine]);
        return matcher.matches() ? Optional.of(matcher.group(1)) : Optional.empty();
    }
}
