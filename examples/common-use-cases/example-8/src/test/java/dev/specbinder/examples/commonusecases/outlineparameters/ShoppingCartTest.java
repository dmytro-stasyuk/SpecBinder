package dev.specbinder.examples.commonusecases.outlineparameters;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Concrete test class that extends the generated abstract class and
 * implements each abstract step method. By the time a step method runs, every
 * Examples placeholder has already been substituted — in the quoted value, the
 * doc string and the data table alike — so the step code only ever sees the
 * concrete values of the current Examples row.
 */
public class ShoppingCartTest extends ShoppingCartScenarios {

    private static final Map<String, Double> CATALOGUE_PRICES = Map.of(
            "Wireless Mouse", 29.99,
            "USB-C Cable", 8.99,
            "Laptop Stand", 35.00);
    private static final Map<String, Promotion> PROMOTIONS = Map.of(
            "Wireless Mouse", new Promotion("SPRING10", 10),
            "Laptop Stand", new Promotion("BUNDLE20", 20));
    private static final String TRACKING_BASE_URL = "https://shop.example.com/orders/";

    private final List<String> cart = new ArrayList<>();
    private final List<LinesParam> orderLines = new ArrayList<>();
    private String trackingLink;

    @Override
    public void iHaveAnEmptyShoppingCart() {
        cart.clear();
    }

    @Override
    public void iAdd$p1ToTheCart(String product) {
        cart.add(product);
    }

    @Override
    public void iSubmitTheOrderWithTheFollowingPayload(String payload) {
        String product = jsonField(payload, "product");
        int quantity = Integer.parseInt(jsonField(payload, "quantity"));
        assertTrue(cart.contains(product), "Ordered product is not in the cart: " + product);
        orderLines.add(new LinesParam(product, quantity, quantity * CATALOGUE_PRICES.get(product)));
    }

    @Override
    public void theOrderShouldContainTheFollowingLines(List<LinesParam> expectedLines) {
        assertEquals(expectedLines.size(), orderLines.size());
        for (int i = 0; i < expectedLines.size(); i++) {
            LinesParam expected = expectedLines.get(i);
            LinesParam actual = orderLines.get(i);
            assertEquals(expected.product(), actual.product());
            assertEquals(expected.quantity(), actual.quantity());
            assertEquals(expected.lineTotal(), actual.lineTotal(), 0.001);
        }
    }

    @Override
    public void theOrderShouldShowTheFollowingPromotionDetails(List<DetailsParam> expectedDetails) {
        Promotion promotion = PROMOTIONS.get(cart.getFirst());
        Map<String, String> details = new LinkedHashMap<>();
        details.put("promotion", promotion.code());
        details.put("channel", "web");
        details.put("discount", promotion.percentage() + "%");

        for (DetailsParam expected : expectedDetails) {
            assertEquals(expected.value(), details.get(expected.field()), "Promotion detail " + expected.field());
        }
    }

    @Override
    public void iPlaceTheOrderWithReference$p1(String reference) {
        String[] parts = reference.split("-");
        String year = parts[1];
        String region = parts[2];
        trackingLink = TRACKING_BASE_URL + region + "/" + year;
    }

    @Override
    public void theTrackingLinkShouldBe$p1(String expectedLink) {
        assertEquals(expectedLink, trackingLink);
    }

    private static String jsonField(String json, String name) {
        Matcher matcher = Pattern.compile("\"" + name + "\"\\s*:\\s*\"([^\"]*)\"").matcher(json);
        assertTrue(matcher.find(), "Payload is missing " + name);
        return matcher.group(1);
    }

    record Promotion(String code, int percentage) {
    }
}
