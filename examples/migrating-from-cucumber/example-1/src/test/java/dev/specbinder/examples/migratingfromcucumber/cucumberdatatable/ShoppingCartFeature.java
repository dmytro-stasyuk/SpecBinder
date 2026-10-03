package dev.specbinder.examples.migratingfromcucumber.cucumberdatatable;

import dev.specbinder.annotations.Gherkin2JUnit;
import io.cucumber.datatable.DataTable;
import io.cucumber.datatable.DataTableType;
import io.cucumber.datatable.DataTableTypeRegistry;
import io.cucumber.datatable.DataTableTypeRegistryTableConverter;

import java.util.Locale;
import java.util.Map;

/**
 * Demonstrates CUCUMBER_DATA_TABLE mode with Cucumber's DataTable API.
 * The generated code passes DataTable objects to step methods, and you
 * use Cucumber's type conversion to map rows to POJOs.
 *
 * You must provide a getTableConverter() method that the generated
 * createDataTable() helper uses to parse the table text. It lives here,
 * in the marker's hierarchy, together with the row types it converts to;
 * the step methods themselves are implemented in ShoppingCartTest.
 *
 * No path in @Gherkin2JUnit — the processor discovers the co-located
 * ShoppingCart.feature in this package by convention.
 */
@Gherkin2JUnit
public abstract class ShoppingCartFeature extends BaseFeature {

    protected DataTableTypeRegistry registry;
    protected DataTable.TableConverter tableConverter;

    public ShoppingCartFeature() {
        registry = new DataTableTypeRegistry(Locale.ENGLISH);

        registry.defineDataTableType(new DataTableType(
                Product.class,
                (Map<String, String> row) -> new Product(
                        row.get("name"),
                        Integer.parseInt(row.get("qty")),
                        Double.parseDouble(row.get("unit price"))
                )
        ));

        registry.defineDataTableType(new DataTableType(
                User.class,
                (Map<String, String> row) -> new User(
                        row.get("username"),
                        row.get("email"),
                        row.get("role")
                )
        ));

        tableConverter = new DataTableTypeRegistryTableConverter(registry);
    }

    /**
     * Required by the generated createDataTable() helper method.
     */
    protected DataTable.TableConverter getTableConverter() {
        return tableConverter;
    }

    public record Product(String name, int qty, double unitPrice) {
    }

    public record User(String username, String email, String role) {
    }
}
