# Example 4: Type Refinement with Enums

Demonstrates how to refine generated `String` types to enum types — both data table Param fields and quoted step parameters — catching invalid values at **compile time** instead of runtime.

## What this demonstrates

- Move the generated `ProductsParam` class **and the abstract step methods that deal with categories** into the marker
  class
- Change the `category` field from `String` to a `Category` enum
- Change the quoted category parameter of `iFilterByCategory$p1` from `String` to the same `Category` enum
- The generator detects the existing class and step declarations and uses them instead of generating its own
- Invalid enum values in the feature file cause **compiler errors**
- Compile-time safety for data table and step parameter values — a key SpecBinder differentiator
- The marker holds the refined types and the step declarations that use them; every step implementation lives in the
  concrete `ShoppingCartTest`, where `product.category()` is already a `Category` enum

## How it works

### Step 1: Generator produces initial code

On first compilation, the generator creates `ProductsParam` with all `String`/inferred types, together with the
abstract step methods — including the one taking the category in quotes (`When I filter by category "electronics"`):

```java
// Generated (before refinement)
public abstract void myCartContainsTheFollowingProducts(List<ProductsParam> products);

public abstract void iFilterByCategory$p1(String p1);  // ← String by default

public static class ProductsParam {
    private final String name;
    private final Integer qty;
    private final Double unitPrice;
    private final String category;  // ← String by default
    // ...
}
```

### Step 2: Refine in marker class

Move `ProductsParam` and the step declarations that deal with categories into your marker class, then change both the
`category` field and the filter step's parameter to an enum. Keeping them together makes it clear that the refined type
and the steps using it are now yours rather than generated:

```java
@Gherkin2JUnit
public abstract class ShoppingCartFeature {

    public enum Category { electronics, grocery, sports }

    public static class ProductsParam {
        // ...
        private final Category category;  // ← now an enum
        // ...
    }

    public abstract void myCartContainsTheFollowingProducts(List<ProductsParam> products);

    public abstract void iFilterByCategory$p1(Category category);  // ← now an enum
}
```

The steps stay abstract — the concrete `ShoppingCartTest` implements them like any other step, and receives a
`Category` directly instead of parsing a `String`. (If an implementation is shared by several features, it could live in
the marker instead.)

### Step 3: Compile-time safety

The generator now uses your `ProductsParam` and step declarations from the marker class — it no longer emits any of
them. The generated call sites pass enum constants, statically imported from `Category`, for the table cells and the
quoted value alike:

```java
new ProductsParam("Wireless Headphones", 1, 59.99, electronics)
new ProductsParam("Coffee Beans 1kg", 3, 12.50, grocery)

iFilterByCategory$p1(electronics);
```

### Step 4: Invalid values caught at compile time

If someone adds a row with an unknown category:

```gherkin
| Yoga Mat | 1 | 25.00 | fitness |
```

or filters by one:

```gherkin
When I filter by category "fitness"
```

The generated code refers to `fitness`, which `Category` has no constant for — **compilation error!** The mismatch is caught before tests ever run.

## Files

| File | Purpose |
|------|---------|
| `src/test/java/.../ShoppingCart.specb` | Feature with categorized products in data tables |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class with bare `@Gherkin2JUnit`, the `Category` enum, the refined `ProductsParam` class and the step declarations that use `Category` |
| `src/test/java/.../ShoppingCartTest.java` | Concrete subclass implementing the step methods with assertions |

## Class hierarchy

```
ShoppingCartFeature.java          (marker class, @Gherkin2JUnit)
  └→ ShoppingCartScenarios.java   (generated, abstract, reuses the marker's ProductsParam and step declarations)
      └→ ShoppingCartTest.java    (your concrete class, implements step methods)
```
