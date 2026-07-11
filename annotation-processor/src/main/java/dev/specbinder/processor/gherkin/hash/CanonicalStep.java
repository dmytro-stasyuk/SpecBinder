package dev.specbinder.processor.gherkin.hash;

/**
 * Canonical, hash-stable representation of a single Gherkin step.
 *
 * <p>The fields are pre-canonicalized strings as defined by the scenario-hash spec:
 * <ul>
 *   <li>{@code stepText} — the textual portion AFTER the keyword and the single space
 *       following it, with inter-word whitespace normalized: runs of whitespace are
 *       collapsed to a single space and leading/trailing whitespace is stripped, so
 *       cosmetic spacing differences do not affect the hash. The keyword
 *       (Given/When/Then/And/But/*) is excluded and therefore also has no effect on the
 *       hash.</li>
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
