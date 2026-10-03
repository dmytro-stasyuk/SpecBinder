package dev.specbinder.examples.gettingstarted.parameters;

import specs.ShoppingCartScenarios;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Concrete test class that extends the generated abstract class and
 * implements each abstract step method. The quoted values from the spec
 * arrive already typed — String, Integer, Double, Boolean, Character —
 * so the step code works with them directly, with no parsing.
 */
public class ShoppingCartTest extends ShoppingCartScenarios {

    private int quantity;
    private double unitPrice;
    private boolean discountApplied;
    private char discountBadge;

    @Override
    public void myCartContains$p1WithQuantity$p2AndUnitPrice$p3(String name, Integer quantity, Double unitPrice) {
        this.quantity = quantity;
        this.unitPrice = unitPrice;
    }

    @Override
    public void iChangeTheQuantityTo$p1(Integer newQuantity) {
        quantity = newQuantity;
    }

    @Override
    public void theCartSubtotalShouldBe$p1(Double expectedSubtotal) {
        assertEquals(expectedSubtotal, quantity * unitPrice, 0.001);
    }

    @Override
    public void theDiscountAppliedIs$p1(Boolean applied) {
        discountApplied = applied;
    }

    @Override
    public void iViewTheCartSummary() {
        discountBadge = discountApplied ? 'Y' : 'N';
    }

    @Override
    public void theDiscountBadgeShows$p1(Character expectedBadge) {
        assertEquals(expectedBadge, discountBadge);
    }
}
