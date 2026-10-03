package dev.specbinder.examples.commonusecases.tddworkflow;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Concrete test class that extends the generated abstract class and
 * implements each abstract step method. Only the one fully specified
 * scenario has steps, so only its steps exist to implement — that scenario
 * goes green, while the empty rule and the empty scenarios keep failing
 * (tagged @new) until they are specified. That red list is the TDD backlog.
 */
public class ShoppingCartTest extends ShoppingCartScenarios {

    private static final Map<String, Integer> ACTIVE_DISCOUNT_CODES = Map.of("SAVE10", 10);

    private double subtotal;

    @Override
    public void myCartSubtotalIs$p1(Double amount) {
        subtotal = amount;
    }

    @Override
    public void iApplyDiscountCode$p1(String code) {
        int percentage = ACTIVE_DISCOUNT_CODES.get(code);
        subtotal = subtotal * (100 - percentage) / 100;
    }

    @Override
    public void theCartSubtotalShouldBe$p1(Double expectedSubtotal) {
        assertEquals(expectedSubtotal, subtotal, 0.001);
    }
}
