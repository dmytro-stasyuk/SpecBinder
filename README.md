# Spec Binder

**Spec Binder** turns natural-language Gherkin specs into **pure JUnit** test code at **compile time**.
No regex “glue,” no runtime step discovery. Your `.feature` files become first-class Java code that compiles, runs, and fails fast.

> Built around an annotation-processor approach (`feature2junit`) that parses feature files during `javac`, generating JUnit test skeletons where each **Given/When/Then** is converted into a strongly-named Java method call.

---

## Why Spec Binder?

* **Compile-time safety:** Eliminates “undefined step” surprises at runtime—mismatches surface as **compiler errors**.

* **No regex glue:** Avoids brittle annotation regexes and accidental ambiguous matches.

* **Plain JUnit 5 (no Cucumber runner):** Generated tests are ordinary JUnit 5 test classes, making execution straightforward in IDEs and CI. Run or debug individual Scenarios/Rules, set breakpoints, and use Find Usages like with any other test.

* **Spec-driven automation:** The **text of your Feature** drives generated method names and call sequence. Steps are **per-feature**, not pulled from a global library.
  * **Unblocked formulation:** You don’t have to hunt for existing steps or bend wording to fit a catalog. Write the most natural Given/When/Then for each Feature; the generator creates feature-scoped step methods, avoiding the tendency to shoehorn newly discovered behaviour into ill-fitting steps.


* **TDD-friendly:** Enables straightforward, **iterative** test‑first development—before any application or even test code exists. Start with an abstract, implementation‑free spec (e.g., only Rule and/or Scenario titles). The generator creates a failing JUnit method for each empty Rule/Scenario, so you immediately have red tests to drive development.
  * **Iterate:** list Rules → add Scenario titles under the first Rule → pick one Scenario and add concrete steps in the Gherkin feature (still red; the generator turns them into failing step methods in the test) → implement those step methods → then implement just enough application code to make it pass (green) → repeat for the next Scenario. When all Scenarios under a Rule are green, move on to the next Rule.
  * **Keep discovering:** As implementation reveals new cases, jot them down as additional `Rule` or `Scenario` titles; they immediately appear as failing tests, ready for red→green.

---

## How it works (at a glance)

1. Create an **abstract marker class** annotated with `@Feature2JUnit("relative/path/to.feature")` — this points the annotation processor at the feature.
2. During compilation, `feature2junit` parses the feature and generates:

   * An **abstract JUnit test class** (one per feature).
   * For each Scenario, a `@Test` method that calls **per-step methods** derived from step text.
   * Parts of step's text that are wrapped in double quotes become step method arguments. [Doc Strings](https://cucumber.io/docs/gherkin/reference/#doc-strings) and [Data Tables](https://cucumber.io/docs/gherkin/reference/#data-tables) are also supported. 
   * Gherkin `Rule` elements are generated as nested test classes, and `Rule` and `Scenario` titles populate JUnit's `@DisplayName` annotations.
   * Each step method is generated as **abstract** (no body).
3. You create a subclass extending the generated abstract test class and implement the abstract step methods.

---

## Usage example

1. **Create or place** a `.feature` file under your chosen directory (e.g., `src/test/resources/specs/...`).

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

2. **Add a marker class** annotated with `@Feature2JUnit("specs/cart.feature")`.

```java
package org.mycompany.app;

import dev.specbinder.feature2junit.Feature2JUnit;

@Feature2JUnit("specs/cart.feature")
public abstract class CartFeature {
    // Marker class: no members required
}
```

2. **Build** the project. The generator writes JUnit sources under your build's generated-sources dir.
3. **Implement the step methods:**

* First compile: the generator produces an **abstract** test class; each step method is **abstract** (no body).

* You create a subclass and implement the step methods.

* Rebuild and run; the subclass is executed by JUnit.

<details>
 
<summary>Generated class:</summary>

