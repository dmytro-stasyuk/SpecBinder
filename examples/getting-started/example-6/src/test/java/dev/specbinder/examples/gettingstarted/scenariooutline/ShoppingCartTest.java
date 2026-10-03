package dev.specbinder.examples.gettingstarted.scenariooutline;

import specs.ShoppingCartScenarios;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Concrete test class that extends the generated abstract class and
 * implements each abstract step method. Step methods of a Scenario Outline
 * are implemented exactly like any other step: the generated
 * @ParameterizedTest method passes each Examples row's values in as
 * arguments, so one implementation runs once per row.
 */
public class ShoppingCartTest extends ShoppingCartScenarios {

    private static final double SMALL_ORDER_LIMIT = 10.00;
    private static final double SMALL_ORDER_SHIPPING_COST = 8.99;
    private static final double FREE_SHIPPING_THRESHOLD = 50.00;
    private static final double STANDARD_SHIPPING_COST = 5.99;

    private CartItem item;
    private double subtotal;
    private double shippingCost;

    @Override
    public void myCartContains$p1WithQuantity$p2AndUnitPrice$p3(String name, Integer quantity, Double unitPrice) {
        item = new CartItem(name, quantity, unitPrice);
        subtotal = item.quantity() * item.unitPrice();
    }

    @Override
    public void iChangeTheQuantityTo$p1(Integer newQuantity) {
        item = new CartItem(item.name(), newQuantity, item.unitPrice());
        subtotal = item.quantity() * item.unitPrice();
    }

    @Override
    public void myCartSubtotalIs$p1(Double amount) {
        subtotal = amount;
    }

    @Override
    public void iViewTheShippingOptions() {
        if (subtotal <= SMALL_ORDER_LIMIT) {
            shippingCost = SMALL_ORDER_SHIPPING_COST;
        } else if (subtotal < FREE_SHIPPING_THRESHOLD) {
            shippingCost = STANDARD_SHIPPING_COST;
        } else {
            shippingCost = 0.00;
        }
    }

    @Override
    public void theCartSubtotalShouldBe$p1(Double expectedSubtotal) {
        assertEquals(expectedSubtotal, subtotal, 0.001);
    }

    @Override
    public void theShippingCostShouldBe$p1(Double expectedShippingCost) {
        assertEquals(expectedShippingCost, shippingCost, 0.001);
    }

    record CartItem(String name, int quantity, double unitPrice) {
    }
}
