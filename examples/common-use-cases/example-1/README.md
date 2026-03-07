# Example 1: Data Tables (LIST_OF_OBJECT_PARAMS)

Demonstrates the default data table mode where Gherkin data tables generate type-safe inner classes with typed accessors — no Cucumber dependency required.

## What this demonstrates

- Data tables generate inner `Param` classes (named after the last word of the step text + `Param`)
- Column headers become typed fields with automatic type inference
- Type inference per column: `Integer`, `Double`, `Boolean`, `String`, etc.
- Readable column headers (e.g. `unit price`) are sanitized to Java field names (`unitPrice`)
- Rows become `new ParamType(...)` calls inside `List.of(...)`
- Multiple data tables in the same feature produce separate inner classes

## Generated inner class example

For the step `Given my cart contains the following products:`, the generator produces:

```java
public static class ProductsParam {
    private final String name;
    private final Integer qty;
    private final Double unitPrice;
    private final Boolean inStock;

    public ProductsParam(String name, Integer qty, Double unitPrice, Boolean inStock) {
        this.name = name;
        this.qty = qty;
        this.unitPrice = unitPrice;
        this.inStock = inStock;
    }

    public String name()       { return this.name; }
    public Integer qty()       { return this.qty; }
    public Double unitPrice()  { return this.unitPrice; }
    public Boolean inStock()   { return this.inStock; }
}
```

## Generated step method and call site

```java
// Step method signature
public void myCartContainsTheFollowingProducts(List<ProductsParam> products) {
    Assertions.fail("Step is not yet implemented");
}

// Call site in @BeforeEach
myCartContainsTheFollowingProducts(
        List.of(
                new ProductsParam("Wireless Headphones", 1, 59.99, true),
                new ProductsParam("Coffee Beans 1kg", 3, 12.50, true),
                new ProductsParam("USB-C Cable", 2, 8.99, false)
        ));
```

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/ShoppingCart.feature` | Feature with multiple data tables of varying shapes |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class annotated with `@Feature2JUnit` |

## Key points

- Each unique data table shape generates its own `Param` class
- The class name is derived from the last word before the colon in the step text
- Fields use accessor methods (not `getX()`) for a record-like API
- No Cucumber dependency — pure Java classes
