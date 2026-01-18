package dev.specbinder.examples.featureprocessor;

import dev.specbinder.annotations.Feature2JUnit;

import java.util.List;
import java.util.Map;

/**
 * Demonstrates how Gherkin data tables are converted to DataTable parameters in step methods.
 * Data tables allow passing structured tabular data to steps for complex test scenarios.
 */
@Feature2JUnit("features/DataTables.feature")
public abstract class DataTablesFeature {

    public void givenICreateTheFollowingUsers(List<Map<String, String>> data) {
        // TODO: Implement step with List<Map<String, String>> parameter
    }

    public void thenTheSystemShouldHave$p1Users(String p1) {
        // TODO: Implement step with parameter: p1
    }

    public void whenICheckTheInventory(List<Map<String, String>> data) {
        // TODO: Implement step with List<Map<String, String>> parameter
    }

    public void thenAllProductsShouldBeInStock() {
        // TODO: Implement step
    }
}
