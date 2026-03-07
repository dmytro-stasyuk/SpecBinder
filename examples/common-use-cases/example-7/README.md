# Example 7: Glob Pattern Discovery (Multiple Features)

Demonstrates using a glob pattern in `@Feature2JUnit` to discover and process multiple feature files from a single marker class, with step methods organized into interfaces by domain.

## What this demonstrates

- `@Feature2JUnit("specs/**/*.feature")` matches all `.feature` files recursively
- One marker class generates **separate test classes** for each discovered feature file
- All generated classes extend the same marker class
- Step methods organized into interfaces (`CartSteps`, `LoginSteps`, etc.)
- Marker class implements all step interfaces — shared steps are inherited by all generated classes
- Hierarchical feature file organization (`specs/cart/`, `specs/user/`)

## Directory layout

```
src/test/resources/
  └── specs/
      ├── cart/
      │   ├── AddToCart.feature
      │   └── Checkout.feature
      └── user/
          ├── Login.feature
          └── Registration.feature

src/test/java/.../glob/
  ├── AllFeatures.java           ← single marker class with glob pattern
  └── steps/
      ├── CartSteps.java         ← interface with cart step methods
      ├── CheckoutSteps.java     ← interface with checkout step methods
      ├── LoginSteps.java        ← interface with login step methods
      └── RegistrationSteps.java ← interface with registration step methods
```

## Generated output

The processor discovers 4 feature files and generates 4 test classes, all extending `AllFeatures`:

```
AllFeatures.java
  ├→ AddToCartTest.java      (generated from specs/cart/AddToCart.feature)
  ├→ CheckoutTest.java       (generated from specs/cart/Checkout.feature)
  ├→ LoginTest.java          (generated from specs/user/Login.feature)
  └→ RegistrationTest.java   (generated from specs/user/Registration.feature)
```

## Step interface pattern

Organize step methods by domain area using Java interfaces with `default` methods:

```java
public interface CartSteps {
    default void iHaveAnEmptyShoppingCart() { /* ... */ }
    default void iAdd$p1ToTheCart(String item) { /* ... */ }
}
```

The marker class implements all interfaces:

```java
@Feature2JUnit("specs/**/*.feature")
public abstract class AllFeatures implements CartSteps, CheckoutSteps, LoginSteps, RegistrationSteps {
}
```

## Files

| File | Purpose |
|------|---------|
| `src/test/resources/specs/cart/*.feature` | Cart and checkout feature files |
| `src/test/resources/specs/user/*.feature` | Login and registration feature files |
| `src/test/java/.../AllFeatures.java` | Marker class with glob pattern, implements step interfaces |
| `src/test/java/.../steps/*.java` | Step method interfaces organized by domain |
