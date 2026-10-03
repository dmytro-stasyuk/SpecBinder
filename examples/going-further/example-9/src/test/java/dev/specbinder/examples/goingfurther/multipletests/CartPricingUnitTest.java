package dev.specbinder.examples.goingfurther.multipletests;

import org.junit.jupiter.api.Tag;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.assertEquals;

@Tag("unit")
public class CartPricingUnitTest extends CartPricingScenarios {

    private final CartPricingService pricing = new CartPricingService();

    private int quantity;
    private BigDecimal unitPrice;
    private int discount;

    @Override
    public void aCartHolding$p1ItemsPriced$p2(Integer quantity, String unitPrice) {
        this.quantity = quantity;
        this.unitPrice = new BigDecimal(unitPrice);
        this.discount = 0;
    }

    @Override
    public void aDiscountOf$p1PercentIsApplied(Integer percent) {
        discount = percent;
    }

    @Override
    public void theCartTotalShouldBe$p1(String expected) {
        assertEquals(new BigDecimal(expected), pricing.total(quantity, unitPrice, discount));
    }
}
