Feature: WithDataTableParameters
  As a developer or CI pipeline consuming SpecBinder execution reports
  I want each step entry that receives a data table to include the table rows
    as structured JSON in the arguments array, so that I can see exactly what
    structured data was passed to each step
  So that I can debug failures and audit test behavior without re-running the suite

  Rule: step reports include the data table rows as structured JSON in the arguments array

    Scenario: a step with a data table passes alongside a step without parameters
      Given a feature file under path "fixtures/datatable-passing.feature" with the following content:
        """
        Feature: DataTablePassing

          Scenario: Register users from a table
            Given the following users:
              | name  | role  |
              | Alice | admin |
              | Bob   | user  |
            Then the system is ready
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;
        import java.util.List;

        @Gherkin2JUnit("fixtures/datatable-passing.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class DataTablePassingFeature {

            public static class UsersParam {
                private final String name;
                private final String role;

                public UsersParam(String name, String role) {
                    this.name = name;
                    this.role = role;
                }

                public String name() { return name; }
                public String role() { return role; }
            }

            public void theFollowingUsers(List<UsersParam> users) { }
            public void theSystemIsReady() { }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import java.util.List;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("DataTablePassing")
        @SourceFilePath("fixtures/datatable-passing.feature")
        public class DataTablePassingTest extends DataTablePassingFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: Register users from a table")
            public void scenario_1() {
                theFollowingUsers(
                        List.of(
                                new UsersParam(
                                        "Alice",
                                        "admin"
                                ),
                                new UsersParam(
                                        "Bob",
                                        "user"
                                )
                        ));
                theSystemIsReady();
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/datatable-passing.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/datatable-passing.feature",
          "displayName" : "DataTablePassing",
          "generatedClass" : "fixtures.DataTablePassingTest",
          "executedAt" : "<ts>",
          "totalDurationMs" : 0,
          "summary" : {
            "passed" : 1,
            "failed" : 0,
            "aborted" : 0,
            "skipped" : 0
          },
          "scenarios" : [ {
            "type" : "scenario",
            "id" : "fixtures.DataTablePassingTest#scenario_1",
            "displayName" : "Scenario: Register users from a table",
            "status" : "passed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "theFollowingUsers",
              "arguments" : [ [ {
                "name" : "Alice",
                "role" : "admin"
              }, {
                "name" : "Bob",
                "role" : "user"
              } ] ],
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            }, {
              "methodName" : "theSystemIsReady",
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            } ]
          } ]
        }
        """

  Rule: when a step with a data table fails the error and table data are both captured

    Scenario: a data table step fails and subsequent steps are skipped
      Given a feature file under path "fixtures/datatable-failing.feature" with the following content:
        """
        Feature: DataTableFailing

          Scenario: Import fails on bad data
            Given the following products:
              | sku   | price |
              | AB100 | 9.99  |
              | AB200 | -5.00 |
            When the import is triggered
            Then the catalog is updated
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;
        import java.util.List;

        @Gherkin2JUnit("fixtures/datatable-failing.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class DataTableFailingFeature {

            public static class ProductsParam {
                private final String sku;
                private final Double price;

                public ProductsParam(String sku, Double price) {
                    this.sku = sku;
                    this.price = price;
                }

                public String sku() { return sku; }
                public Double price() { return price; }
            }

            public void theFollowingProducts(List<ProductsParam> products) {
                for (ProductsParam row : products) {
                    if (row.price() < 0) {
                        throw new AssertionError("negative price for sku " + row.sku());
                    }
                }
            }
            public void theImportIsTriggered() { }
            public void theCatalogIsUpdated() { }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import java.util.List;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("DataTableFailing")
        @SourceFilePath("fixtures/datatable-failing.feature")
        public class DataTableFailingTest extends DataTableFailingFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: Import fails on bad data")
            public void scenario_1() {
                theFollowingProducts(
                        List.of(
                                new ProductsParam(
                                        "AB100",
                                        9.99
                                ),
                                new ProductsParam(
                                        "AB200",
                                        -5.00
                                )
                        ));
                theImportIsTriggered();
                theCatalogIsUpdated();
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/datatable-failing.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/datatable-failing.feature",
          "displayName" : "DataTableFailing",
          "generatedClass" : "fixtures.DataTableFailingTest",
          "executedAt" : "<ts>",
          "totalDurationMs" : 0,
          "summary" : {
            "passed" : 0,
            "failed" : 1,
            "aborted" : 0,
            "skipped" : 0
          },
          "scenarios" : [ {
            "type" : "scenario",
            "id" : "fixtures.DataTableFailingTest#scenario_1",
            "displayName" : "Scenario: Import fails on bad data",
            "status" : "failed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "theFollowingProducts",
              "arguments" : [ [ {
                "sku" : "AB100",
                "price" : 9.99
              }, {
                "sku" : "AB200",
                "price" : -5.0
              } ] ],
              "status" : "failed",
              "startedAt" : "<ts>",
              "durationMs" : 0,
              "error" : {
                "type" : "java.lang.AssertionError",
                "message" : "negative price for sku AB200",
                "stackTrace" : "<stackTrace>"
              }
            }, {
              "methodName" : "theImportIsTriggered",
              "status" : "skipped"
            }, {
              "methodName" : "theCatalogIsUpdated",
              "status" : "skipped"
            } ]
          } ]
        }
        """

  Rule: steps combining inline parameters with a data table capture all arguments in positional order

    Scenario: a step has both an inline string parameter and a data table
      Given a feature file under path "fixtures/datatable-mixed.feature" with the following content:
        """
        Feature: DataTableMixed

          Scenario: Assign roles within a team
            When the manager "Carol" assigns roles:
              | member | role      |
              | Dave   | developer |
              | Eve    | tester    |
            Then the team is configured
        """
      And the following SpecBinder marker class:
        """
        package fixtures;

        import dev.specbinder.annotations.Gherkin2JUnit;
        import dev.specbinder.reporter.SpecBinderReporter;
        import org.junit.jupiter.api.extension.ExtendWith;
        import java.util.List;

        @Gherkin2JUnit("fixtures/datatable-mixed.feature")
        @ExtendWith(SpecBinderReporter.class)
        public abstract class DataTableMixedFeature {

            public static class RolesParam {
                private final String member;
                private final String role;

                public RolesParam(String member, String role) {
                    this.member = member;
                    this.role = role;
                }

                public String member() { return member; }
                public String role() { return role; }
            }

            public void theManagerAssignsRoles(String manager, List<RolesParam> roles) { }
            public void theTeamIsConfigured() { }
        }
        """
      And the following SpecBinder-generated test class:
        """
        package fixtures;

        import dev.specbinder.annotations.output.SourceFilePath;
        import dev.specbinder.annotations.output.SourceLine;
        import java.util.List;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.Test;

        @DisplayName("DataTableMixed")
        @SourceFilePath("fixtures/datatable-mixed.feature")
        public class DataTableMixedTest extends DataTableMixedFeature {

            @Test
            @SourceLine(3)
            @DisplayName("Scenario: Assign roles within a team")
            public void scenario_1() {
                theManagerAssignsRoles("Carol",
                        List.of(
                                new RolesParam(
                                        "Dave",
                                        "developer"
                                ),
                                new RolesParam(
                                        "Eve",
                                        "tester"
                                )
                        ));
                theTeamIsConfigured();
            }
        }
        """
      When the test class is executed
      Then the produced report at "fixtures/datatable-mixed.feature.json" should match:
        """
        {
          "schemaVersion" : 3,
          "sourceFilePath" : "fixtures/datatable-mixed.feature",
          "displayName" : "DataTableMixed",
          "generatedClass" : "fixtures.DataTableMixedTest",
          "executedAt" : "<ts>",
          "totalDurationMs" : 0,
          "summary" : {
            "passed" : 1,
            "failed" : 0,
            "aborted" : 0,
            "skipped" : 0
          },
          "scenarios" : [ {
            "type" : "scenario",
            "id" : "fixtures.DataTableMixedTest#scenario_1",
            "displayName" : "Scenario: Assign roles within a team",
            "status" : "passed",
            "sourceLine" : 3,
            "startedAt" : "<ts>",
            "durationMs" : 0,
            "steps" : [ {
              "methodName" : "theManagerAssignsRoles",
              "arguments" : [ "Carol", [ {
                "member" : "Dave",
                "role" : "developer"
              }, {
                "member" : "Eve",
                "role" : "tester"
              } ] ],
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            }, {
              "methodName" : "theTeamIsConfigured",
              "status" : "passed",
              "startedAt" : "<ts>",
              "durationMs" : 0
            } ]
          } ]
        }
        """
