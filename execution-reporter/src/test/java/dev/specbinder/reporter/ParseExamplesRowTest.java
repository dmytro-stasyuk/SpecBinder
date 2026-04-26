package dev.specbinder.reporter;

import org.junit.jupiter.api.Test;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

class ParseExamplesRowTest {

    @Test
    void parsesSingleColumn() {
        Map<String, String> row = SpecBinderReporter.parseExamplesRow("Example 1: [name = Alice]");
        assertEquals(Map.of("name", "Alice"), row);
    }

    @Test
    void parsesMultipleColumnsPreservingOrder() {
        Map<String, String> row = SpecBinderReporter.parseExamplesRow(
                "Example 2: [name = Wireless Headphones, start qty = 1, price = 60.00]");
        assertEquals(3, row.size());
        assertEquals("Wireless Headphones", row.get("name"));
        assertEquals("1", row.get("start qty"));
        assertEquals("60.00", row.get("price"));
    }

    @Test
    void returnsNullWhenBracketsAbsent() {
        assertNull(SpecBinderReporter.parseExamplesRow("just a plain name"));
    }

    @Test
    void returnsNullWhenPairLacksEqualsSeparator() {
        assertNull(SpecBinderReporter.parseExamplesRow("Example 1: [malformed]"));
    }

    @Test
    void returnsNullForNullInput() {
        assertNull(SpecBinderReporter.parseExamplesRow(null));
    }
}
