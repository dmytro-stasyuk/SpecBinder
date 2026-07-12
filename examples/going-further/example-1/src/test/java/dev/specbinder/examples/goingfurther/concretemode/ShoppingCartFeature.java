package dev.specbinder.examples.goingfurther.concretemode;

import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.annotations.Gherkin2JUnitOptions;

import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Concrete mode: shouldBeAbstract = false.
 *
 * The generator emits a concrete, directly-runnable test class (ShoppingCartTest)
 * instead of an abstract one — no hand-written subclass is needed. Step methods are
 * implemented here in the marker class and inherited by the generated class.
 *
 * Any step left unimplemented would become a failing stub (Assertions.fail(...)) at
 * run time rather than a compile error — that is the key trade-off versus the default
 * abstract mode.
 */
@Gherkin2JUnitOptions(shouldBeAbstract = false)
@Gherkin2JUnit("specs/ShoppingCart.specb")
public abstract class ShoppingCartFeature {

    private final List<CartItem> cart = new ArrayList<>();
    private double subtotal;
    private String banner;

    public void iHaveAnEmptyShoppingCart() {
        cart.clear();
    }

    public void iAdd$p1WithQuantity$p2AndUnitPrice$p3(String name, Integer quantity, Double unitPrice) {
        cart.add(new CartItem(name, quantity, unitPrice));
    }

    public void theCartShouldContain$p1Item(Integer expectedCount) {
        assertEquals(expectedCount, cart.size());
    }

    public void theCartSubtotalShouldBe$p1(Double expectedSubtotal) {
        double actual = cart.stream()
                .mapToDouble(item -> item.quantity * item.unitPrice)
                .sum();
        assertEquals(expectedSubtotal, actual, 0.001);
    }

    public void myCartSubtotalIs$p1(Double amount) {
        subtotal = amount;
    }

    public void iViewTheCart() {
        banner = subtotal >= 50.0 ? "Free shipping" : "Shipping: 5.99";
    }

    public void iShouldSeeThe$p1Banner(String expectedBanner) {
        assertEquals(expectedBanner, banner);
    }

    record CartItem(String name, int quantity, double unitPrice) {
    }
}
