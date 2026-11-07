# Example 10: Localization

Demonstrates writing specs with **non-English and team-defined keywords**. The same card-payment checkout is specified
four times — with German keywords, French keywords, German keywords plus a team's own words, and English keywords
opened by a `Narrative:` heading — and every spec runs against the same in-memory `Checkout` class.

## What this demonstrates

- `@Gherkin2JUnitOptions(keywordLanguages = {KeywordLanguage.GERMAN})` lets every spec the marker discovers use German
  keywords, so `Kasse.specb` needs no header and can start with `Funktionalität:`
- A `# language: fr` header selects French for one spec file and wins over `keywordLanguages`, so `Caisse.specb` sits
  under the same German marker and still reads as French
- One bare `@Gherkin2JUnit` marker generating a class for each spec in its package — `Kasse` produces both
  `KasseScenarios` and `CaisseScenarios`
- `@KeywordSynonym` adding a word next to a keyword's usual words — `Vorausgesetzt` becomes a Given keyword alongside
  `Angenommen` and `Gegeben sei`
- `@KeywordSynonym(..., replace = true)` making a word a keyword's only word — `Geschäftsregel` is the sole Rule
  keyword in `KasseMitSynonymen.specb`, so `Regel:` no longer starts a Rule there
- Options inherited from a base marker — `KasseMitSynonymen` extends `Kasse`, keeps its German keywords and adds the
  synonyms on top
- A synonym for an English keyword — `CheckoutNarrative` adds `Narrative` as a Feature keyword, so the spec opens with
  a user story under a `Narrative:` heading

## The specs

| Spec | How it selects keywords |
|---|---|
| [Kasse.specb](src/test/java/dev/specbinder/examples/goingfurther/localization/Kasse.specb) | `Kasse` sets German with `keywordLanguages`, so the spec can start with `Funktionalität:` |
| [Caisse.specb](src/test/java/dev/specbinder/examples/goingfurther/localization/Caisse.specb) | The same marker discovers this spec, whose `# language: fr` header selects French |
| [KasseMitSynonymen.specb](src/test/java/dev/specbinder/examples/goingfurther/localization/synonyms/KasseMitSynonymen.specb) | `KasseMitSynonymen` inherits German from `Kasse`, adds `Vorausgesetzt` as a Given keyword, and uses `Geschäftsregel` as the Rule keyword |
| [CheckoutNarrative.specb](src/test/java/dev/specbinder/examples/goingfurther/localization/narrative/CheckoutNarrative.specb) | `CheckoutNarrative` adds `Narrative` as a Feature synonym and opens the spec with a three-line user story |

## Structure

A bare `@Gherkin2JUnit` reads every spec in its own package, but not in sub-packages. Each marker with its own options
therefore gets a package of its own — left in the main package, `Kasse` would also read `KasseMitSynonymen.specb`
and `CheckoutNarrative.specb`, without the synonyms those specs are written in.

```
src/test/java/.../localization/
  ├── Kasse.java                     ← marker; German keywords for every spec in this package
  ├── Kasse.specb                    ← German keywords from the marker
  ├── KasseTest.java
  ├── Caisse.specb                   ← French keywords from its own header
  ├── CaisseTest.java
  ├── Checkout.java                  ← tiny in-memory checkout shared by every test
  ├── synonyms/
  │   ├── KasseMitSynonymen.java     ← marker; extends Kasse, adds the German synonyms
  │   ├── KasseMitSynonymen.specb
  │   └── KasseMitSynonymenTest.java
  └── narrative/
      ├── CheckoutNarrative.java     ← marker; English keywords plus the Narrative synonym
      ├── CheckoutNarrative.specb
      └── CheckoutNarrativeTest.java
```

## Class hierarchy

