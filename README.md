<img src="logo.png" alt="SpecBinder logo" width="80" align="left"/>

# Spec Binder

**Spec Binder** turns natural-language Gherkin specs into **pure JUnit** test code at **compile time**.
No runtime step discovery, no Cucumber runner. Your `.feature` / `.specb` files become first-class Java code that compiles and runs like any other JUnit test.

> Built around an annotation-processor approach that parses gherkin spec files during `javac`, generating JUnit test
> skeletons where each **Given/When/Then** is converted into a strongly-named Java method call.

---

## Why Spec Binder?

### 1. Compile-time safety

Eliminates “undefined step” surprises at runtime — mismatches surface as **compiler errors**. Type-inferred parameters
mean the compiler catches issues like providing a String where a number is expected, or referencing an enum value that
doesn't exist — all before tests execute.

### 2. Plain JUnit 5 (no Cucumber runner)

Generated tests are ordinary JUnit 5 test classes, making execution straightforward in IDEs and CI. Run or debug
individual Scenarios and Rules easily, set breakpoints directly inside the generated scenario test methods and use Find
Usages like with any other test. Stack traces point straight to the failing assertion in your code — no indirection
through a framework runner.

### 3. Feature-scoped step methods

Each feature’s step methods are scoped to its own class hierarchy through standard Java inheritance and method
overriding — no global step catalog, no classpath scanning. This provides isolation: you focus on a set of step methods
for one feature (or a small group of features) without worrying about impacting other features elsewhere — all supported
through standard Java language features.

### 4. Simple state management

Sharing state between steps is just instance fields on your test class — no DI framework (PicoContainer, Spring, Guice)
required. No “scenario context” god objects that grow without bound. Standard Java patterns apply because steps are
regular methods on a regular class.

### 5. Type-safe data tables

Pipe delimited gherkin data table rows are automatically mapped to generated Java record-like classes with type-inferred fields — no manual
`Map<String, String>` parsing, no custom converters. Column headers become strongly-typed accessors, so you work with
`item.name()` and `item.quantity()` instead of `row.get("name")`. This eliminates the repetitive boilerplate of mapping
string-based table data to domain objects, while the compiler catches mismatched columns or wrong types before tests
ever run.

### 6. TDD-friendly

Enables straightforward, **iterative** test‑first development—before any application or even test code exists. Start
with an abstract, implementation‑free spec (e.g., only Rule and/or Scenario titles). The generator creates a failing
JUnit method for each empty Rule/Scenario, so you immediately have red tests to drive development.

* **Iterate:** list Rules → add Scenario titles under the first Rule → pick one Scenario and add concrete steps in the
  Gherkin feature (still red; the generator turns them into failing step methods in the test) → implement those step
  methods → then implement just enough application code to make it pass (green) → repeat for the next Scenario. When all
  Scenarios under a Rule are green, move on to the next Rule.
* **Keep discovering:** As implementation reveals new cases, jot them down as additional `Rule` or `Scenario` titles;
  they immediately appear as failing tests, ready for red→green.

---

## How it works (at a glance)

1. Create a **marker class** annotated with `@Gherkin2JUnit("relative/path/to.feature")` — this points the annotation
   processor at the feature. The path is optional: a bare `@Gherkin2JUnit` (no value) uses **convention-based discovery**, processing all `.feature` and `.specb` files found in the same package as the annotated class.
