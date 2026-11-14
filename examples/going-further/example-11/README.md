# Example 11: Composite Steps

Demonstrates **composite steps**: a step directly followed by `*` steps carries out one business action through the
sub-steps written under it. The scenario still reads as "the customer checks out", while the generated test calls
"open the cart", "confirm the delivery address" and "pay with the saved card" in that order, each with a step method of
its own.

## What this demonstrates

- `@Gherkin2JUnitOptions(enableCompositeSteps = true)` turns a step followed by `*` steps into a composite step
- A composite step in the `Background` — `"Alice" is signed in` signs in before every scenario
- Sub-steps reading their composite step's quoted values — `"<$p1>"`, `"<$p2>"`
- A sub-step taking its composite step's whole data table — `"<$dataTable>"` — and one reading a single cell —
  `"<$product[1]>"`, the `product` of the table's first row
- A sub-step taking its composite step's doc string — `"<$docString>"`
- Composite steps in a `Scenario Outline`, where the Examples values reach the sub-steps too
- A generated composite method overridden in the test class to check the action as a whole
- `@ExtendWith(SpecBinderReporter.class)` recording each composite step's sub-steps in the execution report

## How a composite step is generated

Every composite step gets a **composite method** in the generated `CheckoutScenarios`. It takes the step's values and
a lambda holding the sub-steps' calls, and runs that lambda. Each sub-step gets an **ordinary step method** — the same
one it would get written as a step of its own — so `CheckoutTest` implements sub-steps like any other step, and never
needs to implement a composite method.

```java
protected void theCartHolds$p1Of$p2(Integer p1, String p2, BiConsumer<Integer, String>... composite) {
    if (composite.length > 0) {
        stream(composite).forEach(action -> action.accept(p1, p2));
    } else {
        Assertions.fail("Step is not yet implemented");
    }
}

public abstract void searchTheCatalogueFor$p1(String p1);

public abstract void add$p1OfTheFirstResultToTheCart(Integer p1);

@Test
@DisplayName("Scenario: Buying one product")
public void scenario_1() {
    /*
     * Given the cart holds "2" of "Notebook"
     */
    theCartHolds$p1Of$p2(2, "Notebook", (p1, p2) -> {
        /*
         * * search the catalogue for "<$p2>"
         */
        searchTheCatalogueFor$p1(p2);
        /*
         * * add "<$p1>" of the first result to the cart
         */
        add$p1OfTheFirstResultToTheCart(p1);
    });
    // ...
}
```

A reference names one of the composite step's values, and the sub-step's method receives it:

| Reference in a sub-step | Passes on | Generated argument |
|---|---|---|
| `"<$p1>"` … `"<$p5>"` | the composite step's first to fifth quoted value | `p1`, `p2`, … |
| `"<$product[1]>"` | the `product` cell of the composite step's first data table row | `dataTable.get(0).product()` |
| `"<$dataTable>"` at the end of the text | the composite step's whole data table | `dataTable` |
| `"<$docString>"` at the end of the text | the composite step's doc string | `docString` |

The value keeps the type it has on the composite step: `"2"` reaches `add "<$p1>" of the first result to the cart`
as an `Integer`. A data table passed on with `"<$dataTable>"` is built with the row type of the sub-step taking it, so
`the cart holds these products:` and `add the products to the cart: "<$dataTable>"` share `CartParam`.

## Overriding a composite method

The generated composite method only runs the sub-steps. It is `protected`, so the test class can take it over —
`CheckoutTest` overrides the one for "the customer checks out" to check the checkout as a whole:

```java
@Override
protected void theCustomerChecksOut(Runnable... composite) {
    super.theCustomerChecksOut(composite);
    assertNotNull(order, "Checking out should place an order");
}
```

## The marker class

```java
@Gherkin2JUnit
@Gherkin2JUnitOptions(enableCompositeSteps = true)
@ExtendWith(SpecBinderReporter.class)
public abstract class CheckoutFeature {
}
```

The bare `@Gherkin2JUnit` discovers the co-located `Checkout.specb` by convention. Without `enableCompositeSteps`,
the `*` steps would be ordinary steps of their own, run after the step above them.

## Class hierarchy

```
CheckoutFeature.java          (marker, @Gherkin2JUnit + enableCompositeSteps = true + the reporter)
  └→ CheckoutScenarios.java   (generated, abstract — composite methods run their sub-steps)
      └→ CheckoutTest.java    (your concrete class, implements the steps and sub-steps — the class JUnit runs)
```

## Files

| File | Purpose |
|------|---------|
| `src/test/java/.../Checkout.specb` | The spec, with composite steps in its Background, Scenarios and Scenario Outline |
| `src/test/java/.../CheckoutFeature.java` | Marker class turning on composite steps and the execution reporter |
| `src/test/java/.../CheckoutTest.java` | Concrete test implementing the steps and sub-steps, and overriding one composite method |
| `src/main/java/.../Shop.java` | Tiny in-memory web shop; most actions need a particular page to be open, so sub-steps only work in the order the spec lists them |
| `pom.xml` | Execution reporter dependency; enables test execution |

## Run it

With Java 21 or newer and the local SpecBinder snapshot installed:

```bash
cd examples/going-further/example-11
mvn test
```

All **5 scenario executions should pass** — three Scenarios and the Scenario Outline's two rows. A failure fails the
build. The generated class is in `target/generated-test-sources/test-annotations/`.

## Execution report

The run writes `target/specbinder-reports/dev/specbinder/examples/goingfurther/compositesteps/CheckoutTest.json`. A
composite step is one entry in `steps[]`, and its sub-steps sit in its `subSteps[]`, each with its own spec line,
the values it ran with, a status and timing:

```json
{
  "methodName" : "theCartHolds$p1Of$p2",
  "text" : "Given the cart holds \"2\" of \"Notebook\"",
  "arguments" : [ { "type" : "simple", "value" : 2 }, { "type" : "simple", "value" : "Notebook" } ],
  "status" : "passed",
  "subSteps" : [ {
    "methodName" : "searchTheCatalogueFor$p1",
    "text" : "* search the catalogue for \"<$p2>\"",
    "arguments" : [ { "type" : "simple", "value" : "Notebook" } ],
    "status" : "passed"
  }, {
    "methodName" : "add$p1OfTheFirstResultToTheCart",
    "text" : "* add \"<$p1>\" of the first result to the cart",
    "arguments" : [ { "type" : "simple", "value" : 2 } ],
    "status" : "passed"
  } ]
}
```

When a sub-step fails, the error sits on that sub-step, its composite step fails, and the sub-steps and steps after it
are reported as skipped.
