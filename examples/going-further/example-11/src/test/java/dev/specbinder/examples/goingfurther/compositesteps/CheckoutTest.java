package dev.specbinder.examples.goingfurther.compositesteps;

import java.math.BigDecimal;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

/**
 * Concrete test class implementing the Checkout steps against an in-memory {@link Shop}.
 * <p>
 * Only the regular steps and the sub-steps need code here. Each composite step's composite method is generated in
 * CheckoutScenarios and runs its sub-steps in the order the spec lists them, passing on the values they refer to.
 * One composite method, {@link #theCustomerChecksOut}, is overridden to show that it is yours to take over.
 */
public class CheckoutTest extends CheckoutScenarios {

    private final Shop shop = new Shop();
    private Shop.Order order;

    @Override
    public void theShopSells(List<SellsParam> sells) {
        sells.forEach(row -> shop.sell(row.product(), BigDecimal.valueOf(row.price())));
    }

    @Override
    public void openTheSignInPage() {
        shop.openSignInPage();
    }

    @Override
    public void signInAs$p1(String customer) {
        shop.signIn(customer);
    }

    @Override
    public void searchTheCatalogueFor$p1(String text) {
        shop.search(text);
    }

    @Override
    public void add$p1OfTheFirstResultToTheCart(Integer quantity) {
        shop.addFirstResultToCart(quantity);
    }

    @Override
    public void addTheProductsToTheCart(List<CartParam> cart) {
        cart.forEach(line -> shop.addToCart(line.product(), line.quantity()));
    }

    @Override
    public void theFirstCartLineShouldBeFor$p1(String product) {
        assertEquals(product, shop.cartLines().get(0).product());
    }

    @Override
    public void openTheGiftOptions() {
        shop.openGiftOptions();
    }

    @Override
    public void writeTheGiftNote(String note) {
        shop.writeGiftNote(note);
    }

    /**
     * Overrides the generated composite method, which only runs the sub-steps, to also check the checkout as a whole:
     * whichever sub-steps it is written with, it has to end with an order placed.
     */
    @Override
    protected void theCustomerChecksOut(Runnable... composite) {
        super.theCustomerChecksOut(composite);
        assertNotNull(order, "Checking out should place an order");
    }

    @Override
    public void openTheCart() {
        shop.openCart();
    }

    @Override
    public void applyTheDiscountCode$p1(String code) {
        shop.applyDiscountCode(code);
    }

    @Override
    public void confirmTheDeliveryAddress() {
        shop.confirmDeliveryAddress();
    }

    @Override
    public void payWithTheSavedCard() {
        order = shop.payWithSavedCard();
    }

    @Override
    public void theOrderTotalShouldBe$p1(Double total) {
        assertEquals(BigDecimal.valueOf(total).setScale(2), order.total());
    }

    @Override
    public void theConfirmationEmailShouldRead(String email) {
        assertEquals(email.strip(), order.confirmationEmail());
    }
}
