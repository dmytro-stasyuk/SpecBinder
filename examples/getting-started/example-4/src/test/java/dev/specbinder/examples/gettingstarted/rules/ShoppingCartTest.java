package dev.specbinder.examples.gettingstarted.rules;

import specs.ShoppingCartScenarios;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Concrete test class that extends the generated abstract class and
 * implements each abstract step method. The scenarios inside each Rule
 * live in generated @Nested inner classes, but they call the same step
 * methods on the outer instance — so one set of implementations and one
 * set of instance fields serve both top-level and rule scenarios.
 */
public class ShoppingCartTest extends ShoppingCartScenarios {

    private static final double FREE_SHIPPING_THRESHOLD = 50.00;
    private static final double SHIPPING_COST = 5.99;
    private static final Map<String, Integer> ACTIVE_DISCOUNT_CODES = Map.of("SAVE10", 10);

    private double subtotal;
    private boolean empty = true;
    private String display;
    private String banner;
    private String message;

    @Override
    public void iHaveAnEmptyShoppingCart() {
        subtotal = 0;
        empty = true;
    }

    @Override
    public void myCartSubtotalIs$p1(Double amount) {
        subtotal = amount;
        empty = false;
    }

    @Override
    public void iViewTheCart() {
        if (empty) {
            display = "Your cart is empty";
            return;
        }
        banner = subtotal >= FREE_SHIPPING_THRESHOLD
                ? "Free shipping"
                : "Shipping: " + SHIPPING_COST;
    }

    @Override
    public void iApplyDiscountCode$p1(String code) {
        Integer percentage = ACTIVE_DISCOUNT_CODES.get(code);
        if (percentage == null) {
            message = "Invalid discount code";
            return;
        }
        subtotal = subtotal * (100 - percentage) / 100;
    }

    @Override
    public void theCartShouldDisplay$p1(String expectedText) {
        assertEquals(expectedText, display);
    }

    @Override
    public void iShouldSeeThe$p1Banner(String expectedBanner) {
        assertEquals(expectedBanner, banner);
    }

    @Override
    public void theCartSubtotalShouldBe$p1(Double expectedSubtotal) {
        assertEquals(expectedSubtotal, subtotal, 0.001);
    }

    @Override
    public void iShouldSeeThe$p1Message(String expectedMessage) {
        assertEquals(expectedMessage, message);
    }
}
