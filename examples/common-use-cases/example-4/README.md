# Example 4: Data Table Type Refinement with Enums

Demonstrates how to refine generated `String` fields to enum types in data table Param classes, catching invalid values at **compile time** instead of runtime.

## What this demonstrates

- Move the generated `ProductsParam` class into the marker class
- Change the `category` field from `String` to a `Category` enum
- The generator detects the existing class and uses it instead of generating a new one
- Invalid enum values in the feature file cause **compiler errors**
- Compile-time safety for data table values — a key Spec Binder differentiator

## How it works

### Step 1: Generator produces initial code

On first compilation, the generator creates `ProductsParam` with all `String`/inferred types:

```java
// Generated (before refinement)
public static class ProductsParam {
    private final String name;
    private final Integer qty;
    private final Double unitPrice;
    private final String category;  // ← String by default
    // ...
}
```

### Step 2: Refine in marker class

Move `ProductsParam` into your marker class and change `category` to an enum:

```java
public enum Category { electronics, grocery, sports }

public static class ProductsParam {
    // ...
    private final Category category;  // ← now an enum
    // ...
}
```

### Step 3: Compile-time safety

The generator now uses your `ProductsParam` from the marker class. The generated call site uses enum constants:

```java
new ProductsParam("Wireless Headphones", 1, 59.99, Category.electronics)
new ProductsParam("Coffee Beans 1kg", 3, 12.50, Category.grocery)
```

### Step 4: Invalid values caught at compile time

If someone adds a row with an unknown category:

```gherkin
| Yoga Mat | 1 | 25.00 | fitness |
```

The generated code tries `Category.fitness` — **compilation error!** The mismatch is caught before tests ever run.

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/ShoppingCart.specb` | Feature with categorized products in data tables |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class with `Category` enum and refined `ProductsParam` class |
