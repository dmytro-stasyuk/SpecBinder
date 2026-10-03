package dev.specbinder.examples.commonusecases.optionsinheritance.shoppingcart;

import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Concrete test for ShoppingCart.specb. Both inherited options show up here:
 * it extends ShoppingCartSpec (classSuffixIfAbstract = "Spec") and implements
 * step methods named with their keyword prefix (useStepKeywordInStepMethodName = true).
 */
public class ShoppingCartTest extends ShoppingCartSpec {

    private final List<String> cart = new ArrayList<>();

    @Override
    public void givenIHaveAnEmptyShoppingCart() {
        cart.clear();
    }

    @Override
    public void whenIAdd$p1ToTheCart(String product) {
        cart.add(product);
    }

    @Override
    public void thenTheCartShouldContain$p1Item(Integer expectedCount) {
        assertEquals(expectedCount, cart.size());
    }
}