2. During compilation, the annotation processor parses the gherkin spec file and generates:

    * A **JUnit test class** (one per feature).
    * For each Scenario, a `@Test` method that calls **per-step methods** derived from step text.
    * Parts of step's text that are wrapped in double quotes become step method
      arguments. [Doc Strings](https://cucumber.io/docs/gherkin/reference/#doc-strings)
      and [Data Tables](https://cucumber.io/docs/gherkin/reference/#data-tables) are also supported.
    * Gherkin `Rule` elements are generated as nested test classes, and `Rule` and `Scenario` titles populate JUnit's
      `@DisplayName` annotations.

   The generated class operates in one of two modes:

   **Abstract mode (default):**
    * The generated class is **abstract** (named `<Name>Scenarios` by default) and extends the marker class.
    * Each step method is declared as `abstract` — missing implementations become **compile errors**.
    * You create a **concrete subclass** that extends the generated class and overrides every abstract step method with a real implementation. That concrete subclass is what JUnit runs.
    * Step methods can optionally be placed on the marker class itself (or any class up the hierarchy). The generator detects them and **does not emit an abstract declaration** for those steps — the concrete subclass inherits them and only needs to implement the rest.

   **Concrete mode** (`@Gherkin2JUnitOptions(shouldBeAbstract = false)`):
    * The generated class is **concrete** (named `<Name>Test` by default) and extends the marker class.
    * Each step method contains an `Assertions.fail("Step is not yet implemented")` stub, so the generated class is immediately runnable.
    * You implement the step methods **in the marker class**. On the next build, the generator detects these methods in the parent class and **stops generating stubs** for them — the generated test class simply inherits and calls your implementations.

---

## Usage example

1. **Create or place** a `.feature` or `.specb` file under your chosen directory (e.g., `src/test/resources/specs/...`).

**Example** (`specs/cart.feature`):

```gherkin
Feature: Online shopping cart

  Scenario: Update quantity updates subtotal
    Given my cart contains "Wireless Headphones" with quantity "1" and unit price "60.00"
    When I change the quantity to "2"
    Then my cart subtotal is "120.00"

  Rule: Free shipping applies to orders over €50

    Scenario: Show free-shipping banner when threshold is met
      Given my cart subtotal is "55.00"
      When I view the cart
      Then I see the "Free shipping" banner
```

2. **Add a marker class** annotated with `@Gherkin2JUnit("specs/cart.feature")`.

```java
package org.mycompany.app;

import dev.specbinder.processor.Gherkin2JUnit;

@Gherkin2JUnit("specs/cart.feature")
public abstract class CartFeature {
    // Marker class: no members required
}
```

3. **Compile** the marker class. The generator writes JUnit sources under your build's generated-sources dir.

**Generated class** (default *abstract* mode):

```java
package org.mycompany.app;

import dev.specbinder.annotations.output.SourceFilePath;

import java.lang.String;
import javax.annotation.processing.Generated;

import org.junit.jupiter.api.ClassOrderer;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestClassOrder;
import org.junit.jupiter.api.TestMethodOrder;

/**
 * Feature: online shopping cart
 */
@Generated("dev.specbinder.processor.AnnotationProcessor")
@DisplayName("cart")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@TestClassOrder(ClassOrderer.OrderAnnotation.class)
@SourceFilePath("specs/cart.feature")
public abstract class CartScenarios extends CartFeature {

    public abstract void myCartContains$p1WithQuantity$p2AndUnitPrice$p3(String p1, Integer p2, Double p3);

    public abstract void iChangeTheQuantityTo$p1(Integer p1);

    public abstract void myCartSubtotalIs$p1(Double p1);

    public abstract void iViewTheCart();

    public abstract void iSeeThe$p1Banner(String p1);

    @Test
    @Order(1)
    @DisplayName("Scenario: update quantity updates subtotal")
    public void scenario_1() {
        /*
         * Given my cart contains "Wireless Headphones" with quantity "1" and unit price "60.00"
         */
        myCartContains$p1WithQuantity$p2AndUnitPrice$p3("Wireless Headphones", 1, 60.00);
        /*
         * When I change the quantity to "2"
         */
        iChangeTheQuantityTo$p1(2);
        /*
         * Then my cart subtotal is "120.00"
         */
        myCartSubtotalIs$p1(120.00);
    }

    @Nested
    @Order(1)
    @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
    @DisplayName("Rule: free shipping applies to orders over €50")
    public class Rule_1 {
        @Test
        @Order(1)
        @DisplayName("Scenario: show free-shipping banner when threshold is met")
        public void scenario_1() {
            /*
             * Given my cart subtotal is "55.00"
             */
            myCartSubtotalIs$p1(55.00);
            /*
             * When I view the cart
             */
            iViewTheCart();
            /*
             * Then I see the "Free shipping" banner
             */
            iSeeThe$p1Banner("Free shipping");
        }
    }
}
```

4. **Implement the step methods** by creating a concrete subclass of the generated abstract class — see [How it works](#how-it-works-at-a-glance) above for details on abstract vs concrete mode.

**Your concrete test class:**

```java
package org.mycompany.app;

public class CartTest extends CartScenarios {

    @Override
    public void myCartContains$p1WithQuantity$p2AndUnitPrice$p3(String itemName, Integer quantity, Double unitPrice) {
        /* real implementation here */
    }

    @Override
    public void iChangeTheQuantityTo$p1(Integer newQuantity) {
        /* real implementation here */
    }

    @Override
    public void myCartSubtotalIs$p1(Double expectedSubtotal) {
        /* real implementation here */
    }

    @Override
    public void iViewTheCart() {
        /* real implementation here */
    }

    @Override
    public void iSeeThe$p1Banner(String bannerText) {
        /* real implementation here */
    }
}
```

JUnit discovers and runs `CartTest`. If any step method is left unimplemented, the project simply will not compile.

> You can also place step implementations directly on the marker class `CartFeature` — the generator detects them in the class hierarchy and omits the matching abstract declarations from `CartScenarios`, so the concrete subclass only needs to override what's still missing.

---

## Examples

The [`examples/`](examples/) directory contains ready-to-run Maven modules organized in two tracks:

<table>
<tr><td colspan="2"><code>examples/</code></td></tr>
<tr><td colspan="2">├── <code>getting-started/</code> — <em>Fundamentals, one concept at a time</em></td></tr>
<tr><td>│ &ensp; ├── <a href="examples/getting-started/example-1/README.md">Hello World</a></td><td>Simplest possible feature</td></tr>
<tr><td>│ &ensp; ├── <a href="examples/getting-started/example-2/README.md">Step Parameters</a></td><td>Type inference (String, Integer, Double, Boolean, Character)</td></tr>
<tr><td>│ &ensp; ├── <a href="examples/getting-started/example-3/README.md">Concrete Mode E2E</a></td><td>Implementing step methods with real logic</td></tr>
<tr><td>│ &ensp; ├── <a href="examples/getting-started/example-4/README.md">Rules</a></td><td>Nested scenarios with Rule blocks</td></tr>
<tr><td>│ &ensp; ├── <a href="examples/getting-started/example-5/README.md">Background</a></td><td>Feature-level and rule-level backgrounds</td></tr>
<tr><td>│ &ensp; ├── <a href="examples/getting-started/example-6/README.md">Scenario Outline</a></td><td>Parameterized tests with Examples tables</td></tr>
<tr><td>│ &ensp; └── <a href="examples/getting-started/example-7/README.md">Tags</a></td><td>@Tag annotations and test filtering</td></tr>
<tr><td>│</td><td></td></tr>
<tr><td colspan="2">└── <code>common-use-cases/</code> — <em>Real-world patterns and advanced features</em></td></tr>
<tr><td>&ensp; &ensp; ├── <a href="examples/common-use-cases/example-1/README.md">Data Tables</a></td><td>LIST_OF_OBJECT_PARAMS (default mode)</td></tr>
<tr><td>&ensp; &ensp; ├── <a href="examples/common-use-cases/example-2/README.md">Cucumber DataTable</a></td><td>CUCUMBER_DATA_TABLE integration</td></tr>
<tr><td>&ensp; &ensp; ├── <a href="examples/common-use-cases/example-3/README.md">TDD Workflow</a></td><td>Iterative red-green development with @new tags</td></tr>
<tr><td>&ensp; &ensp; ├── <a href="examples/common-use-cases/example-4/README.md">Abstract Mode</a></td><td>Compile-time step enforcement</td></tr>
<tr><td>&ensp; &ensp; ├── <a href="examples/common-use-cases/example-5/README.md">DocStrings</a></td><td>Multi-line input (JSON, plain text)</td></tr>
<tr><td>&ensp; &ensp; ├── <a href="examples/common-use-cases/example-6/README.md">Convention Discovery</a></td><td>Co-located .feature / .specb files, bare @Gherkin2JUnit</td></tr>
<tr><td>&ensp; &ensp; ├── <a href="examples/common-use-cases/example-7/README.md">Glob Patterns</a></td><td>Multiple features from a single marker class</td></tr>
<tr><td>&ensp; &ensp; ├── <a href="examples/common-use-cases/example-8/README.md">Type Refinement</a></td><td>Enum refinement of generated Param classes</td></tr>
<tr><td>&ensp; &ensp; ├── <a href="examples/common-use-cases/example-9/README.md">Config Inheritance</a></td><td>@Gherkin2JUnitOptions inheritance and override</td></tr>
<tr><td>&ensp; &ensp; └── <a href="examples/common-use-cases/example-10/README.md">Cucumber Annotations</a></td><td>@Given/@When/@Then and annotation-based matching</td></tr>
</table>

---

## Details of mapping Gherkin → JUnit

All elements of [Gherkin](https://cucumber.io/docs/gherkin/reference/) are supported, please refer to below sections for
details.

### Primary keywords:

<details>

<summary>Feature</summary>

+ The feature’s keyword, title, and description lines appear as a **class-level JavaDoc** comment on the generated
  class. A `@DisplayName` annotation is also added, using the **spec file name** (without `.feature` / `.specb` extension) — not
  the Feature title.

<table>
  <tr>
    <th align="left">Gherkin</th>
    <th align="left">JUnit</th>
  </tr>
  <tr>
    <td valign="top" class="diffTable" style="padding: 0px; font-size: larger;"><pre><code class="language-gherkin" data-lang="gherkin">

```gherkin
Feature: Shopping cart totals and shipping

  As a shopper
  I want the cart to keep item totals accurate and show free shipping when eligible
  So that I can check out with confidence and avoid extra costs
```

</code></pre>
</td>
<td valign="top">
<pre>
<code class="language-java" data-lang="java">

```java
/**
 * Feature: Shopping cart totals and shipping
 *   As a shopper
 *   I want the cart to keep item totals accurate and show free shipping when eligible
 *   So that I can check out with confidence and avoid extra costs
 */
public class CartFeatureTest extends CartFeature {
}
```

</code></pre></td>
</tr>
</table>

</details>

<details>

<summary>Rule</summary>

+ Rule sections are mapped to nested test classes inside the generated test class.

+ Rule's keyword & title are put into
  the value of the @DisplayName JUnit annotation.

+ If a rule additionally has description lines then those are put into
  a JavaDoc comment above the nested class.

<table>
  <tr>
    <th align="left">Gherkin</th>
    <th align="left">JUnit</th>
  </tr>
  <tr>
    <td valign="top" class="diffTable" style="padding: 0px; font-size: larger;"><pre><code class="language-gherkin" data-lang="gherkin">

```gherkin
Feature: Shopping cart totals and shipping

  Rule: Cannot checkout with an empty cart

  Rule: Free shipping applies when subtotal is at least €50
    Orders at or above €50 show a "Free shipping" banner; lower subtotals show the shipping cost.
```

</code></pre>
</td>
<td valign="top">
<pre>
<code class="language-java" data-lang="java">

```java
/**
 * Feature: Shopping cart totals and shipping
 */
public class CartFeatureTest extends CartFeature {

    @Nested
    @Order(1)
    @Tag("new")
    @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
    @DisplayName("Rule: Cannot checkout with an empty cart")
    public class Rule_1 {
        @Test
        public void noScenariosInRule() {
            Assertions.fail("Rule doesn't have any scenarios");
        }
    }

    /**
     * Orders at or above €50 show a "Free shipping" banner; lower subtotals show the shipping cost.
     */
    @Nested
    @Order(2)
    @Tag("new")
    @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
    @DisplayName("Rule: Free shipping applies when subtotal is at least €50")
    public class Rule_2 {
        @Test
        public void noScenariosInRule() {
            Assertions.fail("Rule doesn't have any scenarios");
        }
    }
}
```

</code></pre></td>
</tr>
</table>

</details>

<details>

<summary>Scenario</summary>

+ Scenario sections are mapped to test methods that are annotated with JUnit's @Test annotation.

+ Scenario's keyword & title are put into the value of the @DisplayName annotation.

+ If scenario additionally has description lines then those are put into a JavaDoc comment
  above the test method.

<table>
  <tr>
    <th align="left">Gherkin</th>
    <th align="left">JUnit</th>
  </tr>
  <tr>
    <td valign="top" class="diffTable" style="padding: 0px; font-size: larger;"><pre><code class="language-gherkin" data-lang="gherkin">

```gherkin
Feature: Shopping cart totals and shipping

  Scenario: Update quantity updates subtotal

  Rule: Free shipping applies when subtotal is at least €50

    Scenario: Show free-shipping banner when threshold is met
    It covers the visual banner only; actual shipping cost calculation is out of scope.
```

</code></pre>
</td>
<td valign="top">
<pre>
<code class="language-java" data-lang="java">

```java

/**
 * Feature: Shopping cart totals and shipping
 */
public class CartFeatureTest extends CartFeature {

    @Test
    @Order(1)
    @Tag("new")
    @DisplayName("Scenario: Update quantity updates subtotal")
    public void scenario_1() {
        Assertions.fail("Scenario has no steps");
    }

    @Nested
    @Order(1)
    @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
    @DisplayName("Rule: Free shipping applies when subtotal is at least €50")
    public class Rule_1 {
        /**
         * It covers the visual banner only; actual shipping cost calculation is out of scope.
         */
        @Test
        @Order(1)
        @Tag("new")
        @DisplayName("Scenario: Show free-shipping banner when threshold is met")
        public void scenario_1() {
            Assertions.fail("Scenario has no steps");
        }
    }
}

```

</code></pre></td>
</tr>
</table>

</details>

<details>

<summary>Given, When, Then, And & But steps</summary>

#### Step keywords → method names

+ By default, the step keyword (Given/When/Then/And/But) is **not included** in the method name. Only the step text
  drives the name.

+ This means identical step text under different keywords (e.g., `Given my cart subtotal is "55.00"` and
  `Then my cart subtotal is "120.00"`) produces a **single shared method**.

+ And … / But … → inherit the previous step’s keyword for annotation purposes, but the keyword is still omitted from the
  method name.

+ To include keywords as method prefixes (e.g., `givenMyCart…`, `whenI…`, `thenMyCart…`), set
  `@Gherkin2JUnitOptions(useStepKeywordInStepMethodName = true)`.

#### Method name derivation (from step text)

+ Take the step’s **plain text** (minus the keyword and any quoted arguments), split into words, and **CamelCase** them.

+ **Invalid Java identifier** characters (at the start or in the middle) are **removed**.

+ Where the step had quoted arguments, the method name includes **positional placeholders** to indicate argument slots (
  e.g., `$p1`, `$p2`, …).

+ If [spec text stripping](#stripping-text-from-spec-files--experimental) is configured, that markup is
  removed **before** the name is derived — so adding or editing a `<CHANGED …>` marker never renames a step method.

> Resulting shape:
`camelCasedWordsAroundArgsWithPlaceholders`
>
> e.g., `myCartContains$p1WithQuantity$p2AndUnitPrice$p3(...)`

#### Quoted arguments → method parameters & call sites

+ Every "**&lt;value&gt;**" in the step becomes a method parameter. The generator infers the type from the quoted value:
  `"true"`/`"false"` → `Boolean`, integer literals → `Integer` (or `Long` if too large), decimal literals → `Double`,
  single characters → `Character`, everything else → `String`.

+ The quoted values are removed from the method name and passed as arguments from the generated scenario method in
  left-to-right order.

+ Parameter names in the generated code are generic (e.g., p1, p2, …).

<table>
  <tr>
    <th align="left">Gherkin</th>
    <th align="left">JUnit</th>
  </tr>
  <tr>
    <td valign="top" class="diffTable" style="padding: 0px; font-size: larger;"><pre><code class="language-gherkin" data-lang="gherkin">

```gherkin
Given my cart contains "Wireless Headphones" with quantity "1" and unit price "60.00"
When I change the quantity to "2"
Then my cart subtotal is "120.00"
```

</code></pre>
</td>
<td valign="top">
<pre>
<code class="language-java" data-lang="java">

```java

// Generated step methods (with failing stubs)
void myCartContains$p1WithQuantity$p2AndUnitPrice$p3(String p1, Integer p2, Double p3) {
    Assertions.fail("Step is not yet implemented");
}

void iChangeTheQuantityTo$p1(Integer p1) {
    Assertions.fail("Step is not yet implemented");
}

void myCartSubtotalIs$p1(Double p1) {
    Assertions.fail("Step is not yet implemented");
}

// Generated scenario method (calls)
myCartContains$p1WithQuantity$p2AndUnitPrice$p3("Wireless Headphones", 1, 60.00);

iChangeTheQuantityTo$p1(2);

myCartSubtotalIs$p1(120.00);

```

</code></pre></td>
</tr>
</table>

+ The original textual representation of each of the step methods is placed into a block java comment above each method
  call to aid readability

##### Complete example:

<table>
  <tr>
    <th align="left">Gherkin</th>
    <th align="left">JUnit</th>
  </tr>
  <tr>
    <td valign="top" class="diffTable" style="padding: 0px; font-size: larger;"><pre><code class="language-gherkin" data-lang="gherkin">

```gherkin
Feature: Shopping cart totals and shipping

  Scenario: Update quantity updates subtotal
    Given my cart contains "Wireless Headphones" with quantity "1" and unit price "60.00"
    When I change the quantity to "2"
    Then my cart subtotal is "120.00"

  Rule: Free shipping applies when subtotal is at least €50

    Scenario: Show free-shipping banner when threshold is met
      Given my cart subtotal is "55.00"
      When I view the cart
      Then I see the "Free shipping" banner
```

</code></pre>
</td>
<td valign="top">
<pre>
<code class="language-java" data-lang="java">

```java

/**
 * Feature: Shopping cart totals and shipping
 */
public class CartFeatureTest extends CartFeature {

    public void myCartContains$p1WithQuantity$p2AndUnitPrice$p3(String p1, Integer p2,
                                                                Double p3) {
        Assertions.fail("Step is not yet implemented");
    }

    public void iChangeTheQuantityTo$p1(Integer p1) {
        Assertions.fail("Step is not yet implemented");
    }

    public void myCartSubtotalIs$p1(Double p1) {
        Assertions.fail("Step is not yet implemented");
    }

    public void iViewTheCart() {
        Assertions.fail("Step is not yet implemented");
    }

    public void iSeeThe$p1Banner(String p1) {
        Assertions.fail("Step is not yet implemented");
    }

    @Test
    @Order(1)
    @DisplayName("Scenario: Update quantity updates subtotal")
    public void scenario_1() {
        /**
         * Given my cart contains "Wireless Headphones" with quantity "1" and unit price "60.00"
         */
        myCartContains$p1WithQuantity$p2AndUnitPrice$p3("Wireless Headphones", 1, 60.00);
        /**
         * When I change the quantity to "2"
         */
        iChangeTheQuantityTo$p1(2);
        /**
         * Then my cart subtotal is "120.00"
         */
        myCartSubtotalIs$p1(120.00);
    }

    @Nested
    @Order(1)
    @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
    @DisplayName("Rule: Free shipping applies when subtotal is at least €50")
    public class Rule_1 {
        @Test
        @Order(1)
        @DisplayName("Scenario: Show free-shipping banner when threshold is met")
        public void scenario_1() {
            /**
             * Given my cart subtotal is "55.00"
             */
            myCartSubtotalIs$p1(55.00);
            /**
             * When I view the cart
             */
            iViewTheCart();
            /**
             * Then I see the "Free shipping" banner
             */
            iSeeThe$p1Banner("Free shipping");
        }
    }
}

```

</code></pre></td>
</tr>
</table>

#### DocStrings & Data Tables (if present)

+ They don’t change the method-naming rules above.

+ They’re passed along to the step method (appended after quoted String params).

+ See below sections for examples of how these are passed down to step method calls.

</details>

<details>

<summary>Background</summary>

#### Rules

* **Lifecycle hook:** Every `Background` becomes a `@BeforeEach` method that runs **before each Scenario** (and Example
  row).

* **Feature-level Background:** A `Background` declared **before any** `Rule` **or** `Scenario` is generated as a member
  method of the outer test class.

* **Rule-level Background:** A `Background` declared as the **first element inside a** `Rule` is generated as a member
  method of that `@Nested` rule class.

* **Display name:** If the `Background` has a **title** (text on the same line as `Background:`), that title is used in
  a `@DisplayName` on the generated `@BeforeEach` method.

* **Description lines:** If the `Background` has description lines under it, they are emitted as a **JavaDoc comment**
  above the generated `@BeforeEach` method.

* **Steps inside Background:** The body of the `@BeforeEach` method **calls the generated step methods** in the same
  order, using the same argument extraction and type inference rules as normal steps.

#### Order of execution (Feature + Rule)

If both a **feature-level** and a **rule-level** `Background` exist, JUnit 5 runs the outer class’s `@BeforeEach` *
*first**, then the nested rule class’s `@BeforeEach`, then the scenario’s test method.
Order: **Feature** `@BeforeEach` → **Rule** `@BeforeEach` → **Scenario** `@Test`.

> Notes:
>
> * Gherkin permits at most **one** `Background` **per container** (one for the Feature, and at most one per Rule).
> * `And` / `But` in Background steps inherit the previous keyword just like elsewhere.

#### Examples

#### 1) Feature-level Background (title + description)

<table>
  <tr>
    <th align="left">Gherkin</th>
    <th align="left">JUnit</th>
  </tr>
  <tr>
    <td valign="top" class="diffTable" style="padding: 0px; font-size: larger;"><pre><code class="language-gherkin" data-lang="gherkin">

```gherkin
Feature: Shopping cart totals and shipping

  Background: Start with a clean cart
  Ensures cart and session are reset before each test.
    Given I am a signed-in shopper "alice@example.com"
    And my cart is empty
    And the currency is "EUR"
```

</code></pre>
</td>
<td valign="top">
<pre>
<code class="language-java" data-lang="java">

```java

/**
 * Feature: Shopping cart totals and shipping
 */
public class CartFeatureTest extends CartFeature {

    public void iAmASignedinShopper$p1(String p1) {
        Assertions.fail("Step is not yet implemented");
    }

    public void myCartIsEmpty() {
        Assertions.fail("Step is not yet implemented");
    }

    public void theCurrencyIs$p1(String p1) {
        Assertions.fail("Step is not yet implemented");
    }

    /**
     * Ensures cart and session are reset before each test.
     */
    @BeforeEach
    @DisplayName("Background: Start with a clean cart")
    public void featureBackground(TestInfo testInfo) {
        /**
         * Given I am a signed-in shopper "alice@example.com"
         */
        iAmASignedinShopper$p1("alice@example.com");
        /**
         * And my cart is empty
         */
        myCartIsEmpty();
        /**
         * And the currency is "EUR"
         */
        theCurrencyIs$p1("EUR");
    }
}

```

</code></pre></td>
</tr>
</table>

#### 2) Rule-level Background

<table>
  <tr>
    <th align="left">Gherkin</th>
    <th align="left">JUnit</th>
  </tr>
  <tr>
    <td valign="top" class="diffTable" style="padding: 0px; font-size: larger;"><pre><code class="language-gherkin" data-lang="gherkin">

```gherkin
Feature: Shopping cart totals and shipping

  Rule: Free shipping applies when subtotal is at least €50

    Background:
    Sets up a cart close to the free-shipping threshold.
      Given my cart subtotal is "45.00"
```

</code></pre>
</td>
<td valign="top">
<pre>
<code class="language-java" data-lang="java">

```java

/**
 * Feature: Shopping cart totals and shipping
 */
public class CartFeatureTest extends CartFeature {

    public void myCartSubtotalIs$p1(Double p1) {
        Assertions.fail("Step is not yet implemented");
    }

    @Nested
    @Order(1)
    @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
    @DisplayName("Rule: Free shipping applies when subtotal is at least €50")
    public class Rule_1 {
        /**
         * Sets up a cart close to the free-shipping threshold.
         */
        @BeforeEach
        @DisplayName("Background:")
        public void ruleBackground(TestInfo testInfo) {
            /**
             * Given my cart subtotal is "45.00"
             */
            myCartSubtotalIs$p1(45.00);
        }
    }
}

```

</code></pre></td>
</tr>
</table>

#### 3) Both Backgrounds + a Scenario under the Rule (full flow)

<table>
  <tr>
    <th align="left">Gherkin</th>
    <th align="left">JUnit</th>
  </tr>
  <tr>
    <td valign="top" class="diffTable" style="padding: 0px; font-size: larger;"><pre><code class="language-gherkin" data-lang="gherkin">

```gherkin
Feature: Shopping cart totals and shipping

  Background: Start with a clean cart
    Given I am a signed-in shopper "alice@example.com"
    And my cart is empty

  Rule: Free shipping applies when subtotal is at least €50

    Background:
      Given the currency is "EUR"
      And my cart subtotal is "55.00"

    Scenario: Show free-shipping banner when threshold is met
      When I view the cart
      Then I see the "Free shipping" banner
```

</code></pre>
</td>
<td valign="top">
<pre>
<code class="language-java" data-lang="java">

```java

/**
 * Feature: Shopping cart totals and shipping
 */
@Generated("dev.specbinder.processor.AnnotationProcessor")
@DisplayName("cart")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@TestClassOrder(ClassOrderer.OrderAnnotation.class)
@SourceFilePath("specs/cart.feature")
public class CartFeatureTest extends CartFeature {

    public void iAmASignedinShopper$p1(String p1) {
        Assertions.fail("Step is not yet implemented");
    }

    public void myCartIsEmpty() {
        Assertions.fail("Step is not yet implemented");
    }

    @BeforeEach
    @DisplayName("Background: Start with a clean cart")
    public void featureBackground(TestInfo testInfo) {
        /**
         * Given I am a signed-in shopper "alice@example.com"
         */
        iAmASignedinShopper$p1("alice@example.com");
        /**
         * And my cart is empty
         */
        myCartIsEmpty();
    }

    public void theCurrencyIs$p1(String p1) {
        Assertions.fail("Step is not yet implemented");
    }

    public void myCartSubtotalIs$p1(Double p1) {
        Assertions.fail("Step is not yet implemented");
    }

    public void iViewTheCart() {
        Assertions.fail("Step is not yet implemented");
    }

    public void iSeeThe$p1Banner(String p1) {
        Assertions.fail("Step is not yet implemented");
    }

    @Nested
    @Order(1)
    @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
    @DisplayName("Rule: Free shipping applies when subtotal is at least €50")
    public class Rule_1 {
        @BeforeEach
        @DisplayName("Background:")
        public void ruleBackground(TestInfo testInfo) {
            /**
             * Given the currency is "EUR"
             */
            theCurrencyIs$p1("EUR");
            /**
             * And my cart subtotal is "55.00"
             */
            myCartSubtotalIs$p1(55.00);
        }

        @Test
        @Order(1)
        @DisplayName("Scenario: Show free-shipping banner when threshold is met")
        public void scenario_1() {
            /**
             * When I view the cart
             */
            iViewTheCart();
            /**
             * Then I see the "Free shipping" banner
             */
            iSeeThe$p1Banner("Free shipping");
        }
    }
}

```

</code></pre></td>
</tr>
</table>

#### **Execution order for that Scenario**

1. `featureBackground()` (feature-level `@BeforeEach`)
2. `ruleBackground()` (rule-level `@BeforeEach`)
3. `scenario_1()` (`@Test`)

</details>

<details>

<summary>Scenario Outline & Examples</summary>

#### 1) One parameterized test per Scenario Outline

A single `@ParameterizedTest` method is generated for each `Scenario Outline`.
Its body is the *template* of the outline; the concrete values come from the `Examples` table.

#### Generated example:

```java

@ParameterizedTest(name = "Example: [{arguments}]")
@CsvSource(
        useHeadersInDisplayName = true,
        delimiter = '|',
        textBlock = """
                name                | startQty | price | newQty | expectedSubtotal
                Wireless Headphones | 1        | 60.00 | 2      | 120.00
                Coffee Beans 1kg    | 2        | 15.50 | 3      | 46.50
                """
)
@DisplayName("Scenario Outline: Subtotal updates when quantity changes")
public void scenario_1(String name, Integer startQty, Double price, Integer newQty, Double expectedSubtotal) { ...}
```

#### 2) `Examples` table → `@CsvSource(textBlock = …)`

* The `Examples` rows are embedded as a **CSV text block** inside `@CsvSource`.

* The **column order** in the table becomes the **parameter order** in the test method.

* The **header row** supplies the **parameter names** (`name`, `startQty`, `price`, `newQty`, `expectedSubtotal`) after
  being sanitized into valid Java identifiers (spaces/punctuation removed, etc.).

* The **cell delimiter** mirrors the table separator (`|`), specified via `delimiter = '|'`.

* The display name pattern `name = "Example: [{arguments}]"` makes IDE/CI output like:
  `Example: [Wireless Headphones, 1, 60.00, 2, 120.00]`, `Example: [Coffee Beans 1kg, 2, 15.50, 3, 46.50]`.

#### 3) Placeholders `<…>` in steps → argument variables

* Each placeholder in the outline text (e.g., `<name>`, `<startQty>`, `<price>`, `<newQty>`, `<expectedSubtotal>`)
  becomes a **method parameter** on the parameterized test.

* Inside the test body, the generated calls **pass those variables** in left-to-right order to the step methods:

```java
myCartContains$p1WithQuantity$p2AndUnitPrice$p3(name, startQty, price);

iChangeTheQuantityTo$p1(newQty);

myCartSubtotalIs$p1(expectedSubtotal);
```

#### Full example

<table>
  <tr>
    <th align="left">Gherkin</th>
    <th align="left">JUnit</th>
  </tr>
  <tr>
    <td valign="top" class="diffTable" style="padding: 0px; font-size: larger;"><pre><code class="language-gherkin" data-lang="gherkin">

```gherkin
Feature: Shopping cart totals and shipping

  Scenario Outline: Subtotal updates when quantity changes
    Given my cart contains <name> with quantity <startQty> and unit price <price>
    When I change the quantity to <newQty>
    Then my cart subtotal is <expectedSubtotal>

    Examples:
      | name                | startQty | price | newQty | expectedSubtotal |
      | Wireless Headphones | 1        | 60.00 | 2      | 120.00           |
      | Coffee Beans 1kg    | 2        | 15.50 | 3      | 46.50            |
```

</code></pre>
</td>
<td valign="top">
<pre>
<code class="language-java" data-lang="java">

```java

/**
 * Feature: Shopping cart totals and shipping
 */
public class CartFeatureTest extends CartFeature {

    public void myCartContains$p1WithQuantity$p2AndUnitPrice$p3(String p1, Integer p2,
                                                                Double p3) {
        Assertions.fail("Step is not yet implemented");
    }

    public void iChangeTheQuantityTo$p1(Integer p1) {
        Assertions.fail("Step is not yet implemented");
    }

    public void myCartSubtotalIs$p1(Double p1) {
        Assertions.fail("Step is not yet implemented");
    }

    @ParameterizedTest(
            name = "Example: [{arguments}]"
    )
    @CsvSource(
            useHeadersInDisplayName = true,
            delimiter = '|',
            textBlock = """
                    name                | startQty | price | newQty | expected subtotal
                    Wireless Headphones | 1        | 60.00 | 2      | 120.00
                    Coffee Beans 1kg    | 2        | 15.50 | 3      | 46.50
                    """
    )
    @Order(1)
    public void scenario_1(String name, Integer startqty, Double price, Integer newqty,
                           Double expectedSubtotal) {
        /**
         * Given my cart contains <name> with quantity <startQty> and unit price <price>
         */
        myCartContains$p1WithQuantity$p2AndUnitPrice$p3(name, startqty, price);
        /**
         * When I change the quantity to <newQty>
         */
        iChangeTheQuantityTo$p1(newqty);
        /**
         * Then my cart subtotal is <expectedSubtotal>
         */
        myCartSubtotalIs$p1(expectedSubtotal);
    }
}

```

</code></pre></td>
</tr>
</table>

#### Edge cases & notes

* **Multiple `Examples` blocks:** Supported, as long as all blocks have **identical header columns in the same order**.
  Each block generates a separate repeatable `@CsvSource` annotation on the same test method.

* **Parameter name sanitization:** Column headers are preserved as-is in the `@CsvSource` text block, but the
  corresponding method parameter names are sanitized to valid Java identifiers (e.g., `start qty` → `startQty`).

* **Empty cells / quoting:** JUnit's `@CsvSource` parser automatically trims leading and trailing whitespace from
  cell values. Empty cells become `null` by default; use `''` (two single quotes) to represent an empty string.

* **Types:** The generator infers parameter types from cell values: `"true"`/`"false"` → `Boolean`, integer literals →
  `Integer` (or `Long`), decimal literals → `Double`, single characters → `Character`, everything else → `String`. All
  values in a column must be compatible with the inferred type; if any value doesn't fit, the column falls back to
  `String`.

</details>

### Secondary keywords:

<details>

<summary>Doc Strings (""") </summary>

#### Rules

* A step with a **DocString** gains **one trailing** `String` **parameter** (after any quoted args).

* **Method naming is unaffected** by the DocString (no extra `$p…` placeholder in the name).

* The **DocString body** (the lines between the triple quotes) is passed **verbatim**: newlines and indentation are *
  *preserved**.

* At the call site, the generator uses a **Java text block** (`"""…"""`) so formatting is retained.

* Gherkin allows **either** a DocString **or** a Data Table on a step, not both; the generator follows that rule.

#### Example A — DocString only (no quoted args)

<table>
  <tr>
    <th align="left">Gherkin</th>
    <th align="left">Generated signature & call</th>
  </tr>
  <tr>
    <td valign="top" class="diffTable" style="padding: 0px; font-size: larger;"><pre><code class="language-gherkin" data-lang="gherkin">

```gherkin
When I submit a shipping address:
"""
  {
    "line1": "Baker St 221B",
    "city": "London",
    "country": "UK"
  }
  """
```

</code></pre>
</td>
<td valign="top">
<pre>
<code class="language-java" data-lang="java">

```java

void iSubmitAShippingAddress(String docString) {
    Assertions.fail("Step is not yet implemented");
}

iSubmitAShippingAddress("""
{
  "line1": "Baker St 221B",
  "city": "London",
  "country": "UK"
}
""");

```

</code></pre></td>
</tr>
</table>

#### Example B — Quoted args + DocString

<table>
  <tr>
    <th align="left">Gherkin</th>
    <th align="left">Generated signature & call</th>
  </tr>
  <tr>
    <td valign="top" class="diffTable" style="padding: 0px; font-size: larger;"><pre><code class="language-gherkin" data-lang="gherkin">

```gherkin
Given I add item "Wireless Headphones" with options
"""
  {
    "color": "Black",
    "warranty": "2 years",
    "unitPrice": "60.00"
  }
  """
```

</code></pre>
</td>
<td valign="top">
<pre>
<code class="language-java" data-lang="java">

```java

void iAddItem$p1WithOptions(String p1, String docString) {
    Assertions.fail("Step is not yet implemented");
}

iAddItem$p1WithOptions("Wireless Headphones","""
        {
          "color": "Black",
          "warranty": "2 years",
          "unitPrice": "60.00"
        }
        """);

```

</code></pre></td>
</tr>
</table>

</details>

<details>

<summary>Data Tables (|)</summary>

The `dataTableParameterType` option controls how Gherkin data tables are represented in the generated Java code.
There are three modes — set via `@Gherkin2JUnitOptions(dataTableParameterType = ...)`.

All three examples below use the same Gherkin input:

```gherkin
Feature: Shopping cart totals and shipping

  Background:
    Given my cart contains the following items:
      | name                | qty | price | category    |
      | Wireless Headphones | 1   | 60.00 | electronics |
      | Coffee Beans 1kg    | 2   | 15.50 | grocery     |
```

---

#### `LIST_OF_OBJECT_PARAMS` (default)

Generates a **record-like inner class** per table (named after the last word of the step text + `Param` suffix).
Each column header becomes a typed field with automatic type inference (precedence: `Boolean`, `Integer`, `Long`,
`Double`, `Character`, then `String`). Each data row becomes a `new ParamType(...)` constructor call inside `List.of(...)`.

<table>
  <tr>
    <th align=”left”>Gherkin</th>
    <th align=”left”>Generated code</th>
  </tr>
  <tr>
    <td valign=”top”><pre><code class=”language-gherkin” data-lang=”gherkin”>

```gherkin
Given my cart contains the following items:
  | name                | qty | price | category    |
  | Wireless Headphones | 1   | 60.00 | electronics |
  | Coffee Beans 1kg    | 2   | 15.50 | grocery     |
```

</code></pre></td>
<td valign=”top”><pre><code class=”language-java” data-lang=”java”>

```java
// Step method signature
public void myCartContainsTheFollowingItems(List<ItemsParam> items) {
    Assertions.fail(“Step is not yet implemented”);
}

// Call site
myCartContainsTheFollowingItems(
        List.of(
                new ItemsParam(
                        “Wireless Headphones”,
                        1,
                        60.00,
                        “electronics”
                ),
                new ItemsParam(
                        “Coffee Beans 1kg”,
                        2,
                        15.50,
                        “grocery”
                )
        ));

// Generated inner class
public static class ItemsParam {
    private final String name;
    private final Integer qty;
    private final Double price;
    private final String category;

    public ItemsParam(String name, Integer qty,
                         Double price, String category) {
        this.name = name;
        this.qty = qty;
        this.price = price;
        this.category = category;
    }

    public String name()      { return this.name; }
    public Integer qty()      { return this.qty; }
    public Double price()     { return this.price; }
    public String category()  { return this.category; }
}
```

</code></pre></td>
</tr>
</table>

**Improving type safety further:** Once the code is generated, you can move the step method stub and
the `ItemsParam` class into your marker/base class and refine the field types — for example, changing a
`String` field to an `enum`. On the next generation run, the generator detects your class in the hierarchy
and uses it instead of generating a new one. If a value in the spec file doesn't match a valid enum constant,
you get a **compilation error** — catching data mismatches at compile time rather than at runtime.

```java
// In your marker class — refined from the generated version
public enum Category { electronics, grocery }

public static class ItemsParam {
    private final String name;
    private final Integer qty;
    private final Double price;
    private final Category category;  // was String, now enum

    // constructor, accessors ...
}

public void myCartContainsTheFollowingItems(List<ItemsParam> items) {
    // your implementation goes here
}
```

Now suppose someone adds a row to the spec file with an invalid category:

```gherkin
Given my cart contains the following items:
  | name                | qty | price | category    |
  | Wireless Headphones | 1   | 60.00 | electronics |
  | Coffee Beans 1kg    | 2   | 15.50 | grocery     |
  | Yoga Mat            | 1   | 25.00 | sports      |
```

The generator uses your `ItemsParam` class from the base class and the generated test class now calls the inherited step method:

```java
// Generated test class — compilation error!
myCartContainsTheFollowingItems(
        List.of(
                new ItemsParam(
                        "Wireless Headphones",
                        1,
                        60.00,
                        Category.electronics
                ),
                new ItemsParam(
                        "Coffee Beans 1kg",
                        2,
                        15.50,
                        Category.grocery
                ),
                new ItemsParam(
                        "Yoga Mat",
                        1,
                        25.00,
                        "sports"  // ❌ compile error: String cannot be converted to Category
                )
        ));
```

The mismatch is caught **at compile time** — you must either add `sports` to the `Category` enum or fix the
spec file before the project compiles.

---

#### `CUCUMBER_DATA_TABLE`

Uses Cucumber's `DataTable` as the parameter type. The generator includes a `createDataTable()` helper
that parses the text block into a `DataTable`. Requires a `getTableConverter()` method in your class hierarchy.
Gives access to the full Cucumber DataTable API for type conversions.

<table>
  <tr>
    <th align=”left”>Gherkin</th>
    <th align=”left”>Generated code</th>
  </tr>
  <tr>
    <td valign=”top”><pre><code class=”language-gherkin” data-lang=”gherkin”>

```gherkin
Given my cart contains the following items:
  | name                | qty | price | category    |
  | Wireless Headphones | 1   | 60.00 | electronics |
  | Coffee Beans 1kg    | 2   | 15.50 | grocery     |
```

</code></pre></td>
<td valign=”top”><pre><code class=”language-java” data-lang=”java”>

```java
// Step method signature
public void myCartContainsTheFollowingItems(DataTable dataTable) {
    Assertions.fail(“Step is not yet implemented”);
}

// Call site
myCartContainsTheFollowingItems(createDataTable(“””
        |name               |qty|price|category   |
        |Wireless Headphones|1  |60.00|electronics|
        |Coffee Beans 1kg   |2  |15.50|grocery    |
        “””));

// Generated helper (skipped if already in your base class)
protected DataTable createDataTable(String tableLines) {
    // parses pipe-delimited text block into DataTable
    // using getTableConverter()
    ...
}

// You must provide this in your base class
protected abstract DataTable.TableConverter
        getTableConverter();
```

</code></pre></td>
</tr>
</table>

---

#### `LIST_OF_MAPS`

Each data table becomes a `List<Map<String, String>>`. The generator includes a `createListOfMaps()` helper
that parses a pipe-delimited text block — the first row is treated as column headers (map keys), subsequent rows
become map entries. All values are strings; you parse/convert as needed.

<table>
  <tr>
    <th align=”left”>Gherkin</th>
    <th align=”left”>Generated code</th>
  </tr>
  <tr>
    <td valign=”top”><pre><code class=”language-gherkin” data-lang=”gherkin”>

```gherkin
Given my cart contains the following items:
  | name                | qty | price | category    |
  | Wireless Headphones | 1   | 60.00 | electronics |
  | Coffee Beans 1kg    | 2   | 15.50 | grocery     |
```

</code></pre></td>
<td valign=”top”><pre><code class=”language-java” data-lang=”java”>

```java
// Step method signature
public void myCartContainsTheFollowingItems(List<Map<String, String>> data) {
    Assertions.fail(“Step is not yet implemented”);
}

// Call site
myCartContainsTheFollowingItems(createListOfMaps(“””
        |name               |qty|price|category   |
        |Wireless Headphones|1  |60.00|electronics|
        |Coffee Beans 1kg   |2  |15.50|grocery    |
        “””));

// Generated helper (skipped if already in your base class)
protected List<Map<String, String>> createListOfMaps(
        String tableLines) {
    // parses pipe-delimited text block into
    // List<Map<String, String>>
    ...
}
```

</code></pre></td>
</tr>
</table>

</details>

<details>

<summary>Tags (@)</summary>

#### Rules

* **One-to-one mapping:** Each Gherkin tag becomes a JUnit 5 `@Tag("<value>")`.
* **Feature-level tags** → `@Tag` annotations on the **generated outer test class**.
* **Rule-level tags** → `@Tag` annotations on the **nested rule class**.
* **Scenario-level tags** → `@Tag` annotations on the **scenario test method** (`@Test` or `@ParameterizedTest`).
* **Examples-level tags** → *not supported* and are currently **ignored**.
* Multiple tags are emitted as a single `@Tags` container annotation wrapping repeated `@Tag` annotations.

**Example**

<table>
  <tr>
    <th align="left">Gherkin</th>
    <th align="left">JUnit</th>
  </tr>
  <tr>
    <td valign="top" class="diffTable" style="padding: 0px; font-size: larger;"><pre><code class="language-gherkin" data-lang="gherkin">

```gherkin
@fast @cart
Feature: Shopping cart totals and shipping

  @ui
  Rule: Free shipping applies when subtotal is at least €50

  @smoke @banner
  Scenario: Show free-shipping banner when threshold is met
    Given my cart subtotal is "55.00"
    When I view the cart
    Then I see the "Free shipping" banner
```

</code></pre>
</td>
<td valign="top">
<pre>
<code class="language-java" data-lang="java">

```java

package org.mycompany.app;

import dev.specbinder.annotations.output.SourceFilePath;

import java.lang.String;
import javax.annotation.processing.Generated;

import org.junit.jupiter.api.ClassOrderer;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.MethodOrderer;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Tags;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestClassOrder;
import org.junit.jupiter.api.TestMethodOrder;

/**
 * Feature: Shopping cart totals and shipping
 */
@Tags({
        @Tag("fast"),
        @Tag("cart")
})
@Generated("dev.specbinder.processor.AnnotationProcessor")
@DisplayName("cart")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@TestClassOrder(ClassOrderer.OrderAnnotation.class)
@SourceFilePath("specs/cart.feature")
public class CartFeatureTest extends CartFeature {

    @Nested
    @Order(1)
    @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
    @Tag("ui")
    @DisplayName("Rule: Free shipping applies when subtotal is at least €50")
    public class Rule_1 {
        @Tags({
                @Tag("smoke"),
                @Tag("banner")
        })
        @Test
        @Order(1)
        @DisplayName("Scenario: Show free-shipping banner when threshold is met")
        public void scenario_1() {
            /**
             * Given my cart subtotal is "55.00"
             */
            myCartSubtotalIs$p1(55.00);
            /**
             * When I view the cart
             */
            iViewTheCart();
            /**
             * Then I see the "Free shipping" banner
             */
            iSeeThe$p1Banner("Free shipping");
        }
    }
}

```

</code></pre></td>
</tr>
</table>

</details>

<details>

<summary>Comments (#)</summary>

* **Ignored by the processor:** Lines that are comments in Gherkin (i.e., lines starting with `#`) are **not mapped** to
  JUnit in any way. They are skipped during generation.
* **Where to put narrative instead:** If you need human‑readable context preserved in Java, use `Feature`/`Rule`/
  `Scenario`/`Background` **descriptions** (indented lines under the header)—those are emitted into JavaDoc/
  `@DisplayName` as documented in sections above.

</details>

---

## Configuration

All configuration is provided via the `@Gherkin2JUnitOptions` annotation. You can place this annotation:

* **On the marker class** (applies to that feature class only).
* **On a shared base test class** (options are **inherited** by subclasses/marker classes in your test hierarchy).
  Inherited options can be **selectively overridden** by placing another `@Gherkin2JUnitOptions` on a child class — only
  the explicitly specified options are overridden, the rest continue to inherit from the parent.

#### Available options

| Option                                  | Type     | Default                  | Description                                                                                                                                               |
|-----------------------------------------|----------|--------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| `supportedFileExtensions`               | String[] | `{"feature", "specb"}`   | File extensions recognised by convention-based discovery and glob patterns                                                                                |
| `skipGenerationForTags`                 | String[] | `{}`                     | Regex patterns; matching tags cause the generator to skip the corresponding Feature/Rule/Scenario/Examples element entirely                              |
| `shouldBeAbstract`                      | boolean  | `true`                   | Generate abstract class with abstract step methods (default). Set to `false` for a concrete class with failing stubs                                      |
| `classSuffixIfAbstract`                 | String   | `"Scenarios"`            | Class name suffix when generating in abstract mode                                                                                                        |
| `classSuffixIfConcrete`                 | String   | `"Test"`                 | Class name suffix when generating in concrete mode                                                                                                        |
| `unimplementedStepBehavior`             | enum     | `FAIL`                   | Body of unimplemented step stubs in *concrete* mode: `FAIL`, `SKIP`, or `COMPILATION_ERROR`                                                              |
| `emptyScenarioBehavior`                 | enum     | `FAIL`                   | Behavior for scenarios with no steps: `FAIL` (test fails), `SKIP` (test skipped), or `COMPILATION_ERROR` (project will not compile)                      |
| `emptyRuleBehavior`                     | enum     | `FAIL`                   | Behavior for rules with no scenarios: `FAIL` (test fails), `SKIP` (test skipped), or `COMPILATION_ERROR` (project will not compile)                      |
| `tagForEmptyScenarios`                  | String   | `"new"`                  | Tag added to empty scenarios (set to `""` to disable)                                                                                                     |
| `tagForEmptyRules`                      | String   | `"new"`                  | Tag added to empty rules (set to `""` to disable)                                                                                                         |
| `dataTableParameterType`                | enum     | `LIST_OF_OBJECT_PARAMS`  | How data tables map to Java types: `LIST_OF_OBJECT_PARAMS`, `LIST_OF_MAPS`, or `CUCUMBER_DATA_TABLE`                                                     |
| `useStepKeywordInStepMethodName`        | boolean  | `false`                  | Include Given/When/Then keyword as a prefix in step method names                                                                                          |
| `addCucumberStepAnnotations`            | boolean  | `false`                  | Add `@Given`/`@When`/`@Then` Cucumber annotations to step methods                                                                                        |
| `useCucumberAnnotationsForStepMatching` | boolean  | `false`                  | Use Cucumber annotations for step matching when present in base class                                                                                     |
| `addSourceLineNumbers`                  | boolean  | `false`                  | Embed source line numbers from the spec file into generated code: line numbers in `@DisplayName` annotations and `[N]` prefixes in step block comments |
| `useQualifiedEnumConstants`             | boolean  | `false`                  | Use fully qualified enum constant names in generated code                                                                                                 |
| `emitScenarioHash`                      | boolean  | `true`                   | Emit a `@ScenarioHash("…")` annotation carrying a SHA-256 of each scenario's executable content                                                          |
| `verbosity`                             | enum     | `NORMAL`                 | Build log verbosity during annotation processing: `SILENT`, `NORMAL`, `VERBOSE`, or `DEBUG`                                                              |
| `enableCompositeSteps`                  | boolean  | `false`                  | **(experimental)** Enable composite step pattern                                                                                                          |
| `stripPatterns`                         | String[] | `{}`                     | **(experimental)** Regex patterns; every match is stripped from the spec file before it is parsed — used to remove revision markers                       |
| `stripBetweenPatterns`                  | @StripBetween[] | `{}`            | **(experimental)** Pairs of start/end regex patterns; the span between them is stripped, markers included                                                 |

<details>

<summary>Example — per‑feature options on the marker class</summary>

```java
import dev.specbinder.processor.Gherkin2JUnit;
import dev.specbinder.processor.Gherkin2JUnitOptions;

@Gherkin2JUnitOptions( /* customize generation options as needed */)
@Gherkin2JUnit("specs/cart.feature")
public abstract class CartFeature {
}
```

</details>

<details>

 <summary>Example — inherited options via a base class</summary>

```java
import dev.specbinder.processor.Gherkin2JUnit;
import dev.specbinder.processor.Gherkin2JUnitOptions;

@Gherkin2JUnitOptions( /* shared options for all features */)
public abstract class BaseFeatureOptions {
}

@Gherkin2JUnit("specs/cart.feature")
public abstract class CartFeature extends BaseFeatureOptions {
}
```

</details>

#### Stripping text from spec files — *(experimental)*

Teams often annotate specs with HTML-like markup tying wording back to an issue tracker:

```gherkin
Given the user has a <CHANGED BR-123>premium</CHANGED BR-123> account
And the <NEW BY BR-456>loyalty tier</NEW BY BR-456> is shown
When the <REMOVED BR-789>legacy discount </REMOVED BR-789>is applied
```

Left in place, that markup reaches the generated code. Most importantly it becomes part of **step method
names** — so adding or editing a marker renames an abstract step method and the hand-written test class
that implements it no longer compiles. It also corrupts record field names derived from data table
headers, and emits unbalanced HTML into JavaDoc.

Two options remove it before the spec is parsed. Both take regular expressions, because in-house markup
conventions vary, and both default to `{}` (nothing is stripped).

| Option | Use it for |
|--------|------------|
| `stripBetweenPatterns` | removing a **span** — an opening marker, the text it wraps, and a closing marker |
| `stripPatterns`        | removing **individual markers**, keeping the text they wrap |

##### Removing a span — `stripBetweenPatterns`

Declare the two ends separately and SpecBinder locates the span for you:

```java
@Gherkin2JUnitOptions(
        stripBetweenPatterns = {
                @StripBetween(start = "<\\s*REMOVED\\b[^<>]*>", end = "</\\s*REMOVED\\b[^<>]*>")
        }
)
```

This is the safer way to delete a marked span, and worth preferring over expressing the same thing as one
`stripPatterns` regex. Writing `"(?is)<REMOVED[^<>]*>.*?</REMOVED[^<>]*>"` by hand has three failure modes
that all produce a **successful build with quietly wrong output**:

| Mistake | What happens |
|---|---|
| omitting `(?s)` | a span crossing a newline silently does not match |
| `.*` instead of `.*?` | the span runs to the **last** closing marker in the file, deleting everything between |
| an unclosed marker | no match, no error, no hint |

Declaring the ends separately removes the first two possibilities outright — the span is found by offset,
so no flag is needed to cross lines, and each `start` always pairs with the **nearest** following `end`.

##### Removing markers only — `stripPatterns`

Every match of every pattern is removed, so what the pattern matches decides what disappears:

```java
@Gherkin2JUnitOptions(
        stripPatterns = {"(?i)(<\\s*(NEW|CHANGED)\\s+[^<>]*>|</\\s*(NEW|CHANGED)\\b[^<>]*>)"}
)
```

A `stripPatterns` entry can also express a whole span, if you would rather keep everything in one option —
just mind the three traps above, and list span-matching patterns before marker-only ones.

##### Points worth knowing

Markup is removed everywhere it can appear: step text, Feature/Rule/Scenario names, descriptions, doc
strings, data tables and `Examples` tables — including **header cells**, where it would otherwise corrupt
generated field names and test method parameter names.

* **Keep marker patterns specific enough to miss `<placeholder>`.** Requiring whitespace and content after
  the keyword (`<\s*CHANGED\s+[^<>]*>`) is what stops a pattern from also matching a Scenario Outline
  placeholder such as `<changed>`. A looser pattern strips the placeholder, silently removing the step's
  parameter and changing the generated method signature.
* **Markers are not a balanced structure.** Each `stripPatterns` match is removed independently, so an
  unpaired marker is removed just the same, and a pair may wrap several steps without affecting what sits
  between them.
* **Nesting is not supported.** A second `start` appearing before the first `end` is simply consumed by the
  outer span.
* **An unclosed span leaves the text untouched.** A `stripBetweenPatterns` start with no following end
  removes nothing.
* **A span may wrap whole constructs** — several steps, an entire Scenario, or table rows. Markers on their
  own lines give the cleanest result; a span that starts or ends mid-line leaves the remainder of that line
  at column zero.
* **Emptied lines are dropped.** Any line left holding only whitespace once a match is removed disappears
  entirely, so deleting a table row does not leave a gap that would terminate the table. This shifts the
  source line numbers of everything below it, which affects `addSourceLineNumbers` output.
* **`stripBetweenPatterns` is applied before `stripPatterns`**, so a span still disappears wholesale even
  when a pattern would also have matched its markers individually. Within `stripPatterns`, entries are
  applied in the order declared.
* **A match that takes all of a step's text but leaves its keyword fails the build**, naming the line —
  include the step keyword inside the matched text instead.

> **Using the IntelliJ plugin?** Until the plugin applies the same patterns, a spec that relies on these
> options will show markup-bearing scenarios as permanently stale in the gutter, and Ctrl+Click from a
> markup-bearing Scenario title will not resolve.

---

## Installation

> **Requirements:** Java **21+**, JUnit 5, Maven/Gradle with **annotation processing** enabled, IDE with APT enabled (
> e.g., IntelliJ).

### Maven pom.xml configuration

```xml

<dependencies>
    <!-- Spec Binder annotations -->
    <dependency>
        <groupId>dev.specbinder</groupId>
        <artifactId>annotations</artifactId>
        <version>2026.39.0</version>
        <scope>test</scope>
    </dependency>

    <!-- Spec Binder annotation processor -->
    <dependency>
        <groupId>dev.specbinder</groupId>
        <artifactId>annotation-processor</artifactId>
        <version>2026.39.0</version>
        <scope>provided</scope>
    </dependency>
</dependencies>
```

### Recommended: place spec files next to Java sources

By default, Gherkin `.feature` / `.specb` files are placed under `src/test/resources/`. Consider placing them under
`src/test/java/` instead — in the same package as your marker classes. This makes it easy to navigate between the
annotated class and its spec file in the IDE, and keeps related files together.

<details>

<summary>Maven pom.xml configuration</summary>

To allow Maven to pick up `.feature` / `.specb` files from `src/test/java/`, add a test resource configuration to your `pom.xml`:

```xml
<build>
    <testResources>
        <testResource>
            <directory>src/test/java</directory>
            <includes>
                <include>**/*.feature</include>
                <include>**/*.specb</include>
            </includes>
        </testResource>
        <testResource>
            <directory>src/test/resources</directory>
        </testResource>
    </testResources>
</build>
```

</details>

<br/>

### Recommended: install the SpecBinder IntelliJ plugin

Install the **[SpecBinder plugin](https://plugins.jetbrains.com/plugin/30540-specbinder-beta-)** from the
JetBrains Marketplace. Among its features, the plugin:

* Registers `.specb` and `.feature` as dedicated file types with Gherkin syntax highlighting, so the IDE recognises them natively.
* **Automatically recompiles** the associated SpecBinder marker classes whenever you edit a gherkin spec file —
  no manual rebuild or file-watcher setup required.
* Displays **inline execution results** from the SpecBinder execution report directly in the gherkin spec file —
  including error panels with failure messages and exception details — so you can diagnose failures without
  switching between the spec and the test report.

---

## Contributing

Issues and feature requests welcome. When filing an issue, please include the `.feature` / `.specb` example, the generated code (from
`target/generated-sources`), and your build tool and JDK version.

### How this project is developed

The initial versions of Spec Binder were written in a traditional, manual way. Starting from January 2026, it
is developed in a **spec-driven** fashion with the help
of [Claude Code](https://docs.anthropic.com/en/docs/claude-code/overview). All implementation is driven by a Gherkin
specification that is authored first, following this iterative workflow:

```
                                                                                                                          ┌─── Claude Code Implements ───────────────┐
  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐  │  ┌────────────────┐  ┌────────────────┐  │  ┌────────────────┐
  │ Create new     │  │ Short prompt   │  │ Ask AI:        │  │ Ask AI:        │  │ Ask AI:        │  │ Ask AI:        │  │  │ Ask AI to TDD: │  │ implement      │  │  │ Review,        │
  │ .feature /     │─▶│ to AI to       │─▶│ to add         │─▶│ to derive      │─▶│ to add         │─▶│ add concrete   │─▶│  │ run test to    │─▶│ until GREEN    │  │─▶│ ask AI to      │
  │ .specb file    │  │ describe       │  │ plausible      │  │ User Story     │  │ plausible      │  │ Given/When/    │  │  │ see it fail    │  │ and no         │  │  │ refactor if    │
  │                │  │ the idea       │  │ Rule titles    │  │ narrative      │  │ Scenario titles│  │ Then steps     │  │  │ (RED)          │  │ regressions    │  │  │ needed, commit │
  └────────────────┘  └────────────────┘  └───────┬────────┘  └───────┬────────┘  └───────┬────────┘  └───────┬────────┘  │  └───────┬────────┘  └────────┬───────┘  │  └────────────────┘
                                              review &            review &            review &            review &        │          └─────────◀──────────┘          │
                                              refine              refine              refine              refine          └──────────────────────────────────────────┘
```

Each step of creating specification involves human review and judgement — Claude Code proposes, the developer decides.
This keeps the specification grounded in real requirements while leveraging AI to accelerate the drafting of rules,
scenarios, and step definitions. Once the specification is complete, Claude Code implements the required behavior
largely autonomously — running tests, writing code, and iterating until all tests pass with minimal developer
intervention.

Dedicated Claude Code slash commands for some of these workflow steps are available in `.claude/commands/`.

---

## Acknowledgements

Spec Binder stands on the shoulders of the [Cucumber](https://cucumber.io/) project. Under the hood, it relies on
Cucumber's [Gherkin parser](https://github.com/cucumber/gherkin) to read `.feature` / `.specb` files and on
the [cucumber-java](https://github.com/cucumber/cucumber-jvm) annotations library for optional `@Given`/`@When`/`@Then`
step matching. SpecBinder's own test suite is also built on top of the
[cucumber-java](https://github.com/cucumber/cucumber-jvm) framework. Credit goes to the Cucumber community for building
and maintaining these foundational tools that make Gherkin a widely adopted specification format.

---

## License

GNU General Public License v3.0
