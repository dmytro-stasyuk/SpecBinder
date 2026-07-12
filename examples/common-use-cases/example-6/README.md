# Example 6: Glob Pattern Discovery (Multiple Features)

Demonstrates using a glob pattern in `@Gherkin2JUnit` to discover and process multiple feature files from a single marker class — one generated test class per discovered feature.

## What this demonstrates

- `@Gherkin2JUnit("specs/**/*.specb")` matches all `.specb` files recursively
- One marker class generates **separate test classes** for each discovered feature file
- All generated classes extend the same marker class
- Hierarchical feature file organization (`specs/cart/`, `specs/user/`) is preserved

## Directory layout

```
src/test/resources/
  └── specs/
      ├── cart/
      │   ├── AddToCart.specb
      │   └── Checkout.specb
      └── user/
          ├── Login.specb
          └── Registration.specb

src/test/java/.../glob/
  └── AllFeatures.java   ← single marker class with the glob pattern
```

## Generated output

The processor discovers 4 feature files and generates 4 abstract test classes, all extending `AllFeatures`:

```
AllFeatures.java
  ├→ AddToCartScenarios.java      (from specs/cart/AddToCart.specb)
  ├→ CheckoutScenarios.java       (from specs/cart/Checkout.specb)
  ├→ LoginScenarios.java          (from specs/user/Login.specb)
  └→ RegistrationScenarios.java   (from specs/user/Registration.specb)
```

## The marker class

The marker only needs the glob pattern — it carries no step wiring of its own:

```java
@Gherkin2JUnit("specs/**/*.specb")
public abstract class AllFeatures {
}
```

Step methods are implemented as usual — directly on the marker, in a concrete subclass, or organized into interfaces. For sharing a set of step interfaces across many discovered features, see the **Organizing Steps into Interfaces** example (`going-further/example-3`).

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/cart/*.specb` | Cart and checkout feature files |
| `src/test/resources/specs/user/*.specb` | Login and registration feature files |
| `src/test/java/.../AllFeatures.java` | Marker class with the glob pattern |

## Run it

```bash
cd examples/common-use-cases/example-6
mvn test
```
