package dev.specbinder.examples.goingfurther.diagnostics;

import specs.ShoppingCartScenarios;

import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Concrete test implementing the spec's steps. The verbosity option affects only
 * the build-log output during generation — the generated test itself is ordinary
 * JUnit 5 and runs exactly as any other example.
 */
public class ShoppingCartTest extends ShoppingCartScenarios {

    private final List<Double> lineTotals = new ArrayList<>();

    @Override
    public void iHaveAnEmptyShoppingCart() {
        lineTotals.clear();
    }

    @Override
    public void iAdd$p1WithQuantity$p2AndUnitPrice$p3(String name, Integer quantity, Double unitPrice) {
        lineTotals.add(quantity * unitPrice);
    }

    @Override
    public void theCartSubtotalShouldBe$p1(Double expectedSubtotal) {
        double subtotal = lineTotals.stream().mapToDouble(Double::doubleValue).sum();
        assertEquals(expectedSubtotal, subtotal, 0.001);
    }
}
