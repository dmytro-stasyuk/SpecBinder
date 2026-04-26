package dev.specbinder.processor.gherkin.hash;

/**
 * Canonical, hash-stable representation of a single Gherkin step.
 *
 * <p>The fields are pre-canonicalized strings as defined by the scenario-hash spec:
 * <ul>
 *   <li>{@code stepText} — the textual portion AFTER the keyword and the single space
 *       following it, taken literally (no trim, no normalization). The keyword
 *       (Given/When/Then/And/But) is excluded.</li>
 *   <li>{@code canonicalDataTable} — null if the step has no DataTable; otherwise the
 *       canonical serialization: cell values trimmed of leading/trailing whitespace,
 *       cells joined by {@code |} with the leading/trailing {@code |} kept, rows
 *       joined by {@code \n}.</li>
 *   <li>{@code canonicalDocString} — null if the step has no DocString; otherwise the
 *       canonical serialization including the opening and closing {@code """} markers
 *       (and any content-type tag like {@code """html}). Common indent is stripped
 *       from every line including the markers; trailing whitespace is stripped from
 *       every line; lines are joined by {@code \n}.</li>
 * </ul>
 *
 * @param stepText             step text after the keyword
 * @param canonicalDataTable   canonical DataTable serialization, or null
 * @param canonicalDocString   canonical DocString serialization, or null
 */
public record CanonicalStep(String stepText, String canonicalDataTable, String canonicalDocString) {
}