```
Kasse.java                                (marker, @Gherkin2JUnit + keywordLanguages = GERMAN)
  ├→ KasseScenarios.java                  (generated from Kasse.specb, abstract)
  │   └→ KasseTest.java                   (your concrete class, implements the steps)
  ├→ CaisseScenarios.java                 (generated from Caisse.specb, abstract)
  │   └→ CaisseTest.java                  (your concrete class, implements the steps)
  └→ KasseMitSynonymen.java               (marker, @Gherkin2JUnit + keywordSynonyms; inherits German)
      └→ KasseMitSynonymenScenarios.java  (generated, abstract)
          └→ KasseMitSynonymenTest.java   (your concrete class, implements the steps)

CheckoutNarrative.java                    (marker, @Gherkin2JUnit + keywordSynonyms; English keywords)
  └→ CheckoutNarrativeScenarios.java      (generated, abstract)
      └→ CheckoutNarrativeTest.java       (your concrete class, implements the steps)
```

## The marker classes

```java
@Gherkin2JUnit
@Gherkin2JUnitOptions(keywordLanguages = {KeywordLanguage.GERMAN})
public abstract class Kasse {
}
```

```java
@Gherkin2JUnit
@Gherkin2JUnitOptions(keywordSynonyms = {
        @KeywordSynonym(keyword = GherkinKeyword.RULE, synonyms = "Geschäftsregel", replace = true),
        @KeywordSynonym(keyword = GherkinKeyword.GIVEN, synonyms = "Vorausgesetzt")
})
public abstract class KasseMitSynonymen extends Kasse {
}
```

`KasseMitSynonymen` sets only `keywordSynonyms`, so `keywordLanguages` still comes from `Kasse`. The synonyms apply on
top of whichever language a spec is read in — the marker's languages or a `# language:` header alike.

## Generated output (excerpt)

`KasseMitSynonymenScenarios` keeps the spec's own words in every display name, while the step methods leave the
keyword out — `Vorausgesetzt ein Warenkorb mit "2" Artikeln` becomes the same `einWarenkorbMit$p1Artikeln` that
`Gegeben sei ein Warenkorb mit "2" Artikeln` produces in `KasseScenarios`. Generated Java names such as `Rule_1` and
`rule_1_scenario_1()` stay English.

```java
@DisplayName("Funktionalität: Kasse")
public abstract class KasseMitSynonymenScenarios extends KasseMitSynonymen {
    public abstract void einWarenkorbMit$p1Artikeln(Integer p1);
    // ...

    @Nested
    @DisplayName("Geschäftsregel: Kartenzahlung")
    public class Rule_1 {
        @Test
        @DisplayName("Szenario: Mit Karte bezahlen")
        public void rule_1_scenario_1() {
            /*
             * Vorausgesetzt ein Warenkorb mit "2" Artikeln
             */
            einWarenkorbMit$p1Artikeln(2);
            // ...
        }
    }
}
```

## Files

| File | Purpose |
|------|---------|
| `src/test/java/.../Kasse.java` | Marker class selecting German keywords for the specs in its package |
| `src/test/java/.../Kasse.specb` | Checkout spec with German keywords |
| `src/test/java/.../KasseTest.java` | Concrete test implementing the German steps |
| `src/test/java/.../Caisse.specb` | Checkout spec with a `# language: fr` header and French keywords |
| `src/test/java/.../CaisseTest.java` | Concrete test implementing the French steps |
| `src/test/java/.../Checkout.java` | Tiny in-memory checkout used by every test |
| `src/test/java/.../synonyms/KasseMitSynonymen.java` | Marker class extending `Kasse` and adding the German synonyms |
| `src/test/java/.../synonyms/KasseMitSynonymen.specb` | German checkout spec using `Geschäftsregel` and `Vorausgesetzt` |
| `src/test/java/.../synonyms/KasseMitSynonymenTest.java` | Concrete test implementing the steps of the synonym spec |
| `src/test/java/.../narrative/CheckoutNarrative.java` | Marker class adding `Narrative` as a Feature keyword |
| `src/test/java/.../narrative/CheckoutNarrative.specb` | English checkout spec opened by a `Narrative:` user story |
| `src/test/java/.../narrative/CheckoutNarrativeTest.java` | Concrete test implementing the English steps |

## Run it

With Java 21 or newer and the local SpecBinder snapshot installed:

```bash
cd examples/going-further/example-10
mvn test
```

All four scenarios should pass; a failure fails the build. The generated classes are in
`target/generated-test-sources/test-annotations/`.
