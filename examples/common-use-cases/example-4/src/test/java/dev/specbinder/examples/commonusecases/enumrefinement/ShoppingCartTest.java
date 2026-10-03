package dev.specbinder.examples.commonusecases.enumrefinement;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Concrete test class that extends the generated abstract class and
 * implements each abstract step method. The data table arrives as a List of
 * the refined ProductsParam from the marker class, so {@code category()} is
 * already a Category enum here — no string comparison needed.
 */
public class ShoppingCartTest extends ShoppingCartScenarios {

    private List<ProductsParam> products;
    private double subtotal;

    @Override
    public void myCartContainsTheFollowingProducts(List<ProductsParam> products) {
        this.products = products;
    }

    @Override
    public void iCalculateTheSubtotal() {
        subtotal = totalOf(products);
    }

    @Override
    public void theCartSubtotalShouldBe$p1(Double expectedSubtotal) {
        assertEquals(expectedSubtotal, subtotal, 0.001);
    }

    @Override
    public void iFilterByCategory$p1(Category category) {
        products = products.stream()
                .filter(product -> product.category() == category)
                .toList();
    }

    @Override
    public void theFilteredItemsShouldTotal$p1(Double expectedTotal) {
        assertEquals(expectedTotal, totalOf(products), 0.001);
    }

    private static double totalOf(List<ProductsParam> products) {
        return products.stream()
                .mapToDouble(product -> product.qty() * product.unitPrice())
                .sum();
    }
}
