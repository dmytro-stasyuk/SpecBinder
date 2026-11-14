package dev.specbinder.examples.goingfurther.compositesteps;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * A tiny in-memory web shop, used the way a customer clicks through it: most actions need a particular page to be
 * open, so the sub-steps of a composite step only work in the order the spec lists them.
 */
public class Shop {

    public enum Page {
        HOME, SIGN_IN, SEARCH_RESULTS, GIFT_OPTIONS, CART, ORDER_CONFIRMATION
    }

    public record CartLine(String product, int quantity, BigDecimal price) {
    }

    public record Order(BigDecimal total, String confirmationEmail) {
    }

    private static final Map<String, Integer> DISCOUNT_PERCENTAGES = Map.of("SAVE10", 10);

    private final Map<String, BigDecimal> catalogue = new LinkedHashMap<>();
    private final List<CartLine> cartLines = new ArrayList<>();
    private Page page = Page.HOME;
    private String customer;
    private List<String> searchResults = List.of();
    private String discountCode;
    private String giftNote;
    private boolean deliveryAddressConfirmed;

    public void sell(String product, BigDecimal price) {
        catalogue.put(product, price);
    }

    public void openSignInPage() {
        page = Page.SIGN_IN;
    }

    public void signIn(String customer) {
        requirePage(Page.SIGN_IN);
        this.customer = customer;
        page = Page.HOME;
    }

    public void search(String text) {
        searchResults = catalogue.keySet().stream()
                .filter(product -> product.toLowerCase().contains(text.toLowerCase()))
                .toList();
        page = Page.SEARCH_RESULTS;
    }

    public void addFirstResultToCart(int quantity) {
        requirePage(Page.SEARCH_RESULTS);
        if (searchResults.isEmpty()) {
            throw new IllegalStateException("The search found nothing to add to the cart");
        }
        addToCart(searchResults.get(0), quantity);
    }

    public void addToCart(String product, int quantity) {
        BigDecimal price = catalogue.get(product);
        if (price == null) {
            throw new IllegalArgumentException("The shop doesn't sell " + product);
        }
        cartLines.add(new CartLine(product, quantity, price));
    }

    public List<CartLine> cartLines() {
        return List.copyOf(cartLines);
    }

    public void openGiftOptions() {
        page = Page.GIFT_OPTIONS;
    }

    public void writeGiftNote(String note) {
        requirePage(Page.GIFT_OPTIONS);
        giftNote = note.strip();
    }

    public void openCart() {
        page = Page.CART;
    }

    public void applyDiscountCode(String code) {
        requirePage(Page.CART);
        discountCode = code;
    }

    public void confirmDeliveryAddress() {
        requirePage(Page.CART);
        deliveryAddressConfirmed = true;
    }

    public Order payWithSavedCard() {
        requirePage(Page.CART);
        if (customer == null) {
            throw new IllegalStateException("Sign in before paying");
        }
        if (!deliveryAddressConfirmed) {
            throw new IllegalStateException("Confirm the delivery address before paying");
        }
        page = Page.ORDER_CONFIRMATION;
        return new Order(total(), confirmationEmail());
    }

    private BigDecimal total() {
        BigDecimal subtotal = cartLines.stream()
                .map(line -> line.price().multiply(BigDecimal.valueOf(line.quantity())))
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        // an unknown discount code takes nothing off
        int discountPercentage = discountCode == null ? 0 : DISCOUNT_PERCENTAGES.getOrDefault(discountCode, 0);
        return subtotal.multiply(BigDecimal.valueOf(100 - discountPercentage))
                .movePointLeft(2)
                .setScale(2, RoundingMode.HALF_UP);
    }

    private String confirmationEmail() {
        String email = "Thank you for your order, " + customer + ".";
        return giftNote == null ? email : email + "\nGift note: " + giftNote;
    }

    private void requirePage(Page expected) {
        if (page != expected) {
            throw new IllegalStateException("Expected the " + expected + " page to be open, but it was " + page);
        }
    }
}
