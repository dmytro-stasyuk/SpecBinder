# Example 2: Data Tables with Cucumber DataTable Integration

Demonstrates the `CUCUMBER_DATA_TABLE` mode where Gherkin data tables are passed as Cucumber `DataTable` objects, giving access to the full Cucumber DataTable API for type conversions and POJO mapping.

## What this demonstrates

- `@Feature2JUnitOptions(dataTableParameterType = CUCUMBER_DATA_TABLE)` changes data table handling
- Step methods receive `DataTable` instead of `List<Param>`
- The generator creates a `createDataTable()` helper that parses text blocks into `DataTable` objects
- You must provide a `getTableConverter()` method in your class hierarchy
- Full access to Cucumber's `DataTable` API: `asList()`, `asMap()`, `asMaps()`, POJO mapping
- Requires `cucumber-java` dependency

## Comparison with default mode

| Aspect | LIST_OF_OBJECT_PARAMS (default) | CUCUMBER_DATA_TABLE |
|--------|--------------------------------|---------------------|
| Parameter type | `List<GeneratedParam>` | `DataTable` |
| Type safety | Compile-time (typed fields) | Runtime (string-based) |
| POJO mapping | Automatic (generated classes) | Manual (DataTableTypeRegistry) |
| Dependencies | None | `cucumber-java` |
| Best for | New projects, compile-time safety | Cucumber migration, complex conversions |

## Generated code

```java
// Generated helper method (if not already in base class)
protected DataTable createDataTable(String tableLines) {
    // parses pipe-delimited text block into DataTable
    // using getTableConverter()
}

// Generated call site
myCartContainsTheFollowingProducts(createDataTable("""
        |name               |qty|unit price|
        |Wireless Headphones|1  |59.99     |
        |Coffee Beans 1kg   |3  |12.50     |
        """));
```

## POJO mapping with DataTableTypeRegistry

```java
registry.defineDataTableType(new DataTableType(
        Product.class,
        (Map<String, String> row) -> new Product(
                row.get("name"),
                Integer.parseInt(row.get("qty")),
                Double.parseDouble(row.get("unit price"))
        )
));

// Then in step method:
List<Product> products = dataTable.asList(Product.class);
```

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/ShoppingCart.feature` | Feature with data tables |
| `src/test/java/.../BaseFeature.java` | Base class with `@Feature2JUnitOptions(dataTableParameterType = CUCUMBER_DATA_TABLE)` |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class with `getTableConverter()`, POJO type registration, and step implementations |
| `pom.xml` | Includes `cucumber-java` dependency |
