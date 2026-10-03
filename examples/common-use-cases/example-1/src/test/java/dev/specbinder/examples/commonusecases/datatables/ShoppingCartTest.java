package dev.specbinder.examples.commonusecases.datatables;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Concrete test class that extends the generated abstract class and
 * implements each abstract step method. Every data table arrives as a
 * List of the generated Param type, so step code reads rows through typed
 * accessors — {@code product.qty()} is an Integer, {@code product.inStock()}
 * a Boolean — with no string parsing.
 */
public class ShoppingCartTest extends ShoppingCartScenarios {

    private List<ProductsParam> products;
    private double subtotal;
    private List<String> outOfStockNames;
    private List<ThresholdsParam> thresholds;
    private final List<AdjustmentsParam> adjustments = new ArrayList<>();

    @Override
    public void myCartContainsTheFollowingProducts(List<ProductsParam> products) {
        this.products = products;
    }

    @Override
    public void iCalculateTheSubtotal() {
        subtotal = products.stream()
                .mapToDouble(product -> product.qty() * product.unitPrice())
                .sum();
    }

    @Override
    public void theCartSubtotalShouldBe$p1(Double expectedSubtotal) {
        assertEquals(expectedSubtotal, subtotal, 0.001);
    }

    @Override
    public void iCheckStockAvailability() {
        outOfStockNames = products.stream()
                .filter(product -> !product.inStock())
                .map(ProductsParam::name)
                .toList();
    }

    @Override
    public void iShouldSeeTheFollowingOutOfStockProducts(List<ProductsParam> expectedProducts) {
        List<String> expectedNames = expectedProducts.stream()
                .map(ProductsParam::name)
                .toList();
        assertEquals(expectedNames, outOfStockNames);
    }

    @Override
    public void theFollowingDiscountThresholds(List<ThresholdsParam> thresholds) {
        this.thresholds = thresholds;
    }

    @Override
    public void iApplyBulkDiscounts() {
        for (ProductsParam product : products) {
            thresholds.stream()
                    .filter(threshold -> product.qty() >= threshold.minQty())
                    .max(Comparator.comparing(ThresholdsParam::minQty))
                    .ifPresent(threshold -> adjustments.add(new AdjustmentsParam(
                            product.name(),
                            product.unitPrice(),
                            product.unitPrice() * (100 - threshold.discountPercent()) / 100)));
        }
    }

    @Override
    public void iShouldSeeTheFollowingPriceAdjustments(List<AdjustmentsParam> expectedAdjustments) {
        assertEquals(expectedAdjustments.size(), adjustments.size());
        for (int i = 0; i < expectedAdjustments.size(); i++) {
            AdjustmentsParam expected = expectedAdjustments.get(i);
            AdjustmentsParam actual = adjustments.get(i);
            assertEquals(expected.name(), actual.name());
            assertEquals(expected.originalPrice(), actual.originalPrice(), 0.001);
            assertEquals(expected.discountedPrice(), actual.discountedPrice(), 0.001);
        }
    }
}
