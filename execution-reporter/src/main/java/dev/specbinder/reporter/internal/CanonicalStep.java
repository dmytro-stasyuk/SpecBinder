package dev.specbinder.reporter.internal;

/**
 * Canonical, hash-stable representation of a single Gherkin step on the reporter side —
 * a direct mirror of {@code dev.specbinder.processor.gherkin.hash.CanonicalStep} in the
 * annotation processor. The two implementations are intentionally duplicated rather than
 * extracted to a shared module so neither side needs to drag the Cucumber AST dependency
 * into a module it would otherwise not depend on; algorithm parity is enforced by golden
 * hash tests in each module.
 *
 * @param stepText           step text after the keyword (no keyword, no trim)
 * @param canonicalDataTable canonical DataTable serialization, or null
 * @param canonicalDocString canonical DocString serialization, or null
 */
public record CanonicalStep(String stepText, String canonicalDataTable, String canonicalDocString) {
}
