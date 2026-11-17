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

    /** The pages of the shop a customer can have open. */
    public enum Page {
        /** The page the shop opens on, and the one a customer lands on after signing in. */
        HOME,
        /** The page where a customer signs in. */
        SIGN_IN,
        /** The page listing the products a search found. */
        SEARCH_RESULTS,
        /** The page where a customer writes a gift note. */
        GIFT_OPTIONS,
        /** The page where a customer applies a discount code, confirms the delivery address and pays. */
        CART,
        /** The page shown once an order is paid. */
        ORDER_CONFIRMATION
    }

    /**
     * A product in the cart.
     *
     * @param product  name of the product
     * @param quantity how many of the product are in the cart
     * @param price    price of a single item, as the shop sold it when the product was added
     */
    public record CartLine(String product, int quantity, BigDecimal price) {
    }

    /**
     * A paid order.
     *
     * @param total             amount paid, after the discount, with a scale of 2
     * @param confirmationEmail email the customer receives, including the gift note if one was written
     */
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

    /** Creates a shop that sells nothing yet, with the home page open and no one signed in. */
    public Shop() {
    }

    /**
     * Adds a product to the catalogue, or changes the price of one already in it.
     *
     * @param product name of the product
     * @param price   price of a single item
     */
    public void sell(String product, BigDecimal price) {
        catalogue.put(product, price);
    }

    /** Opens the sign-in page. */
    public void openSignInPage() {
        page = Page.SIGN_IN;
    }

    /**
     * Signs the customer in and takes them back to the home page.
     *
     * @param customer name of the customer
     * @throws IllegalStateException if the sign-in page isn't open
     */
    public void signIn(String customer) {
        requirePage(Page.SIGN_IN);
        this.customer = customer;
        page = Page.HOME;
    }

    /**
     * Searches the catalogue for products whose name contains the text, ignoring case, and opens the search results.
     *
     * @param text text to look for in product names
     */
    public void search(String text) {
        searchResults = catalogue.keySet().stream()
                .filter(product -> product.toLowerCase().contains(text.toLowerCase()))
                .toList();
        page = Page.SEARCH_RESULTS;
    }

    /**
     * Adds the first product the last search found to the cart.
     *
     * @param quantity how many of the product to add
     * @throws IllegalStateException if the search results aren't open, or the search found nothing
     */
    public void addFirstResultToCart(int quantity) {
        requirePage(Page.SEARCH_RESULTS);
        if (searchResults.isEmpty()) {
            throw new IllegalStateException("The search found nothing to add to the cart");
        }
        addToCart(searchResults.get(0), quantity);
    }

    /**
     * Adds a product to the cart at its current price; this works from any page.
     *
     * @param product  name of the product
     * @param quantity how many of the product to add
     * @throws IllegalArgumentException if the shop doesn't sell the product
     */
    public void addToCart(String product, int quantity) {
        BigDecimal price = catalogue.get(product);
        if (price == null) {
            throw new IllegalArgumentException("The shop doesn't sell " + product);
        }
        cartLines.add(new CartLine(product, quantity, price));
    }

    /**
     * Returns the products in the cart.
     *
     * @return the cart lines, in the order the products were added
     */
    public List<CartLine> cartLines() {
        return List.copyOf(cartLines);
    }

    /** Opens the gift options page. */
    public void openGiftOptions() {
        page = Page.GIFT_OPTIONS;
    }

    /**
     * Writes the gift note added to the confirmation email, without leading or trailing whitespace.
     *
     * @param note text of the gift note
     * @throws IllegalStateException if the gift options page isn't open
     */
    public void writeGiftNote(String note) {
        requirePage(Page.GIFT_OPTIONS);
        giftNote = note.strip();
    }

    /** Opens the cart. */
    public void openCart() {
        page = Page.CART;
    }

    /**
     * Applies a discount code to the order; an unknown code is accepted but takes nothing off.
     *
     * @param code the discount code
     * @throws IllegalStateException if the cart isn't open
     */
    public void applyDiscountCode(String code) {
        requirePage(Page.CART);
        discountCode = code;
    }

    /**
     * Confirms the delivery address, which has to be done before paying.
     *
     * @throws IllegalStateException if the cart isn't open
     */
    public void confirmDeliveryAddress() {
        requirePage(Page.CART);
        deliveryAddressConfirmed = true;
    }

    /**
     * Pays for the cart with the customer's saved card and opens the order confirmation.
     *
     * @return the paid order
     * @throws IllegalStateException if the cart isn't open, no one is signed in, or the delivery address isn't
     *                               confirmed
     */
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
