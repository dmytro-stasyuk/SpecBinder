package dev.specbinder.examples.goingfurther.stepinterfaces;

/**
 * Concrete test class. Every step is already implemented by the step interfaces, so
 * all that is left is to supply the state they work on: one fresh {@link Cart} per test.
 * Without a concrete subclass the generated ShoppingCartScenarios stays abstract and
 * JUnit never runs it.
 */
public class ShoppingCartTest extends ShoppingCartScenarios {

    private final Cart cart = new Cart();

    @Override
    public Cart cart() {
        return cart;
    }
}
