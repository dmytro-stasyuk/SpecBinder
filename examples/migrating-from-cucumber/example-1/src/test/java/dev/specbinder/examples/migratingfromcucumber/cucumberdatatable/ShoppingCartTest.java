package dev.specbinder.examples.migratingfromcucumber.cucumberdatatable;

import io.cucumber.datatable.DataTable;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Concrete test class implementing the steps. Each data table arrives as a Cucumber
 * DataTable, and the row types registered in ShoppingCartFeature let {@code asList(...)}
 * turn it straight into typed objects — the same conversion API existing Cucumber glue uses.
 */
public class ShoppingCartTest extends ShoppingCartScenarios {

    private List<Product> products;
    private List<User> users;

    @Override
    public void myCartContainsTheFollowingProducts(DataTable dataTable) {
        products = dataTable.asList(Product.class);
    }

    @Override
    public void theCartShouldContain$p1Products(Integer expectedCount) {
        assertEquals(expectedCount, products.size());
    }

    @Override
    public void theFollowingUsersExist(DataTable dataTable) {
        users = dataTable.asList(User.class);
    }

    @Override
    public void theSystemShouldHave$p1Users(Integer expectedCount) {
        assertEquals(expectedCount, users.size());
    }
}
