package dev.specbinder.processor.gherkin.hash;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;
import java.util.List;

/**
 * Computes the canonical scenario hash from an ordered list of canonical steps.
 *
 * <p>The hash input is built by joining each step's canonical block with {@code \n}
 * (no trailing newline). A step's canonical block is the step text, optionally
 * followed by {@code \n} + the canonical DataTable, optionally followed by {@code \n}
 * + the canonical DocString. UTF-8 bytes are SHA-256'd; the digest is returned as
 * lowercase hex.
 *
 * <p>The same algorithm runs on the IntelliJ plugin side over PSI-derived
 * {@code CanonicalStep}s; algorithm parity is enforced by golden-hash tests on
 * both sides.
 */
public final class ScenarioHasher {

    private ScenarioHasher() {
    }

    /**
     * Computes a SHA-256 hex digest from the given canonical steps.
     *
     * @param steps ordered list of canonical steps
     * @return lowercase hex SHA-256 digest
     */
    public static String hash(List<CanonicalStep> steps) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < steps.size(); i++) {
            if (i > 0) sb.append('\n');
            CanonicalStep step = steps.get(i);
            sb.append(step.stepText());
            if (step.canonicalDataTable() != null) {
                sb.append('\n').append(step.canonicalDataTable());
            }
            if (step.canonicalDocString() != null) {
                sb.append('\n').append(step.canonicalDocString());
            }
        }
        return sha256Hex(sb.toString());
    }

    private static String sha256Hex(String input) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] bytes = digest.digest(input.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(bytes);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 not available", e);
        }
    }
}
