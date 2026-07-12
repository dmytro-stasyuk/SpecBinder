# Example 2: DocStrings for Multi-line Input

Demonstrates how Gherkin doc strings (triple-quoted blocks) map to `String` parameters with formatting preserved via Java text blocks.

## What this demonstrates

- Doc strings become a trailing `String` parameter on the step method
- Method naming is **unaffected** by the doc string (no extra `$p` placeholder)
- Formatting (newlines, indentation) is **preserved** via Java text blocks (`"""..."""`)
- Doc strings can be combined with quoted parameters in the same step
- Works with any content: JSON, plain text, XML, etc.

## Gherkin → JUnit mapping

### Doc string only (no quoted args)

```gherkin
When I submit the following shipping address:
  """
  {
    "line1": "Baker St 221B",
    "city": "London"
  }
  """
```

```java
// Step method — one String parameter for the doc string
void iSubmitTheFollowingShippingAddress(String docString) { ... }

// Call site — Java text block preserves formatting
iSubmitTheFollowingShippingAddress("""
        {
          "line1": "Baker St 221B",
          "city": "London"
        }
        """);
```

### Quoted args + doc string

```gherkin
When I add item "Wireless Headphones" with options:
  """
  { "color": "Black" }
  """
```

```java
// Quoted arg comes first, doc string is appended after
void iAddItem$p1WithOptions(String p1, String docString) { ... }

iAddItem$p1WithOptions("Wireless Headphones", """
        { "color": "Black" }
        """);
```

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/ShoppingCart.specb` | Three scenarios: JSON doc string, quoted arg + doc string, plain text doc string |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class annotated with `@Gherkin2JUnit` |
