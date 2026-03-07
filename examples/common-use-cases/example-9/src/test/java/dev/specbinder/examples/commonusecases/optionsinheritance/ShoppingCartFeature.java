package dev.specbinder.examples.commonusecases.optionsinheritance;

import dev.specbinder.annotations.Feature2JUnit;

/**
 * Inherits all options from BaseFeature — no override needed.
 * Generated step methods will include the keyword prefix
 * (e.g. givenIHaveAnEmptyShoppingCart instead of iHaveAnEmptyShoppingCart).
 */
@Feature2JUnit("specs/ShoppingCart.feature")
public abstract class ShoppingCartFeature extends BaseFeature {
}
