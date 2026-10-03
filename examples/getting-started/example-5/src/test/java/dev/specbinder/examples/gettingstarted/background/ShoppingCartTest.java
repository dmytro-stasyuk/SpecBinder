package dev.specbinder.examples.gettingstarted.background;

import specs.ShoppingCartScenarios;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

/**
 * Concrete test class that extends the generated abstract class and
 * implements each abstract step method. Background steps are ordinary
 * step methods too: the generated @BeforeEach methods call them, so the
 * feature-level background has already signed the shopper in and emptied
 * the cart by the time a rule-level background or a scenario runs.
 */
public class ShoppingCartTest extends ShoppingCartScenarios {

    private static final double FREE_SHIPPING_THRESHOLD = 50.00;
    private static final double SHIPPING_COST = 5.99;
    private static final int POINTS_PER_EURO = 1;

    private String signedInShopper;
    private double subtotal;
    private int loyaltyPoints;
    private String display;

    @Override
    public void iAmSignedInAs$p1(String email) {
        signedInShopper = email;
    }

    @Override
    public void iHaveAnEmptyShoppingCart() {
        subtotal = 0;
    }

    @Override
    public void myCartSubtotalIs$p1(Double amount) {
        subtotal = amount;
    }

    @Override
    public void iHave$p1LoyaltyPoints(Integer points) {
        loyaltyPoints = points;
    }

    @Override
    public void iViewTheCart() {
        if (subtotal == 0) {
            display = "Your cart is empty";
        }
    }

    @Override
    public void iAddAnItemPricedAt$p1(Double price) {
        subtotal += price;
    }

    @Override
    public void iPurchaseItemsTotalling$p1(Double total) {
        assertNotNull(signedInShopper, "Only a signed-in shopper can purchase");
        loyaltyPoints += (int) (total * POINTS_PER_EURO);
    }

    @Override
    public void iShouldSee$p1(String expectedText) {
        assertEquals(expectedText, display);
    }

    @Override
    public void iShouldSeeThe$p1Banner(String expectedBanner) {
        String banner = subtotal >= FREE_SHIPPING_THRESHOLD
                ? "Free shipping"
                : "Shipping: " + SHIPPING_COST;
        assertEquals(expectedBanner, banner);
    }

    @Override
    public void iShouldHave$p1LoyaltyPoints(Integer expectedPoints) {
        assertEquals(expectedPoints, loyaltyPoints);
    }
}
