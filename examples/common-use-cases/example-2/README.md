# Example 2: DocStrings for Multi-line Input

Demonstrates how Gherkin doc strings (triple-quoted blocks) map to `String` parameters with formatting preserved via Java text blocks.

## What this demonstrates

- Doc strings become a trailing `String` parameter on the step method
- Method naming is **unaffected** by the doc string (no extra `$p` placeholder)
- Formatting (newlines, indentation) is **preserved** via Java text blocks (`"""..."""`)
- Doc strings can be combined with quoted parameters in the same step
- Works with any content: JSON, plain text, XML, etc.
- A doc string may carry a **content type** (`json`, `image`, `svg`, `html`) — the IDE uses it to highlight or preview the
  content, while SpecBinder still passes it through as a plain `String`
- The concrete `ShoppingCartTest` receives each doc string exactly as written — the plain-text confirmation is
  compared verbatim, line breaks included

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

### Content types

A doc string may name its content type right after the opening fence. The last scenario uses three of them — the shop's
branding assets as inputs, and the confirmation page it produces as the expected outcome:

```gherkin
Given the shop uses the following confirmation badge:
  """image
  iVBORw0KGgoAAAANSUhEUgAAAIwAAABpCAIAAABnK1xY...
  """
And the shop uses the following delivery icon:
  """svg
  <svg xmlns="http://www.w3.org/2000/svg" width="120" height="72" viewBox="0 0 120 72">...</svg>
  """
And I have completed a purchase
Then I should receive the following confirmation page:
  """html
  <h2>Thank you for your order!</h2>
  ...
  """
```

`image` holds a picture base64 encoded — the format is worked out from the data, so PNG, JPEG, GIF and WebP all work.
`svg` holds the markup of a drawing and `html` holds a fragment of a page. The generated signature is the same as for
any other doc string:

```java
public abstract void theShopUsesTheFollowingConfirmationBadge(String docString);
public abstract void theShopUsesTheFollowingDeliveryIcon(String docString);
public abstract void iShouldReceiveTheFollowingConfirmationPage(String docString);
```

So nothing about the content type reaches the test code. It is there for the reader, and for the editor: the SpecBinder
IntelliJ plugin puts an eye icon in the gutter beside the opening fence and renders the picture, the drawing or the page
below the closing one.

## Files

| File | Purpose |
|------|---------|
| `src/test/java/.../ShoppingCart.specb` | Four scenarios: JSON doc string, quoted arg + doc string, plain text doc string, and typed `image` / `svg` / `html` doc strings |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class with bare `@Gherkin2JUnit` — discovers the co-located spec by convention |
| `src/test/java/.../ShoppingCartTest.java` | Concrete subclass implementing the step methods with assertions |

## Class hierarchy

```
ShoppingCartFeature.java          (marker class, @Gherkin2JUnit)
  └→ ShoppingCartScenarios.java   (generated, abstract, contains @Test methods)
      └→ ShoppingCartTest.java    (your concrete class, implements step methods)
```
