package dev.specbinder.examples.commonusecases.enumrefinement;

import dev.specbinder.annotations.Feature2JUnit;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * The generator initially produces ProductsParam with a String category field.
 * By defining ProductsParam here with a Category enum, we refine the type:
 * the generator detects our class and uses it instead of generating a new one.
 *
 * If someone adds a row with an invalid category (e.g. "furniture"),
 * the generated code will try Category.furniture — causing a COMPILER ERROR.
 */
@Feature2JUnit("specs/ShoppingCart.feature")
public abstract class ShoppingCartFeature {

    /**
     * Enum constraining the allowed category values.
     * Adding a product with a category not in this enum causes a compilation error.
     */
    public enum Category { electronics, grocery, sports }

    /**
     * Refined Param class — moved from the generated code into the marker class.
     * The category field is now an enum instead of String.
     */
    public static class ProductsParam {
        private final String name;
        private final Integer qty;
        private final Double unitPrice;
        private final Category category;

        public ProductsParam(String name, Integer qty, Double unitPrice, Category category) {
            this.name = name;
            this.qty = qty;
            this.unitPrice = unitPrice;
            this.category = category;
        }

        public String name() { return this.name; }
        public Integer qty() { return this.qty; }
        public Double unitPrice() { return this.unitPrice; }
        public Category category() { return this.category; }
    }

    protected List<ProductsParam> products;

    public void myCartContainsTheFollowingProducts(List<ProductsParam> products) {
        this.products = products;
    }

    public void iCalculateTheSubtotal() {
        // subtotal calculated on demand in assertion
    }

    public void theCartSubtotalShouldBe$p1(Double expectedSubtotal) {
        double actual = products.stream()
                .mapToDouble(p -> p.qty() * p.unitPrice())
                .sum();
        assertEquals(expectedSubtotal, actual, 0.001);
    }

    public void iFilterByCategory$p1(String categoryName) {
        Category category = Category.valueOf(categoryName);
        products = products.stream()
                .filter(p -> p.category() == category)
                .toList();
    }

    public void theFilteredItemsShouldTotal$p1(Double expectedTotal) {
        double actual = products.stream()
                .mapToDouble(p -> p.qty() * p.unitPrice())
                .sum();
        assertEquals(expectedTotal, actual, 0.001);
    }
}
