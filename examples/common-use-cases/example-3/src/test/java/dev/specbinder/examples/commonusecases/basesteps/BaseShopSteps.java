package dev.specbinder.examples.commonusecases.basesteps;

import java.util.ArrayList;
import java.util.List;

/**
 * A reusable base class holding shared cart state and the common step
 * implementations. Any marker class that extends this base inherits these step
 * methods — the generator detects them in the marker's class hierarchy and does
 * NOT emit abstract declarations for them, so the implementations are shared
 * across every feature whose marker extends this class, with no per-feature glue.
 */
public abstract class BaseShopSteps {

    protected final List<CartItem> cart = new ArrayList<>();

    public void iHaveAnEmptyShoppingCart() {
        cart.clear();
    }

    public void iAdd$p1WithQuantity$p2AndUnitPrice$p3(String name, Integer quantity, Double unitPrice) {
        cart.add(new CartItem(name, quantity, unitPrice));
    }

    protected int itemCount() {
        return cart.size();
    }

    protected double subtotal() {
        return cart.stream()
                .mapToDouble(item -> item.quantity() * item.unitPrice())
                .sum();
    }

    private record CartItem(String name, int quantity, double unitPrice) {
    }
}
