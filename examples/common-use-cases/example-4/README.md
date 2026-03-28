# Example 4: Abstract Mode (`shouldBeAbstract = true`)

Demonstrates abstract mode where the generated class declares abstract step methods, and you create a concrete subclass to implement them. Missing implementations cause **compilation errors**.

## What this demonstrates

- `@Gherkin2JUnitOptions(shouldBeAbstract = true)` generates an abstract class
- Generated class suffix changes from `Test` to `Scenarios` (configurable)
- All step methods are declared `abstract` — no failing stubs
- You create a concrete test class extending the generated abstract class
- Missing `@Override` methods cause a **compiler error**, not a runtime failure
- Three-layer hierarchy: marker → generated abstract → concrete test

## Class hierarchy

```
ShoppingCartFeature.java          (marker class, @Gherkin2JUnit)
  └→ ShoppingCartScenarios.java   (generated, abstract, contains @Test methods)
      └→ ShoppingCartTest.java    (your concrete class, implements step methods)
```

## Concrete vs Abstract mode comparison

| Aspect | Concrete (default) | Abstract                                      |
|--------|-------------------|-----------------------------------------------|
| Generated class | Concrete, extends marker | Abstract, extends marker                      |
| New step methods | Failing stubs (`Assertions.fail(...)`) | `abstract` declarations                       |
| Inherited step methods | Not generated (inherited from marker) | Not generated (inherited from marker)         |
| Missing steps | Runtime failure | **Compilation error**                         |
| Where you implement | In the marker class | In the marker class, or the concrete subclass |
| Class suffix | `Test` | `Scenarios`                                   |

**Key point:** In both modes, step methods already present in the marker class are inherited — the generator does not emit stubs or abstract declarations for them. The difference is only in how *new* (unimplemented) steps are handled.

## Inherited vs abstract step methods in this example

In `ShoppingCartFeature.java` (marker class):
- `myCartSubtotalIs$p1()` — implemented here, **inherited** by the generated class
- `iViewTheCart()` — implemented here, **inherited** by the generated class

In `ShoppingCartScenarios.java` (generated abstract class):
- `iHaveAnEmptyShoppingCart()` — **abstract**, must be implemented in `ShoppingCartTest`
- `iAdd$p1WithQuantity$p2AndUnitPrice$p3()` — **abstract**
- `theCartShouldContain$p1Item()` — **abstract**
- `theCartSubtotalShouldBe$p1()` — **abstract**
- `iShouldSeeThe$p1Banner()` — **abstract**

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/ShoppingCart.feature` | Feature with scenarios and a rule |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class with `@Gherkin2JUnitOptions(shouldBeAbstract = true)` and two inherited step methods |
| `src/test/java/.../ShoppingCartTest.java` | Concrete test class implementing only the abstract step methods |
