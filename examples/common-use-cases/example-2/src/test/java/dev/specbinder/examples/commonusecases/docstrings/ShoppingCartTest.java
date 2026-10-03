package dev.specbinder.examples.commonusecases.docstrings;

import java.util.*;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Concrete test class that extends the generated abstract class and
 * implements each abstract step method. A doc string arrives as a plain
 * String with its line breaks and indentation intact, so it can be
 * inspected — or compared against generated text — exactly as written
 * in the spec. A content type on the doc string (image, svg, html) is for
 * the IDE only: the step method still receives a plain String.
 */
public class ShoppingCartTest extends ShoppingCartScenarios {

    private static final List<String> REQUIRED_ADDRESS_FIELDS = List.of("line1", "city", "postcode", "country");
    private static final byte[] PNG_SIGNATURE = {(byte) 0x89, 'P', 'N', 'G', '\r', '\n', 0x1A, '\n'};

    private final List<String> items = new ArrayList<>();
    private final List<CustomizedItem> customizedItems = new ArrayList<>();
    private String shippingAddress;
    private Order completedOrder;

    @Override
    public void iHaveAShoppingCartWithItems() {
        items.add("Coffee Beans 1kg");
    }

    @Override
    public void iSubmitTheFollowingShippingAddress(String address) {
        shippingAddress = address;
    }

    @Override
    public void theOrderShouldBeReadyForCheckout() {
        assertFalse(items.isEmpty(), "The cart has no items");
        for (String field : REQUIRED_ADDRESS_FIELDS) {
            assertTrue(shippingAddress.contains("\"" + field + "\""), "Shipping address is missing " + field);
        }
    }

    @Override
    public void iAddItem$p1WithOptions(String name, String options) {
        customizedItems.add(new CustomizedItem(name, options));
    }

    @Override
    public void theCartShouldContain$p1CustomizedItem(Integer expectedCount) {
        assertEquals(expectedCount, customizedItems.size());
    }

    @Override
    public void theShopUsesTheFollowingConfirmationBadge(String base64Image) {
        byte[] image = Base64.getMimeDecoder().decode(base64Image.strip());
        assertTrue(Arrays.equals(PNG_SIGNATURE, 0, PNG_SIGNATURE.length, image, 0, PNG_SIGNATURE.length),
                "The confirmation badge must be a PNG image");
    }

    @Override
    public void theShopUsesTheFollowingDeliveryIcon(String svg) {
        assertTrue(svg.strip().startsWith("<svg"), "The delivery icon must be an SVG drawing");
    }

    @Override
    public void iHaveCompletedAPurchase() {
        completedOrder = new Order(12345, 3, 97.49);
    }

    @Override
    public void iShouldReceiveTheFollowingConfirmation(String expectedConfirmation) {
        assertEquals(expectedConfirmation, completedOrder.confirmationText());
    }

    @Override
    public void iShouldReceiveTheFollowingConfirmationPage(String expectedPage) {
        assertEquals(expectedPage, completedOrder.confirmationPage());
    }

    record CustomizedItem(String name, String options) {
    }

    record Order(int number, int itemCount, double total) {

        String confirmationText() {
            return """
                    Thank you for your order!

                    Order #%d
                    Items: %d
                    Total: €%s

                    Your order will be shipped within 2 business days.
                    """.formatted(number, itemCount, formattedTotal());
        }

        String confirmationPage() {
            return """
                    <h2>Thank you for your order!</h2>
                    <p>Order <strong>#%d</strong> will be shipped within 2 business days.</p>
                    <table border="1" cellpadding="6" cellspacing="0">
                      <tr><th>Items</th><td>%d</td></tr>
                      <tr><th>Total</th><td style="background:#0d9488;color:#ffffff">€%s</td></tr>
                    </table>
                    """.formatted(number, itemCount, formattedTotal());
        }

        private String formattedTotal() {
            return String.format(Locale.ROOT, "%.2f", total);
        }
    }
}
