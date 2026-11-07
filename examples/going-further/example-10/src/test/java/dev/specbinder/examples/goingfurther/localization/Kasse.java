package dev.specbinder.examples.goingfurther.localization;

import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.annotations.Gherkin2JUnitOptions;
import dev.specbinder.annotations.KeywordLanguage;

/**
 * Marker class selecting German keywords for the specs in this package; the step methods live in KasseTest and
 * CaisseTest.
 * <p>
 * {@code keywordLanguages = GERMAN} lets a spec without a {@code # language:} header use German keywords, so
 * Kasse.specb starts with {@code Funktionalität:}. A header always wins over the option: Caisse.specb opens with
 * {@code # language: fr} and is read as French although this marker selects German.
 * <p>
 * {@code @Gherkin2JUnitOptions} is inherited, so KasseMitSynonymen extends this class to keep the German keywords and
 * add its own synonyms on top.
 * <p>
 * No path in @Gherkin2JUnit — the processor discovers every spec in this package by convention and generates a class
 * for each: KasseScenarios from Kasse.specb and CaisseScenarios from Caisse.specb. Specs that need other options live
 * in the {@code synonyms} and {@code narrative} sub-packages, which this marker does not read.
 */
@Gherkin2JUnit
@Gherkin2JUnitOptions(keywordLanguages = {KeywordLanguage.GERMAN})
public abstract class Kasse {
}
