# Example 6: Glob Pattern Discovery (Multiple Features)

Demonstrates using a glob pattern in `@Gherkin2JUnit` to discover and process multiple spec files from a single marker class — one generated test class per discovered spec, even across sub-packages.

## What this demonstrates

- `@Gherkin2JUnit("./**/*.specb")` matches all `.specb` files in the marker's package and every sub-package below it
- `./` resolves against the marker's package, so the pattern doesn't repeat the package name
- One marker class generates **separate test classes** for each discovered spec file
- All generated classes extend the same marker class
- Each generated class lands in its **spec's own package** (`glob.cart`, `glob.user`), next to the spec and its test
- Glob versus bare `@Gherkin2JUnit`: a bare annotation only looks in the marker's own package — the recursive `**` is
  what reaches `cart/` and `user/`

## Directory layout

```
src/test/java/.../glob/
  ├── AllFeatures.java              ← single marker class with the glob pattern
  ├── cart/
  │   ├── AddToCart.specb
  │   ├── AddToCartTest.java
  │   ├── Checkout.specb
  │   └── CheckoutTest.java
  └── user/
      ├── Login.specb
      ├── LoginTest.java
      ├── Registration.specb
      └── RegistrationTest.java
```

The specs are co-located with the Java code, so the module relies on the `testResources` configuration inherited from
the `common-use-cases` parent POM (see getting-started example-8).

## Generated output

The processor discovers 4 spec files and generates 4 abstract test classes, all extending `AllFeatures`:

```
AllFeatures.java
  ├→ cart/AddToCartScenarios.java      (from cart/AddToCart.specb)
  │     └→ cart/AddToCartTest.java     (concrete)
  ├→ cart/CheckoutScenarios.java       (from cart/Checkout.specb)
  │     └→ cart/CheckoutTest.java      (concrete)
  ├→ user/LoginScenarios.java          (from user/Login.specb)
  │     └→ user/LoginTest.java         (concrete)
  └→ user/RegistrationScenarios.java   (from user/Registration.specb)
        └→ user/RegistrationTest.java  (concrete)
```

## The marker class

The marker only needs the glob pattern — it carries no step wiring of its own:

```java
@Gherkin2JUnit("./**/*.specb")
public abstract class AllFeatures {
}
```

Each spec gets its own concrete test class next to it, implementing that spec's steps. Some steps appear in more than
one spec — `I have an empty shopping cart`, `I should see "…"` — and each generated class declares them separately, so
each test implements its own copy. To share them instead, see **Sharing Steps via a Base Class** (example-3) or
**Organizing Steps into Interfaces** (`going-further/example-3`).

## Files

| File | Purpose |
|------|---------|
| `src/test/java/.../glob/AllFeatures.java` | Marker class with the glob pattern |
| `src/test/java/.../glob/cart/*.specb` | Cart and checkout spec files |
| `src/test/java/.../glob/cart/*Test.java` | Concrete tests for the cart and checkout specs |
| `src/test/java/.../glob/user/*.specb` | Login and registration spec files |
| `src/test/java/.../glob/user/*Test.java` | Concrete tests for the login and registration specs |

## Run it

```bash
cd examples/common-use-cases/example-6
mvn test
```
