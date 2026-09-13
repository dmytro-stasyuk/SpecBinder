# Example 8: Examples Table Values in Every Kind of Parameter

Demonstrates how the values of a `Examples` table reach **every** kind of step parameter of a
`Scenario Outline` — a quoted value, a doc string and a data table — not just the quoted ones.

## What this demonstrates

- `<placeholder>` filling a **whole quoted value** becomes a method parameter, with its type inferred
- `<placeholder>` **mixed with fixed text** inside a quoted value is substituted at the call site instead
- `<placeholder>` inside a **doc string** is substituted at the call site; the parameter stays `String`
- `<placeholder>` inside a **data table** cell is substituted at the call site too
- A data table can mix **static cells and placeholders** in the same table
- A doc string may carry a **content type** (`"""json`), which the IDE uses for highlighting and
  formatting while SpecBinder still passes the content through as a plain `String`
- Inside a typed doc string, **wrap the placeholder in quotes** (`"<qty>"`). Substitution is textual,
  so the template itself must be valid for its content type — a bare `<qty>` is not valid JSON and the
  IDE reports *"JSON standard does not allow such tokens"*. The trade-off: `"<qty>"` substitutes to the
  JSON string `"1"`, whereas a bare `<qty>` would have produced the number `1`
- Two table steps need **distinct trailing words**, because the generated parameter type is named
  after them — two steps both ending `should be:` would share one merged `BeParam` class
- A doc string may also be typed `image`, `svg` or `html`. SpecBinder still passes the content
  through as a plain `String`; the IDE plugin renders it below the doc string as a **preview**

## Gherkin → JUnit mapping

### Placeholder inside a typed doc string

```gherkin
And I submit the order with the following payload:
  """json
  {
    "product": "<product>",
    "quantity": "<qty>",
    "total": "<total>"
  }
  """
```

Substitution happens at the call site, so the step method signature is unaffected:

```java
public abstract void iSubmitTheOrderWithTheFollowingPayload(String docString);

iSubmitTheOrderWithTheFollowingPayload("""
        {
          "product": "<product>",
          "quantity": "<qty>",
          "total": "<total>"
        }
        """
        .replaceAll("<product>", product)
        .replaceAll("<qty>", qty.toString())
        .replaceAll("<total>", total.toString()));
```

### The content types beyond `json`

The last scenario is a plain `Scenario:`, not an outline — it is here because the three remaining
content types belong beside the `json` one above, and because every one of them is a `String` to
SpecBinder and a rendered document to the IDE.

```gherkin
When the confirmation badge is
  """image
  iVBORw0KGgoAAAANSUhEUgAAAIwAAABpCAIAAABnK1xY...
  """
```

`image` holds the picture base64 encoded — the format is worked out from the data, so PNG, JPEG,
GIF and WebP all work. `svg` holds the markup of a drawing and `html` holds a fragment of a page.
The generated signature is the same in all four cases:

```java
public abstract void theConfirmationBadgeIs(String docString);
public abstract void theDeliveryIconIs(String docString);
public abstract void theConfirmationPageIs(String docString);
```

So nothing about the content type reaches the test code. It is there for the reader, and for the
editor: the SpecBinder IntelliJ plugin puts an eye icon in the gutter beside the opening fence and
renders the picture, the drawing or the page below the closing one.

### Placeholders inside a data table

```gherkin
Then the order should contain the following lines:
  | product   | quantity | line total |
  | <product> | <qty>    | <total>    |
```

Every cell is a placeholder, so the row is built straight from the scenario's parameters — with the
types inferred from the `Examples` values (`Integer`, `Double`):

```java
public abstract void theOrderShouldContainTheFollowingLines(List<LinesParam> lines);

theOrderShouldContainTheFollowingLines(List.of(new LinesParam(product, qty, total)));
```

### Static cells and placeholders in the same table

```gherkin
Then the order should show the following promotion details:
  | field     | value      |
  | promotion | <promo>    |
  | channel   | web        |
  | discount  | <discount> |
```

```java
theOrderShouldShowTheFollowingPromotionDetails(List.of(
        new DetailsParam("promotion", promo),
        new DetailsParam("channel", "web"),
        new DetailsParam("discount", discount)));
```

### Fixed text and placeholders in the same quoted value

A quoted value that is *entirely* a placeholder is passed straight through as a typed parameter. One
that mixes literal text with placeholders is substituted at the call site instead — the same
`replaceAll` pattern used for doc strings and data-table cells.

```gherkin
When I add "<product>" to the cart
And I place the order with reference "ORD-<year>-<region>"
Then the tracking link should be "https://shop.example.com/orders/<region>/<year>"
```

```java
iAdd$p1ToTheCart(product);                              // whole value — passed directly

iPlaceTheOrderWithReference$p1("ORD-<year>-<region>"    // mixed — substituted at the call site
        .replaceAll("<year>", year.toString())
        .replaceAll("<region>", region));

theTrackingLinkShouldBe$p1("https://shop.example.com/orders/<region>/<year>"
        .replaceAll("<year>", year.toString())
        .replaceAll("<region>", region));
```

Note `year.toString()`: `year` was inferred as `Integer` from the `Examples` values, while `region`
is already a `String`.

## Run it

```bash
./mvnw -pl examples/common-use-cases/example-8 test-compile
```

The generated class appears under
`target/generated-test-sources/test-annotations/specs/ShoppingCartScenarios.java`.
