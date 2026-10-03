package dev.specbinder.examples.goingfurther.multipletests;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Tag;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

import java.math.BigDecimal;

import static org.junit.jupiter.api.Assertions.assertEquals;

@Tag("spring")
public class CartPricingSpringTest extends CartPricingScenarios {

    private AnnotationConfigApplicationContext application;
    private CartPricingService pricing;

    @BeforeEach
    void startSpring() {
        application = new AnnotationConfigApplicationContext(PricingConfiguration.class);
        pricing = application.getBean(CartPricingService.class);
    }

    @AfterEach
    void stopSpring() {
        if (application != null) application.close();
    }

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
