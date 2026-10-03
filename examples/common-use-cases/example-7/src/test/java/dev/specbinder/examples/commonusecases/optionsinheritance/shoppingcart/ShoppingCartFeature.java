package dev.specbinder.examples.commonusecases.optionsinheritance.shoppingcart;

import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.examples.commonusecases.optionsinheritance.BaseFeature;

/**
 * Inherits all options from BaseFeature — no override needed:
 * - useStepKeywordInStepMethodName = true   ← inherited: givenIHaveAnEmptyShoppingCart, not iHaveAnEmptyShoppingCart
 * - classSuffixIfAbstract = "Spec"          ← inherited: generates ShoppingCartSpec
 *
 * No path in @Gherkin2JUnit — the processor discovers the co-located
 * ShoppingCart.specb in this package by convention.
 */
@Gherkin2JUnit
public abstract class ShoppingCartFeature extends BaseFeature {
}
