Feature: ListOfObjectsAndFieldInference
  As a test developer using Gherkin steps with data tables configured as LIST_OF_OBJECT_PARAMS
  I want data table column values to be automatically typed to create strongly-typed parameter object fields
  So that I can use generated parameter classes with appropriate field types without manual type conversion

  - Each data table column value is analyzed to determine its field type in the generated parameter class
  - Type checking follows the same precedence order as simple parameters: Boolean, Integer, Long, Double, Character, then String
  - All rows in the data table are analyzed, and the most specific type that accommodates all values is selected
  - If no wrapper type matches, String is used as the default field type
  - Field names are derived from the header row with appropriate camel-casing

  Rule: Integer type inference for data table fields
  - A field is typed as Integer if all values in that column are valid 32-bit signed integers
  - Values must be parseable by Integer.parseInt() without throwing NumberFormatException
  - Generated parameter class uses Java wrapper type: Integer
  - Integer inference is checked after Boolean

    Scenario: Data table column with integer values generates Integer field
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class IntegerFieldFeature {
      }
      """
      And the following feature file:
        """
        Feature: Integer Field Test
          Scenario: Test with integer column
            Given the following users:
              | name  | age | score |
              | Alice | 30  | 100   |
              | Bob   | 25  | -50   |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Integer;
        import java.lang.String;
        import java.util.List;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Integer Field Test
         */
        @DisplayName("IntegerFieldFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/IntegerFieldFeature.feature")
        public class IntegerFieldFeatureTest extends IntegerFieldFeature {
            public void theFollowingUsers(List<UsersParam> users) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test with integer column")
            public void scenario_1() {
                /*
                 * Given the following users:
                 *   | name  | age | score |
                 *   | Alice | 30  | 100   |
                 *   | Bob   | 25  | -50   |
                 */
                theFollowingUsers(
                        List.of(
                                new UsersParam(
                                        "Alice",
                                        30,
                                        100
                                ),
                                new UsersParam(
                                        "Bob",
                                        25,
                                        -50
                                )
                        ));
            }

            public static class UsersParam {
                private final String name;

                private final Integer age;

                private final Integer score;

                public UsersParam(String name, Integer age, Integer score) {
                    this.name = name;
                    this.age = age;
                    this.score = score;
                }

                public String name() {
                    return this.name;
                }

                public Integer age() {
                    return this.age;
                }

                public Integer score() {
                    return this.score;
                }
            }
        }
        """

    Scenario: Data table column with empty cells and integer values generates Integer field with nulls
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class IntegerWithEmptyCellsFeature {
      }
      """
      And the following feature file:
        """
        Feature: Integer Field with Empty Cells Test
          Scenario: Test with integer column containing empty cells
            Given the following users:
              | name  | age | score |
              | Alice | 30  | 100   |
              | Bob   |     | -50   |
              | Carol | 28  |       |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Integer;
        import java.lang.String;
        import java.util.List;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Integer Field with Empty Cells Test
         */
        @DisplayName("IntegerWithEmptyCellsFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/IntegerWithEmptyCellsFeature.feature")
        public class IntegerWithEmptyCellsFeatureTest extends IntegerWithEmptyCellsFeature {
            public void theFollowingUsers(List<UsersParam> users) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test with integer column containing empty cells")
            public void scenario_1() {
                /*
                 * Given the following users:
                 *   | name  | age | score |
                 *   | Alice | 30  | 100   |
                 *   | Bob   |     | -50   |
                 *   | Carol | 28  |       |
                 */
                theFollowingUsers(
                        List.of(
                                new UsersParam(
                                        "Alice",
                                        30,
                                        100
                                ),
                                new UsersParam(
                                        "Bob",
                                        null,
                                        -50
                                ),
                                new UsersParam(
                                        "Carol",
                                        28,
                                        null
                                )
                        ));
            }

            public static class UsersParam {
                private final String name;

                private final Integer age;

                private final Integer score;

                public UsersParam(String name, Integer age, Integer score) {
                    this.name = name;
                    this.age = age;
                    this.score = score;
                }

                public String name() {
                    return this.name;
                }

                public Integer age() {
                    return this.age;
                }

                public Integer score() {
                    return this.score;
                }
            }
        }
        """

  Rule: Long type inference for data table fields
  - A field is typed as Long if all values in that column are valid 64-bit signed integers
  - This includes values that exceed Integer range but fit within Long range
  - Generated parameter class uses Java wrapper type: Long
  - Long inference is checked after Integer

    Scenario: Data table column with long values generates Long field
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class LongFieldFeature {
      }
      """
      And the following feature file:
        """
        Feature: Long Field Test
          Scenario: Test with long column
            Given the following accounts:
              | name    | balance      |
              | Savings | 2147483648   |
              | Checking| -2147483649  |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Long;
        import java.lang.String;
        import java.util.List;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Long Field Test
         */
        @DisplayName("LongFieldFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/LongFieldFeature.feature")
        public class LongFieldFeatureTest extends LongFieldFeature {
            public void theFollowingAccounts(List<AccountsParam> accounts) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test with long column")
            public void scenario_1() {
                /*
                 * Given the following accounts:
                 *   | name     | balance     |
                 *   | Savings  | 2147483648  |
                 *   | Checking | -2147483649 |
                 */
                theFollowingAccounts(
                        List.of(
                                new AccountsParam(
                                        "Savings",
                                        2147483648L
                                ),
                                new AccountsParam(
                                        "Checking",
                                        -2147483649L
                                )
                        ));
            }

            public static class AccountsParam {
                private final String name;

                private final Long balance;

                public AccountsParam(String name, Long balance) {
                    this.name = name;
                    this.balance = balance;
                }

                public String name() {
                    return this.name;
                }

                public Long balance() {
                    return this.balance;
                }
            }
        }
        """

    Scenario: Data table column with empty cells and long values generates Long field with nulls
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class LongWithEmptyCellsFeature {
      }
      """
      And the following feature file:
        """
        Feature: Long Field with Empty Cells Test
          Scenario: Test with long column containing empty cells
            Given the following accounts:
              | name       | balance      | limit        |
              | Savings    | 2147483648   | 9000000000   |
              | Checking   |              | -2147483649  |
              | Investment | -9000000000  |              |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Long;
        import java.lang.String;
        import java.util.List;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Long Field with Empty Cells Test
         */
        @DisplayName("LongWithEmptyCellsFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/LongWithEmptyCellsFeature.feature")
        public class LongWithEmptyCellsFeatureTest extends LongWithEmptyCellsFeature {
            public void theFollowingAccounts(List<AccountsParam> accounts) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test with long column containing empty cells")
            public void scenario_1() {
                /*
                 * Given the following accounts:
                 *   | name       | balance     | limit       |
                 *   | Savings    | 2147483648  | 9000000000  |
                 *   | Checking   |             | -2147483649 |
                 *   | Investment | -9000000000 |             |
                 */
                theFollowingAccounts(
                        List.of(
                                new AccountsParam(
                                        "Savings",
                                        2147483648L,
                                        9000000000L
                                ),
                                new AccountsParam(
                                        "Checking",
                                        null,
                                        -2147483649L
                                ),
                                new AccountsParam(
                                        "Investment",
                                        -9000000000L,
                                        null
                                )
                        ));
            }

            public static class AccountsParam {
                private final String name;

                private final Long balance;

                private final Long limit;

                public AccountsParam(String name, Long balance, Long limit) {
                    this.name = name;
                    this.balance = balance;
                    this.limit = limit;
                }

                public String name() {
                    return this.name;
                }

                public Long balance() {
                    return this.balance;
                }

                public Long limit() {
                    return this.limit;
                }
            }
        }
        """

  Rule: Double type inference for data table fields
  - A field is typed as Double if all values in that column are valid floating-point numbers
  - This includes integer values, decimal values, and scientific notation
  - Generated parameter class uses Java wrapper type: Double
  - Double inference is checked after Long

    Scenario: Data table column with double values generates Double field
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class DoubleFieldFeature {
      }
      """
      And the following feature file:
        """
        Feature: Double Field Test
          Scenario: Test with double column
            Given the following products:
              | name   | price | discount |
              | Widget | 19.99 | 0.15     |
              | Gadget | 29.50 | 0.20     |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Double;
        import java.lang.String;
        import java.util.List;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Double Field Test
         */
        @DisplayName("DoubleFieldFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/DoubleFieldFeature.feature")
        public class DoubleFieldFeatureTest extends DoubleFieldFeature {
            public void theFollowingProducts(List<ProductsParam> products) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test with double column")
            public void scenario_1() {
                /*
                 * Given the following products:
                 *   | name   | price | discount |
                 *   | Widget | 19.99 | 0.15     |
                 *   | Gadget | 29.50 | 0.20     |
                 */
                theFollowingProducts(
                        List.of(
                                new ProductsParam(
                                        "Widget",
                                        19.99,
                                        0.15
                                ),
                                new ProductsParam(
                                        "Gadget",
                                        29.50,
                                        0.20
                                )
                        ));
            }

            public static class ProductsParam {
                private final String name;

                private final Double price;

                private final Double discount;

                public ProductsParam(String name, Double price, Double discount) {
                    this.name = name;
                    this.price = price;
                    this.discount = discount;
                }

                public String name() {
                    return this.name;
                }

                public Double price() {
                    return this.price;
                }

                public Double discount() {
                    return this.discount;
                }
            }
        }
        """

    Scenario: Data table column with empty cells and double values generates Double field with nulls
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class DoubleWithEmptyCellsFeature {
      }
      """
      And the following feature file:
        """
        Feature: Double Field with Empty Cells Test
          Scenario: Test with double column containing empty cells
            Given the following products:
              | name   | price | discount |
              | Widget | 19.99 | 0.15     |
              | Gadget |       | 0.20     |
              | Tool   | 29.50 |          |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Double;
        import java.lang.String;
        import java.util.List;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Double Field with Empty Cells Test
         */
        @DisplayName("DoubleWithEmptyCellsFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/DoubleWithEmptyCellsFeature.feature")
        public class DoubleWithEmptyCellsFeatureTest extends DoubleWithEmptyCellsFeature {
            public void theFollowingProducts(List<ProductsParam> products) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test with double column containing empty cells")
            public void scenario_1() {
                /*
                 * Given the following products:
                 *   | name   | price | discount |
                 *   | Widget | 19.99 | 0.15     |
                 *   | Gadget |       | 0.20     |
                 *   | Tool   | 29.50 |          |
                 */
                theFollowingProducts(
                        List.of(
                                new ProductsParam(
                                        "Widget",
                                        19.99,
                                        0.15
                                ),
                                new ProductsParam(
                                        "Gadget",
                                        null,
                                        0.20
                                ),
                                new ProductsParam(
                                        "Tool",
                                        29.50,
                                        null
                                )
                        ));
            }

            public static class ProductsParam {
                private final String name;

                private final Double price;

                private final Double discount;

                public ProductsParam(String name, Double price, Double discount) {
                    this.name = name;
                    this.price = price;
                    this.discount = discount;
                }

                public String name() {
                    return this.name;
                }

                public Double price() {
                    return this.price;
                }

                public Double discount() {
                    return this.discount;
                }
            }
        }
        """

  Rule: Boolean type inference for data table fields
  - A field is typed as Boolean if all values in that column are "true" or "false" (case-insensitive)
  - Generated parameter class uses Java wrapper type: Boolean
  - Boolean inference has highest precedence in type checking

    Scenario: Data table column with boolean values generates Boolean field
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class BooleanFieldFeature {
      }
      """
      And the following feature file:
        """
        Feature: Boolean Field Test
          Scenario: Test with boolean column
            Given the following users:
              | name  | isActive |
              | Alice | true     |
              | Bob   | false    |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Boolean;
        import java.lang.String;
        import java.util.List;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Boolean Field Test
         */
        @DisplayName("BooleanFieldFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/BooleanFieldFeature.feature")
        public class BooleanFieldFeatureTest extends BooleanFieldFeature {
            public void theFollowingUsers(List<UsersParam> users) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test with boolean column")
            public void scenario_1() {
                /*
                 * Given the following users:
                 *   | name  | isActive |
                 *   | Alice | true     |
                 *   | Bob   | false    |
                 */
                theFollowingUsers(
                        List.of(
                                new UsersParam(
                                        "Alice",
                                        true
                                ),
                                new UsersParam(
                                        "Bob",
                                        false
                                )
                        ));
            }

            public static class UsersParam {
                private final String name;

                private final Boolean isActive;

                public UsersParam(String name, Boolean isActive) {
                    this.name = name;
                    this.isActive = isActive;
                }

                public String name() {
                    return this.name;
                }

                public Boolean isActive() {
                    return this.isActive;
                }
            }
        }
        """

    Scenario: Data table column with empty cells and boolean values generates Boolean field with nulls
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class BooleanWithEmptyCellsFeature {
      }
      """
      And the following feature file:
        """
        Feature: Boolean Field with Empty Cells Test
          Scenario: Test with boolean column containing empty cells
            Given the following users:
              | name  | isActive | isPremium |
              | Alice | true     | false     |
              | Bob   |          | true      |
              | Carol | false    |           |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Boolean;
        import java.lang.String;
        import java.util.List;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Boolean Field with Empty Cells Test
         */
        @DisplayName("BooleanWithEmptyCellsFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/BooleanWithEmptyCellsFeature.feature")
        public class BooleanWithEmptyCellsFeatureTest extends BooleanWithEmptyCellsFeature {
            public void theFollowingUsers(List<UsersParam> users) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test with boolean column containing empty cells")
            public void scenario_1() {
                /*
                 * Given the following users:
                 *   | name  | isActive | isPremium |
                 *   | Alice | true     | false     |
                 *   | Bob   |          | true      |
                 *   | Carol | false    |           |
                 */
                theFollowingUsers(
                        List.of(
                                new UsersParam(
                                        "Alice",
                                        true,
                                        false
                                ),
                                new UsersParam(
                                        "Bob",
                                        null,
                                        true
                                ),
                                new UsersParam(
                                        "Carol",
                                        false,
                                        null
                                )
                        ));
            }

            public static class UsersParam {
                private final String name;

                private final Boolean isActive;

                private final Boolean isPremium;

                public UsersParam(String name, Boolean isActive, Boolean isPremium) {
                    this.name = name;
                    this.isActive = isActive;
                    this.isPremium = isPremium;
                }

                public String name() {
                    return this.name;
                }

                public Boolean isActive() {
                    return this.isActive;
                }

                public Boolean isPremium() {
                    return this.isPremium;
                }
            }
        }
        """

  Rule: Character type inference for data table fields
  - A field is typed as Character if all values in that column are exactly one character long
  - Only single-character strings qualify for Character inference
  - Generated parameter class uses Java wrapper type: Character
  - Character inference is checked after Double

    Scenario: Data table column with single-character values generates Character field
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class CharacterFieldFeature {
      }
      """
      And the following feature file:
        """
        Feature: Character Field Test
          Scenario: Test with character column
            Given the following students:
              | name  | grade |
              | Alice | A     |
              | Bob   | B     |
              | Carol | C     |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Character;
        import java.lang.String;
        import java.util.List;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Character Field Test
         */
        @DisplayName("CharacterFieldFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/CharacterFieldFeature.feature")
        public class CharacterFieldFeatureTest extends CharacterFieldFeature {
            public void theFollowingStudents(List<StudentsParam> students) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test with character column")
            public void scenario_1() {
                /*
                 * Given the following students:
                 *   | name  | grade |
                 *   | Alice | A     |
                 *   | Bob   | B     |
                 *   | Carol | C     |
                 */
                theFollowingStudents(
                        List.of(
                                new StudentsParam(
                                        "Alice",
                                        'A'
                                ),
                                new StudentsParam(
                                        "Bob",
                                        'B'
                                ),
                                new StudentsParam(
                                        "Carol",
                                        'C'
                                )
                        ));
            }

            public static class StudentsParam {
                private final String name;

                private final Character grade;

                public StudentsParam(String name, Character grade) {
                    this.name = name;
                    this.grade = grade;
                }

                public String name() {
                    return this.name;
                }

                public Character grade() {
                    return this.grade;
                }
            }
        }
        """

    Scenario: Data table column with empty cells and single-character values generates Character field with nulls
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class CharacterWithEmptyCellsFeature {
      }
      """
      And the following feature file:
        """
        Feature: Character Field with Empty Cells Test
          Scenario: Test with character column containing empty cells
            Given the following students:
              | name  | grade | section |
              | Alice | A     | X       |
              | Bob   |       | Y       |
              | Carol | C     |         |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Character;
        import java.lang.String;
        import java.util.List;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Character Field with Empty Cells Test
         */
        @DisplayName("CharacterWithEmptyCellsFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/CharacterWithEmptyCellsFeature.feature")
        public class CharacterWithEmptyCellsFeatureTest extends CharacterWithEmptyCellsFeature {
            public void theFollowingStudents(List<StudentsParam> students) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test with character column containing empty cells")
            public void scenario_1() {
                /*
                 * Given the following students:
                 *   | name  | grade | section |
                 *   | Alice | A     | X       |
                 *   | Bob   |       | Y       |
                 *   | Carol | C     |         |
                 */
                theFollowingStudents(
                        List.of(
                                new StudentsParam(
                                        "Alice",
                                        'A',
                                        'X'
                                ),
                                new StudentsParam(
                                        "Bob",
                                        null,
                                        'Y'
                                ),
                                new StudentsParam(
                                        "Carol",
                                        'C',
                                        null
                                )
                        ));
            }

            public static class StudentsParam {
                private final String name;

                private final Character grade;

                private final Character section;

                public StudentsParam(String name, Character grade, Character section) {
                    this.name = name;
                    this.grade = grade;
                    this.section = section;
                }

                public String name() {
                    return this.name;
                }

                public Character grade() {
                    return this.grade;
                }

                public Character section() {
                    return this.section;
                }
            }
        }
        """

    Scenario: Data table column with multi-character values falls back to String
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class MultiCharFeature {
      }
      """
      And the following feature file:
        """
        Feature: Multi-Character Falls Back to String
          Scenario: Test with multi-character column
            Given the following students:
              | name  | grade |
              | Alice | AB    |
              | Bob   | BC    |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.String;
        import java.util.List;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Multi-Character Falls Back to String
         */
        @DisplayName("MultiCharFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MultiCharFeature.feature")
        public class MultiCharFeatureTest extends MultiCharFeature {
            public void theFollowingStudents(List<StudentsParam> students) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test with multi-character column")
            public void scenario_1() {
                /*
                 * Given the following students:
                 *   | name  | grade |
                 *   | Alice | AB    |
                 *   | Bob   | BC    |
                 */
                theFollowingStudents(
                        List.of(
                                new StudentsParam(
                                        "Alice",
                                        "AB"
                                ),
                                new StudentsParam(
                                        "Bob",
                                        "BC"
                                )
                        ));
            }

            public static class StudentsParam {
                private final String name;

                private final String grade;

                public StudentsParam(String name, String grade) {
                    this.name = name;
                    this.grade = grade;
                }

                public String name() {
                    return this.name;
                }

                public String grade() {
                    return this.grade;
                }
            }
        }
        """

  Rule: String type as fallback for data table fields
  - A field is typed as String if no wrapper type conversion succeeds for all values in that column
  - String is the default field type when values don't match any wrapper type pattern
  - String conversion always succeeds and serves as the ultimate fallback

    Scenario: Data table column with non-convertible values generates String field
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class StringFieldFeature {
      }
      """
      And the following feature file:
        """
        Feature: String Field Test
          Scenario: Test with string column
            Given the following users:
              | name  | status   |
              | Alice | active   |
              | Bob   | inactive |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.String;
        import java.util.List;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: String Field Test
         */
        @DisplayName("StringFieldFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/StringFieldFeature.feature")
        public class StringFieldFeatureTest extends StringFieldFeature {
            public void theFollowingUsers(List<UsersParam> users) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test with string column")
            public void scenario_1() {
                /*
                 * Given the following users:
                 *   | name  | status   |
                 *   | Alice | active   |
                 *   | Bob   | inactive |
                 */
                theFollowingUsers(
                        List.of(
                                new UsersParam(
                                        "Alice",
                                        "active"
                                ),
                                new UsersParam(
                                        "Bob",
                                        "inactive"
                                )
                        ));
            }

            public static class UsersParam {
                private final String name;

                private final String status;

                public UsersParam(String name, String status) {
                    this.name = name;
                    this.status = status;
                }

                public String name() {
                    return this.name;
                }

                public String status() {
                    return this.status;
                }
            }
        }
        """

    Scenario: Data table column with empty cells and string values generates String field with nulls
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class StringWithEmptyCellsFeature {
      }
      """
      And the following feature file:
        """
        Feature: String Field with Empty Cells Test
          Scenario: Test with string column containing empty cells
            Given the following users:
              | name  | status   | role     |
              | Alice | active   | admin    |
              | Bob   |          | user     |
              | Carol | inactive |          |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.String;
        import java.util.List;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: String Field with Empty Cells Test
         */
        @DisplayName("StringWithEmptyCellsFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/StringWithEmptyCellsFeature.feature")
        public class StringWithEmptyCellsFeatureTest extends StringWithEmptyCellsFeature {
            public void theFollowingUsers(List<UsersParam> users) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test with string column containing empty cells")
            public void scenario_1() {
                /*
                 * Given the following users:
                 *   | name  | status   | role  |
                 *   | Alice | active   | admin |
                 *   | Bob   |          | user  |
                 *   | Carol | inactive |       |
                 */
                theFollowingUsers(
                        List.of(
                                new UsersParam(
                                        "Alice",
                                        "active",
                                        "admin"
                                ),
                                new UsersParam(
                                        "Bob",
                                        null,
                                        "user"
                                ),
                                new UsersParam(
                                        "Carol",
                                        "inactive",
                                        null
                                )
                        ));
            }

            public static class UsersParam {
                private final String name;

                private final String status;

                private final String role;

                public UsersParam(String name, String status, String role) {
                    this.name = name;
                    this.status = status;
                    this.role = role;
                }

                public String name() {
                    return this.name;
                }

                public String status() {
                    return this.status;
                }

                public String role() {
                    return this.role;
                }
            }
        }
        """

  Rule: Mixed type values in same column use most general type
  - When different rows have values that would infer different types for the same column, use String as the most general type
  - This ensures all values can be accommodated in the generated parameter class
  - Type consistency is validated across all data table rows, not just the first row

    Scenario: Data table column with mixed types falls back to String
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class MixedTypeFeature {
      }
      """
      And the following feature file:
        """
        Feature: Mixed Type Column Test
          Scenario: Test with mixed type values
            Given the following items:
              | name   | value  |
              | Item1  | 42     |
              | Item2  | text   |
              | Item3  | 3.14   |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.String;
        import java.util.List;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Mixed Type Column Test
         */
        @DisplayName("MixedTypeFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MixedTypeFeature.feature")
        public class MixedTypeFeatureTest extends MixedTypeFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test with mixed type values")
            public void scenario_1() {
                /*
                 * Given the following items:
                 *   | name  | value |
                 *   | Item1 | 42    |
                 *   | Item2 | text  |
                 *   | Item3 | 3.14  |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        "Item1",
                                        "42"
                                ),
                                new ItemsParam(
                                        "Item2",
                                        "text"
                                ),
                                new ItemsParam(
                                        "Item3",
                                        "3.14"
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String value;

                public ItemsParam(String name, String value) {
                    this.name = name;
                    this.value = value;
                }

                public String name() {
                    return this.name;
                }

                public String value() {
                    return this.value;
                }
            }
        }
        """

  Rule: Multiple columns can have different inferred types
  - Each column in a data table is analyzed independently
  - Different columns can have different inferred types based on their values
  - The generated parameter class includes the appropriate type for each field

    Scenario: Data table with multiple columns of different types
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class MultiTypeFeature {
      }
      """
      And the following feature file:
        """
        Feature: Multiple Column Types Test
          Scenario: Test with various column types
            Given the following users:
              | name  | age | balance  | isActive | grade |
              | Alice | 30  | 1000.50  | true     | A     |
              | Bob   | 25  | 500.75   | false    | B     |
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Boolean;
        import java.lang.Character;
        import java.lang.Double;
        import java.lang.Integer;
        import java.lang.String;
        import java.util.List;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Multiple Column Types Test
         */
        @DisplayName("MultiTypeFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MultiTypeFeature.feature")
        public class MultiTypeFeatureTest extends MultiTypeFeature {
            public void theFollowingUsers(List<UsersParam> users) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test with various column types")
            public void scenario_1() {
                /*
                 * Given the following users:
                 *   | name  | age | balance | isActive | grade |
                 *   | Alice | 30  | 1000.50 | true     | A     |
                 *   | Bob   | 25  | 500.75  | false    | B     |
                 */
                theFollowingUsers(
                        List.of(
                                new UsersParam(
                                        "Alice",
                                        30,
                                        1000.50,
                                        true,
                                        'A'
                                ),
                                new UsersParam(
                                        "Bob",
                                        25,
                                        500.75,
                                        false,
                                        'B'
                                )
                        ));
            }

            public static class UsersParam {
                private final String name;

                private final Integer age;

                private final Double balance;

                private final Boolean isActive;

                private final Character grade;

                public UsersParam(String name, Integer age, Double balance, Boolean isActive,
                        Character grade) {
                    this.name = name;
                    this.age = age;
                    this.balance = balance;
                    this.isActive = isActive;
                    this.grade = grade;
                }

                public String name() {
                    return this.name;
                }

                public Integer age() {
                    return this.age;
                }

                public Double balance() {
                    return this.balance;
                }

                public Boolean isActive() {
                    return this.isActive;
                }

                public Character grade() {
                    return this.grade;
                }
            }
        }
        """

