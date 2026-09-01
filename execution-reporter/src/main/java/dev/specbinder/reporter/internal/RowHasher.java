package dev.specbinder.reporter.internal;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * Identity of a single Scenario Outline example row, derived from the row's values alone.
 * <p>
 * Because the hash ignores where the row sits in the Examples table, a row keeps its identity
 * when the table is reordered — which is what lets a recorded outcome follow its row rather
 * than the ordinal it happened to occupy. Column order does not matter either: keys are sorted
 * before hashing.
 * <p>
 * Lives beside {@link ScenarioHasher} so that tooling reconciling reports can compute the same
 * identity the reporter records.
 */
public final class RowHasher {

    private RowHasher() {
    }

    public static String hash(Map<String, String> row) {
        if (row == null || row.isEmpty()) {
            return null;
        }
        List<String> keys = new ArrayList<>(row.keySet());
        Collections.sort(keys);
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < keys.size(); i++) {
            if (i > 0) sb.append('\n');
            String key = keys.get(i);
            sb.append(key).append('=').append(row.get(key));
        }
        return sha256Hex(sb.toString());
    }

    private static String sha256Hex(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] digest = md.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder(digest.length * 2);
            for (byte b : digest) {
                hex.append(String.format("%02x", b));
            }
            return hex.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 not available", e);
        }
    }
}