```java
package org.mycompany.app;

import dev.specbinder.annotations.output.FeatureFilePath;
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
 * To implement tests in this generated class, extend it and implement all abstract methods.
 */
@Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@TestClassOrder(ClassOrderer.OrderAnnotation.class)
@FeatureFilePath("specs/cart.feature")
public abstract class CartFeatureScenarios extends CartFeature {
    {
        /**
         * Feature: online shopping cart
         */
    }

    public abstract void givenMyCartContains$p1WithQuantity$p2AndUnitPrice$p3(String p1, String p2, String p3);

    public abstract void whenIChangeTheQuantityTo$p1(String p1);

    public abstract void thenMyCartSubtotalIs$p1(String p1);

    @Test
    @Order(1)
    @DisplayName("Scenario: update quantity updates subtotal")
    public void scenario_1() {
        /**
         * Given my cart contains "Wireless Headphones" with quantity "1" and unit price "60.00"
         */
        givenMyCartContains$p1WithQuantity$p2AndUnitPrice$p3("Wireless Headphones", "1", "60.00");
        /**
         * When I change the quantity to "2"
         */
        whenIChangeTheQuantityTo$p1("2");
        /**
         * Then my cart subtotal is "120.00"
         */
        thenMyCartSubtotalIs$p1("120.00");
    }

    public abstract void givenMyCartSubtotalIs$p1(String p1);

    public abstract void whenIViewTheCart();

    public abstract void thenISeeThe$p1Banner(String p1);

    @Nested
    @Order(1)
    @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
    @DisplayName("Rule: free shipping applies to orders over €50")
    public class Rule_1 {
        @Test
        @Order(1)
        @DisplayName("Scenario: show free-shipping banner when threshold is met")
        public void scenario_1() {
            /**
             * Given my cart subtotal is "55.00"
             */
            givenMyCartSubtotalIs$p1("55.00");
            /**
             * When I view the cart
             */
            whenIViewTheCart();
            /**
             * Then I see the "Free shipping" banner
             */
            thenISeeThe$p1Banner("Free shipping");
        }
    }
}
```

</details>

<details>

<summary>Your implementation:</summary>

```java
package org.mycompany.app;

public class CartFeatureTest extends CartFeatureScenarios {

    @Override
    public void givenMyCartContains$p1WithQuantity$p2AndUnitPrice$p3(String p1, String p2, String p3) {
       /* real implementation here */
    }

    @Override
    public void whenIChangeTheQuantityTo$p1(String p1) {
       /* real implementation here */
    }

    @Override
    public void thenMyCartSubtotalIs$p1(String p1) {
       /* real implementation here */
    }

    @Override
    public void givenMyCartSubtotalIs$p1(String p1) {
        /* real implementation here */
    }

    @Override
    public void whenIViewTheCart() {
        /* real implementation here */
    }

    @Override
    public void thenISeeThe$p1Banner(String p1) {
        /* real implementation here */
    }
}
```

</details>

---

## Details of mapping Gherkin → Jnit  

