# Example 1: Concrete Mode (`shouldBeAbstract = false`)

Demonstrates concrete mode, the opt-out from the default. The generated class is **concrete and directly runnable** — no hand-written subclass — and unimplemented steps become failing stubs at **run time** instead of compile errors.

> The default is **abstract mode**, shown in the getting-started examples: an abstract `Scenarios` class with one abstract method per step, enforced at compile time.

## What this demonstrates

- `@Gherkin2JUnitOptions(shouldBeAbstract = false)` generates a concrete class
- Generated class uses the `Test` suffix instead of `Scenarios` (configurable)
- No subclass required — the generated class runs on its own
- Step methods are implemented directly in the marker class and inherited by the generated class
- Unimplemented steps become failing stubs (`Assertions.fail(...)`) — a **runtime failure**, not a compile error

## Class hierarchy

Concrete mode collapses abstract mode's three layers into two — there is no hand-written subclass:

```
ShoppingCartFeature.java    (marker class, @Gherkin2JUnit + shouldBeAbstract = false, implements steps)
  └→ ShoppingCartTest.java  (generated, concrete, runnable — inherits your implementations)
```

## Abstract vs concrete mode comparison

| Aspect | Abstract (default) | Concrete                                 |
|--------|--------------------|------------------------------------------|
| Generated class | Abstract, extends marker | Concrete, extends marker           |
| New step methods | `abstract` declarations | Failing stubs (`Assertions.fail(...)`) |
| Inherited step methods | Not generated (inherited from marker) | Not generated (inherited from marker) |
| Missing steps | **Compilation error** | Runtime failure                     |
| Subclass required to run | Yes | No                                    |
| Where you implement | In the marker class, or a concrete subclass | In the marker class      |
| Class suffix | `Scenarios` | `Test`                                        |
| Opt in via | (default) | `@Gherkin2JUnitOptions(shouldBeAbstract = false)` |

**Key point:** In both modes, step methods already present in the marker class are inherited — the generator emits neither a stub nor an abstract declaration for them. The difference is only in how *new* (unimplemented) steps are handled, and whether a subclass is needed to run the tests.

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/ShoppingCart.specb` | Feature with a scenario and a rule |
| `src/test/java/.../ShoppingCartFeature.java` | Marker class with `@Gherkin2JUnitOptions(shouldBeAbstract = false)` and all step methods implemented |

## Run it

```bash
cd examples/going-further/example-1
mvn test
```
