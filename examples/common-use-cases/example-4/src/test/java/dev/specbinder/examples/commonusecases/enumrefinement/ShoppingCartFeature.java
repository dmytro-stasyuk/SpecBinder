package dev.specbinder.examples.commonusecases.enumrefinement;

import dev.specbinder.annotations.Gherkin2JUnit;

import java.util.List;

/**
 * The generator initially produces ProductsParam with a String category field,
 * together with the abstract step method that receives it. Both are moved here
 * from the generated class and the type is refined to a Category enum: the
 * generator detects them and uses them instead of generating its own.
 *
 * If someone adds a row with an invalid category (e.g. "furniture"),
 * the generated code will try Category.furniture — causing a COMPILER ERROR.
 *
 * No path in @Gherkin2JUnit — the processor discovers the co-located
 * ShoppingCart.specb in this package by convention.
 */
@Gherkin2JUnit
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

    /**
     * Step declaration moved from the generated code along with ProductsParam, so the
     * refined type and the step that receives it live side by side. It stays abstract —
     * the concrete test class implements it like any other step.
     */
    public abstract void myCartContainsTheFollowingProducts(List<ProductsParam> products);

    /**
     * Step declaration moved from the generated code with its quoted parameter refined
     * from String to Category. The generator passes the quoted value as an enum constant,
     * so a category the enum doesn't know is a compiler error here too.
     */
    public abstract void iFilterByCategory$p1(Category category);
}