All elements of [Gherkin](https://cucumber.io/docs/gherkin/reference/) are supported, please refer to below sections for details

### Primary keywords:

<details>

<summary>Feature</summary>

+ The feature’s keyword, title, and description lines appear in a block comment at the top of the generated class.

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
 public class CartFeatureScenarios extends CartFeature {
    {
        /**
         * Feature: Shopping cart totals and shipping
         *   As a shopper
         *   I want the cart to keep item totals accurate and show free shipping when eligible
         *   So that I can check out with confidence and avoid extra costs
         */
    }
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
public class CartFeatureScenarios extends CartFeature {
    {
        /**
         * Feature: Shopping cart totals and shipping
         */
    }

    @Nested
    @Order(1)
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

public class CartFeatureScenarios extends CartFeature {
    {
        /**
         * Feature: Shopping cart totals and shipping
         */
    }

    @Test
    @Order(1)
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

#### Step keywords → method prefixes

+ Given … → method starts with given…

+ When … → when…

+ Then … → then…

+ And … / But … → inherit the previous step’s keyword (e.g., after a When, And becomes when…)

#### Method name derivation (from step text)

+ Take the step’s **plain text** (minus any quoted arguments), split into words, and **CamelCase** them.

+ **Invalid Java identifier** characters (at the start or in the middle) are **removed**.

+ The keyword prefix (`given/when/then`) is prepended.

+ Where the step had quoted arguments, the method name includes **positional placeholders** to indicate argument slots (e.g., `$p1`, `$p2`, …).

> Resulting shape: 
`given` + `CamelCasedWordsAroundArgsWithPlaceholders`
> 
> e.g., `givenMyCartContains$p1WithQuantity$p2AndUnitPrice$p3(...)` 

#### Quoted arguments → method parameters & call sites

+ Every "**&lt;value&gt;**" in the step becomes a String parameter (current support is String only).

+ The quoted values are removed from the method name and passed as arguments from the generated scenario method in left-to-right order.

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

// Generated step methods (signatures)
void givenMyCartContains$p1WithQuantity$p2AndUnitPrice$p3(String p1, String p2, String p3);
void whenIChangeTheQuantityTo$p1(String p1);
void thenMyCartSubtotalIs$p1(String p1);

// Generated scenario method (calls)
givenMyCartContains$p1WithQuantity$p2AndUnitPrice$p3("Wireless Headphones", "1", "60.00");
whenIChangeTheQuantityTo$p1("2");
thenMyCartSubtotalIs$p1("120.00");

```
 
</code></pre></td>
</tr>
</table>

+ The original textual representation of each of the step methods is placed into a block java comment above each method call to aid readability

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

public abstract class CartFeatureScenarios extends CartFeature {
    {
        /**
         * Feature: Shopping cart totals and shipping
         */
    }

    public abstract void givenMyCartContains$p1WithQuantity$p2AndUnitPrice$p3(String p1, String p2,
            String p3);

    public abstract void whenIChangeTheQuantityTo$p1(String p1);

    public abstract void thenMyCartSubtotalIs$p1(String p1);

    @Test
    @Order(1)
    @DisplayName("Scenario: Update quantity updates subtotal")
    public void scenario_1() {
        /**
         * Given my cart contains "Wireless Headphones" with quantity "1" and unit price "60.00"
         */
        givenMyCartContains$p1WithQuantity$p2AndUnitPrice$p3("Wireless Headphones", "1", "60.00");
        /**
         * When I change the quantity to "2"
         */
        whenIChangeTheQuantityTo$p1("2");
        /**
         * Then my cart subtotal is "120.00"
         */
        thenMyCartSubtotalIs$p1("120.00");
    }

    public abstract void givenMyCartSubtotalIs$p1(String p1);

    public abstract void whenIViewTheCart();

    public abstract void thenISeeThe$p1Banner(String p1);

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
            givenMyCartSubtotalIs$p1("55.00");
            /**
             * When I view the cart
             */
            whenIViewTheCart();
            /**
             * Then I see the "Free shipping" banner
             */
            thenISeeThe$p1Banner("Free shipping");
        }
    }
}

```
 
</code></pre></td>
</tr>
</table>

#### Limited support for using '*' as step keyword

+ Currently if you use the '*' character in place of Given/When/Then/And/But step keywords - the generation will work in some cases and in
other cases it may fail - so this type of usage is discoraged. 

#### DocStrings & Data Tables (if present)

+ They don’t change the method-naming rules above.

+ They’re passed along to the step method (appended after quoted String params).

+ See below sections for examples of how these are passed down to step method calls.
 
</details>

<details>

<summary>Background</summary>

#### Rules

* **Lifecycle hook:** Every `Background` becomes a `@BeforeEach` method that runs **before each Scenario** (and Example row).

* **Feature-level Background:** A `Background` declared **before any** `Rule` **or** `Scenario` is generated as a member method of the outer test class.

* **Rule-level Background:** A `Background` declared as the **first element inside a** `Rule` is generated as a member method of that `@Nested` rule class.

* **Display name:** If the `Background` has a **title** (text on the same line as `Background:`), that title is used in a `@DisplayName` on the generated `@BeforeEach` method.

* **Description lines:** If the `Background` has description lines under it, they are emitted as a **JavaDoc comment** above the generated `@BeforeEach` method.

* **Steps inside Background:** The body of the `@BeforeEach` method **calls the generated step methods** in the same order, using the same string-argument extraction rules as normal steps (text in quotes → `String` parameters).

#### Order of execution (Feature + Rule)

If both a **feature-level** and a **rule-level** `Background` exist, JUnit 5 runs the outer class’s `@BeforeEach` **first**, then the nested rule class’s `@BeforeEach`, then the scenario’s test method.
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

public abstract class CartFeatureScenarios extends CartFeature {
    {
        /**
         * Feature: Shopping cart totals and shipping
         */
    }

    public abstract void givenIAmASignedinShopper$p1(String p1);

    public abstract void givenMyCartIsEmpty();

    public abstract void givenTheCurrencyIs$p1(String p1);

    /**
     * Ensures cart and session are reset before each test.
     */
    @BeforeEach
    @DisplayName("Background: Start with a clean cart")
    public void featureBackground(TestInfo testInfo) {
        /**
         * Given I am a signed-in shopper "alice@example.com"
         */
        givenIAmASignedinShopper$p1("alice@example.com");
        /**
         * And my cart is empty
         */
        givenMyCartIsEmpty();
        /**
         * And the currency is "EUR"
         */
        givenTheCurrencyIs$p1("EUR");
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

public abstract class CartFeatureScenarios extends CartFeature {
    {
        /**
         * Feature: Shopping cart totals and shipping
         */
    }

    public abstract void givenMyCartSubtotalIs$p1(String p1);

    @Nested
    @Order(1)
    @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
    @DisplayName("Rule: Free shipping applies when subtotal is at least €50")
    public class Rule_1 {
        @BeforeEach
        @DisplayName("Background: sets up a cart close to the free-shipping threshold.")
        public void ruleBackground(TestInfo testInfo) {
            /**
             * Given my cart subtotal is "45.00"
             */
            givenMyCartSubtotalIs$p1("45.00");
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

@Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@TestClassOrder(ClassOrderer.OrderAnnotation.class)
@FeatureFilePath("specs/cart.feature")
public abstract class CartFeatureScenarios extends CartFeature {
    {
        /**
         * Feature: Shopping cart totals and shipping
         */
    }

    public abstract void givenIAmASignedinShopper$p1(String p1);

    public abstract void givenMyCartIsEmpty();

    @BeforeEach
    @DisplayName("Background: Start with a clean cart")
    public void featureBackground(TestInfo testInfo) {
        /**
         * Given I am a signed-in shopper "alice@example.com"
         */
        givenIAmASignedinShopper$p1("alice@example.com");
        /**
         * And my cart is empty
         */
        givenMyCartIsEmpty();
    }

    public abstract void givenTheCurrencyIs$p1(String p1);

    public abstract void givenMyCartSubtotalIs$p1(String p1);

    public abstract void whenIViewTheCart();

    public abstract void thenISeeThe$p1Banner(String p1);

    @Nested
    @Order(1)
    @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
    @DisplayName("Rule: Free shipping applies when subtotal is at least €50")
    public class Rule_1 {
        @BeforeEach
        @DisplayName("Background: ")
        public void ruleBackground(TestInfo testInfo) {
            /**
             * Given the currency is "EUR"
             */
            givenTheCurrencyIs$p1("EUR");
            /**
             * And my cart subtotal is "55.00"
             */
            givenMyCartSubtotalIs$p1("55.00");
        }

        @Test
        @Order(1)
        @DisplayName("Scenario: Show free-shipping banner when threshold is met")
        public void scenario_1() {
            /**
             * When I view the cart
             */
            whenIViewTheCart();
            /**
             * Then I see the "Free shipping" banner
             */
            thenISeeThe$p1Banner("Free shipping");
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
@ParameterizedTest(name = "Example {index}: [{arguments}]")
@CsvSource(
    useHeadersInDisplayName = true,
    delimiter = '|',
    textBlock = """
            name                | startQty | price | newQty | expectedSubtotal
            Wireless Headphones | 1        | 60.00 | 2      | 120.00
            Coffee Beans 1kg    | 2        | 15.50 | 3      | 46.50
            """
)
@DisplayName("Scenario: Subtotal updates when quantity changes")
public void scenario_1(String name, String startQty, String price, String newQty, String expectedSubtotal) { ... }
```

#### 2) `Examples` table → `@CsvSource(textBlock = …)`

* The `Examples` rows are embedded as a **CSV text block** inside `@CsvSource`.

* The **column order** in the table becomes the **parameter order** in the test method.

* The **header row** supplies the **parameter names** (`name`, `startQty`, `price`, `newQty`, `expectedSubtotal`) after being sanitized into valid Java identifiers (spaces/punctuation removed, etc.).

* The **cell delimiter** mirrors the table separator (`|`), specified via `delimiter = '|'`.

* The display name pattern `name = "Example {index}: [{arguments}]"` makes IDE/CI output like:
  `Example 1: [12, 5, 7]`, `Example 2: [20, 5, 15]`.

#### 3) Placeholders `<…>` in steps → argument variables

* Each placeholder in the outline text (e.g., `<name>`, `<startQty>`, `<price>`, `<newQty>`, `<expectedSubtotal>`) becomes a **method parameter** on the parameterized test.

* Inside the test body, the generated calls **pass those variables** in left-to-right order to the step methods:

```java
givenMyCartContains$p1WithQuantity$p2AndUnitPrice$p3(name, startQty, price);

whenIChangeTheQuantityTo$p1(newQty);

thenMyCartSubtotalIs$p1(expectedSubtotal);
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

public abstract class CartFeatureScenarios extends CartFeature {
    {
        /**
         * Feature: Shopping cart totals and shipping
         */
    }

    public abstract void givenMyCartContains$p1WithQuantity$p2AndUnitPrice$p3(String p1, String p2,
            String p3);

    public abstract void whenIChangeTheQuantityTo$p1(String p1);

    public abstract void thenMyCartSubtotalIsExpectedsubtotal();

    @ParameterizedTest(
            name = "Example {index}: [{arguments}]"
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
    public void scenario_1(String name, String startqty, String price, String newqty,
            String expectedSubtotal) {
        /**
         * Given my cart contains <name> with quantity <startQty> and unit price <price>
         */
        givenMyCartContains$p1WithQuantity$p2AndUnitPrice$p3(name, startqty, price);
        /**
         * When I change the quantity to <newQty>
         */
        whenIChangeTheQuantityTo$p1(newqty);
        /**
         * Then my cart subtotal is <expectedSubtotal>
         */
        thenMyCartSubtotalIsExpectedsubtotal();
    }
}

```

</code></pre></td>
</tr>
</table>


#### Edge cases & notes

* **Multiple `Examples` blocks:** Currently not supported. The generator expects exactly one `Examples` block per `Scenario Outline`; specifying more than one will cause conversion to fail with an error.

* **Header sanitization:** If a header isn’t a valid Java identifier (e.g., `start qty`), it’s sanitized to something like `startQty`.

* **Empty cells / quoting:** Empty cells are passed as empty strings. Cells containing separators or spaces are handled by the CSV parser; text blocks keep formatting readable.

* **Types:** Current generator emits `String` parameters only; you can parse/convert inside your step methods.
 
</details>

### Secondary keywords:

<details>

<summary>Doc Strings (""") </summary>

#### Rules

* A step with a **DocString** gains **one trailing** `String` **parameter** (after any quoted args).

* **Method naming is unaffected** by the DocString (no extra `$p…` placeholder in the name).

* The **DocString body** (the lines between the triple quotes) is passed **verbatim**: newlines and indentation are **preserved**.

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

abstract void whenISubmitAShippingAddress(String docString);

whenISubmitAShippingAddress("""
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

abstract void givenIAddItem$p1WithOptions(String p1, String docString);

givenIAddItem$p1WithOptions("Wireless Headphones", """
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

#### What the generator emits

* **Step parameter type:** A step that has a Gherkin **Data Table** receives **one trailing parameter of type** `io.cucumber.datatable.DataTable`.

  * If the step also has **quoted arguments**, those come **first** (as `String`s), and the `DataTable` comes **last**.
    
* **Call site:** The scenario (or Background) calls the step with a helper:
  * The generator includes a `createDataTable(String tableLines)` method that parses a **pipe-delimited Java text block** into a rectangular `List<List<String>>`, then calls `DataTable.create(...)`. If you already have a method with this name in your marker/base test class then generation of this method is omitted and your method is called instead.
  * It also declares a `protected abstract DataTable.TableConverter getTableConverter()` that your implementation must provide. This lets your step code later use `asList(...)`, etc., if you want typed conversions.

**Example:**

<table>
  <tr>
    <th align="left">Gherkin</th>
    <th align="left">Generated signature & call</th>
  </tr>
  <tr>
    <td valign="top" class="diffTable" style="padding: 0px; font-size: larger;"><pre><code class="language-gherkin" data-lang="gherkin">

```gherkin

Feature: Shopping cart totals and shipping

  Background:
    Given my cart contains:
      | name                | qty | price |
      | Wireless Headphones | 1   | 60.00 |
      | Coffee Beans 1kg    | 2   | 15.50 |

```

  </code></pre>
    </td>
    <td valign="top">
     <pre>
       <code class="language-java" data-lang="java">

```java

public abstract class CartFeatureScenarios extends CartFeature {
    {
        /**
         * Feature: Shopping cart totals and shipping
         */
    }

    public abstract void givenMyCartContains(DataTable dataTable);

    @BeforeEach
    @DisplayName("Background: ")
    public void featureBackground(TestInfo testInfo) {
        /**
         * Given my cart contains:
         */
        givenMyCartContains(createDataTable("""
                |name               |qty|price|
                |Wireless Headphones|1  |60.00|
                |Coffee Beans 1kg   |2  |15.50|
                """));
    }

    protected abstract DataTable.TableConverter getTableConverter();

    /**
     * Generation of this method is skipped if you already have it in your marker/base class.
     * 
     * @param tableLines the table lines as in the feature file
     * @return DataTable instance
     */
    protected DataTable createDataTable(String tableLines) {

        String[] tableRows = tableLines.split("\\n");
        List<List<String>> rawDataTable = new ArrayList<>(tableRows.length);

        for (String tableRow : tableRows) {
            String trimmedLine = tableRow.trim();
            if (!trimmedLine.isEmpty()) {
                String[] columns = trimmedLine.split("\\|");
                List<String> rowColumns = new ArrayList<>(columns.length);
                for (int i = 1; i < columns.length; i++) {
                    String column = columns[i].trim();
                    rowColumns.add(column);
                }
                rawDataTable.add(rowColumns);
            }
        }

        DataTable dataTable = DataTable.create(rawDataTable, getTableConverter());
        return dataTable;
    }
}

```

</code></pre></td>
</tr>
</table>

#### What this means in practice

* **No “List<Map<…>>” in the signature.** The generator **always** passes a `DataTable`. You decide in your step how to consume it.
* **Cells are strings**. The helper **trims** each cell; otherwise values are untouched. There’s **no automatic typing**.
* **Header vs raw** is **up to your step**: if your first row is a header, treat it as such in your implementation.

**Example implementation** of `getTableConverter()` and mapping to an object type using `DataTableTypeRegistry` facility from the `cucumber-java` library.

```java

package org.mycompany.app;

import io.cucumber.datatable.DataTable;
import io.cucumber.datatable.DataTableType;
import io.cucumber.datatable.DataTableTypeRegistry;
import io.cucumber.datatable.DataTableTypeRegistryTableConverter;

import java.util.Locale;
import java.util.Map;

public class CartFeatureTest extends CartFeatureScenarios {

    protected DataTableTypeRegistry dataTableRegistry;

    protected DataTable.TableConverter tableConverter;

    public CartFeatureTest() {

        dataTableRegistry = new DataTableTypeRegistry(Locale.ENGLISH);

        dataTableRegistry.defineDataTableType(new DataTableType(
                CartItem.class,
                (Map<String, String> row) ->
                        new CartItem(
                                row.get("name"),
                                Integer.parseInt(row.get("qty")),
                                Double.parseDouble(row.get("price"))
                        ))
        );
        tableConverter = new DataTableTypeRegistryTableConverter(dataTableRegistry);

    }

    @Override
    protected DataTable.TableConverter getTableConverter() {
        return tableConverter;
    }
}

```
 
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

import dev.specbinder.annotations.output.FeatureFilePath;

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

@Tags({
        @Tag("fast"),
        @Tag("cart")
})
@Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@TestClassOrder(ClassOrderer.OrderAnnotation.class)
@FeatureFilePath("specs/cart.feature")
public class CartFeatureScenarios extends CartFeature {
    {
        /**
         * Feature: Shopping cart totals and shipping
         */
    }

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
            givenMyCartSubtotalIs$p1("55.00");
            /**
             * When I view the cart
             */
            whenIViewTheCart();
            /**
             * Then I see the "Free shipping" banner
             */
            thenISeeThe$p1Banner("Free shipping");
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

* **Ignored by the processor:** Lines that are comments in Gherkin (i.e., lines starting with `#`) are **not mapped** to JUnit in any way. They are skipped during generation.
* **Where to put narrative instead:** If you need human‑readable context preserved in Java, use `Feature`/`Rule`/`Scenario`/`Background` **descriptions** (indented lines under the header)—those are emitted into JavaDoc/`@DisplayName` as documented in sections above.
 
</details>

---

## Configuration

All configuration is provided via the `@Feature2JUnitOptions` annotation. You can place this annotation:

* **On the marker class** (applies to that feature only).
* **On a shared base test class** (options are **inherited** by subclasses/marker classes in your test hierarchy).

The generated test class is always **abstract** with abstract step methods. Various options are available to customize the code generation behavior. For the complete list of options and defaults, refer to the `@Feature2JUnitOptions` JavaDoc or the annotation source code.

<details>

<summary>Example — per‑feature options on the marker class</summary>

```java
import dev.specbinder.feature2junit.Feature2JUnit;
import dev.specbinder.feature2junit.Feature2JUnitOptions;

@Feature2JUnitOptions( /* customize generation options as needed */ )
@Feature2JUnit("specs/cart.feature")
public abstract class CartFeature { }
```

</details>

<details>

 <summary>Example — inherited options via a base class</summary>

```java
import dev.specbinder.feature2junit.Feature2JUnit;
import dev.specbinder.feature2junit.Feature2JUnitOptions;

@Feature2JUnitOptions( /* shared options for all features */ )
public abstract class BaseFeatureOptions { }

@Feature2JUnit("specs/cart.feature")
public abstract class CartFeature extends BaseFeatureOptions { }
```

</details>

---

## Installation

> **Requirements:** Java **17+**, JUnit 5, Maven/Gradle with **annotation processing** enabled, IDE with APT enabled (e.g., IntelliJ).
>
> **Optional:** The `cucumber-java` library is **not required by default**. You only need to add it as a dependency if you want to map Gherkin data tables to instances of Cucumber's `io.cucumber.datatable.DataTable` type. For an example of this usage, see the [example-2 module README](examples/examples-feature-processor/example-2/README.md) and its `pom.xml`. 

<details>

<summary>Maven example</summary>

```xml
<dependencies>
  <!-- Spec Binder annotations -->
  <dependency>
    <groupId>dev.specbinder</groupId>
    <artifactId>annotations</artifactId>
    <version>0.1.9</version>
    <scope>test</scope>
  </dependency>

  <!-- Spec Binder annotation processor -->
  <dependency>
    <groupId>dev.specbinder</groupId>
    <artifactId>feature-processor</artifactId>
    <version>0.1.9</version>
    <scope>test</scope>
  </dependency>
</dependencies>
```

</details>

---

## What it is / What it isn’t

**It is**

* A **compile-time** bridge from Gherkin to **plain JUnit**.
* A per-feature, spec-driven test skeleton generator.

**It isn’t**

* A Cucumber/JBehave runner (no runtime step discovery, no regex glue).
* A shared step catalog. Steps are **scoped to a feature** by design.

---

## Limitations

**Language Support**

* **English only:** Gherkin feature files must use English step keywords and text. Since Java method signatures are derived directly from step text (e.g., `Given I add item "X"` becomes `givenIAddItem$p1(String p1)`), non-English characters or keywords cannot be reliably converted into valid Java identifiers. Using other natural languages in step text will result in compilation errors or invalid method names.

---

## Contributing

Issues and PRs welcome. Please include:

* The `.feature` example
* The generated code (from `target/generated-sources`)
* Your build tool and JDK version

---

## License

GNU General Public License v3.0

---

## Appendix: Cucumber/JBehave vs Spec Binder

| Topic                     | Cucumber/JBehave                                              | Spec Binder                                         |
| ------------------------- | ------------------------------------------------------------- |-----------------------------------------------------|
| Wiring                    | Regex in annotations; runtime discovery                       | **Compile-time** generated JUnit                    |
| Failure surface           | Often runtime “undefined step”                                | **Compiler errors** on mismatch                     |
| Step scope                | Shared/global libraries                                       | **Per-feature scoped**                              |
| Step refactoring strategy | Search & replace text (often via complex regular expressions) | Compiler errors, method rename & inline refactoring |
| Test Runner               | Custom runner & plugins                                       | Plain JUnit                                         |
|                           |                                                               |                                                     |
