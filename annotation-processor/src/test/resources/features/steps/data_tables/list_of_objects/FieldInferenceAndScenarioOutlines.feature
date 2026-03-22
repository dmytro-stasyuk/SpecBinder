Feature: FieldInferenceAndScenarioOutlines
  As a test developer using Gherkin Scenario Outlines with data tables configured as LIST_OF_OBJECT_PARAMS
  I want data table column types to be inferred correctly when cells contain placeholders referencing Examples columns
  So that generated parameter classes have appropriate field types even when values come from parameterized examples

  Rule: Type inference for Integer type combines Examples values and data table literal values

    Scenario: with only references to Examples values that are all integers
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class PlaceholderOnlyFeature {
      }
      """
      And the following feature file:
        """
        Feature: Placeholder Only Test
          Scenario Outline: Test with placeholder-only column
            Given the following items:
              | name   | quantity   |
              | <name> | <quantity> |
            Examples:
              | name  | quantity |
              | Apple | 10       |
              | Banana| 20       |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Placeholder Only Test
         */
        @DisplayName("PlaceholderOnlyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/PlaceholderOnlyFeature.feature")
        public class PlaceholderOnlyFeatureTest extends PlaceholderOnlyFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name   | quantity
                            Apple  | 10
                            Banana | 20
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with placeholder-only column")
            public void scenario_1(String name, Integer quantity) {
                /*
                 * Given the following items:
                 *   | name   | quantity   |
                 *   | <name> | <quantity> |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        quantity
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final Integer quantity;

                public ItemsParam(String name, Integer quantity) {
                    this.name = name;
                    this.quantity = quantity;
                }

                public String name() {
                    return this.name;
                }

                public Integer quantity() {
                    return this.quantity;
                }
            }
        }
        """

    Scenario: with only references to Examples values that are mixed type
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class MixedExamplesFeature {
      }
      """
      And the following feature file:
        """
        Feature: Mixed Examples Test
          Scenario Outline: Test with mixed type examples
            Given the following items:
              | name   | quantity   |
              | <name> | <quantity> |
            Examples:
              | name   | quantity |
              | Apple  | 10       |
              | Banana | many     |
              | Orange | 5        |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Mixed Examples Test
         */
        @DisplayName("MixedExamplesFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MixedExamplesFeature.feature")
        public class MixedExamplesFeatureTest extends MixedExamplesFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name   | quantity
                            Apple  | 10
                            Banana | many
                            Orange | 5
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with mixed type examples")
            public void scenario_1(String name, String quantity) {
                /*
                 * Given the following items:
                 *   | name   | quantity   |
                 *   | <name> | <quantity> |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        quantity
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String quantity;

                public ItemsParam(String name, String quantity) {
                    this.name = name;
                    this.quantity = quantity;
                }

                public String name() {
                    return this.name;
                }

                public String quantity() {
                    return this.quantity;
                }
            }
        }
        """

    Scenario: with references to Examples values that are mixed type and literal values that are all numbers
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class MixedExamplesLiteralNumbersFeature {
      }
      """
      And the following feature file:
        """
        Feature: Mixed Examples with Literal Numbers Test
          Scenario Outline: Test with mixed examples and literal numbers
            Given the following items:
              | name   | quantity   |
              | <name> | <quantity> |
              | Mango  | 15         |
              | Grape  | 20         |
            Examples:
              | name   | quantity |
              | Apple  | 10       |
              | Banana | many     |
              | Orange | 5        |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Mixed Examples with Literal Numbers Test
         */
        @DisplayName("MixedExamplesLiteralNumbersFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MixedExamplesLiteralNumbersFeature.feature")
        public class MixedExamplesLiteralNumbersFeatureTest extends MixedExamplesLiteralNumbersFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name   | quantity
                            Apple  | 10
                            Banana | many
                            Orange | 5
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with mixed examples and literal numbers")
            public void scenario_1(String name, String quantity) {
                /*
                 * Given the following items:
                 *   | name   | quantity   |
                 *   | <name> | <quantity> |
                 *   | Mango  | 15         |
                 *   | Grape  | 20         |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        quantity
                                ),
                                new ItemsParam(
                                        "Mango",
                                        "15"
                                ),
                                new ItemsParam(
                                        "Grape",
                                        "20"
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String quantity;

                public ItemsParam(String name, String quantity) {
                    this.name = name;
                    this.quantity = quantity;
                }

                public String name() {
                    return this.name;
                }

                public String quantity() {
                    return this.quantity;
                }
            }
        }
        """

    Scenario: with references to Examples values that are all integers and literal values that are also text
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class LiteralTextFeature {
      }
      """
      And the following feature file:
        """
        Feature: Literal Text Row Test
          Scenario Outline: Test with literal text in data table
            Given the following items:
              | name   | quantity   |
              | <name> | <quantity> |
              | Mango  | unknown    |
              | Grape  | 15         |
            Examples:
              | name   | quantity |
              | Apple  | 10       |
              | Banana | 20       |
        """
      When the generator is run
      Then the following java source file should be be generated:
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Literal Text Row Test
         */
        @DisplayName("LiteralTextFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/LiteralTextFeature.feature")
        public class LiteralTextFeatureTest extends LiteralTextFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name   | quantity
                            Apple  | 10
                            Banana | 20
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with literal text in data table")
            public void scenario_1(String name, Integer quantity) {
                /*
                 * Given the following items:
                 *   | name   | quantity   |
                 *   | <name> | <quantity> |
                 *   | Mango  | unknown    |
                 *   | Grape  | 15         |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        quantity
                                ),
                                new ItemsParam(
                                        "Mango",
                                        "unknown"
                                ),
                                new ItemsParam(
                                        "Grape",
                                        "15"
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String quantity;

                public ItemsParam(String name, String quantity) {
                    this.name = name;
                    this.quantity = quantity;
                }

                public String name() {
                    return this.name;
                }

                public String quantity() {
                    return this.quantity;
                }
            }
        }
        """
      And the compilation error should contain the following text:
        """
        error: incompatible types: java.lang.Integer cannot be converted to java.lang.String
        """

    Scenario: with multiple step invocations
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class MultipleStepsFeature {
      }
      """
      And the following feature file:
        """
        Feature: Multiple Steps Test
          Scenario Outline: Test with multiple steps having different data table types
            Given the following items:
              | name   | quantity |
              | Apple  | 10       |
              | Banana | 20       |
            And the following items:
              | name  | quantity |
              | Mango | many     |
              | Grape | 15       |
            And the following items:
              | name   | quantity   |
              | <name> | <quantity> |
            Examples:
              | name   | quantity |
              | Orange | 30       |
              | Kiwi   | 40       |
        """
      When the generator is run
      Then the following java source file should be be generated:
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Multiple Steps Test
         */
        @DisplayName("MultipleStepsFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MultipleStepsFeature.feature")
        public class MultipleStepsFeatureTest extends MultipleStepsFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name   | quantity
                            Orange | 30
                            Kiwi   | 40
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with multiple steps having different data table types")
            public void scenario_1(String name, Integer quantity) {
                /*
                 * Given the following items:
                 *   | name   | quantity |
                 *   | Apple  | 10       |
                 *   | Banana | 20       |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        "Apple",
                                        "10"
                                ),
                                new ItemsParam(
                                        "Banana",
                                        "20"
                                )
                        ));
                /*
                 * And the following items:
                 *   | name  | quantity |
                 *   | Mango | many     |
                 *   | Grape | 15       |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        "Mango",
                                        "many"
                                ),
                                new ItemsParam(
                                        "Grape",
                                        "15"
                                )
                        ));
                /*
                 * And the following items:
                 *   | name   | quantity   |
                 *   | <name> | <quantity> |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        quantity
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String quantity;

                public ItemsParam(String name, String quantity) {
                    this.name = name;
                    this.quantity = quantity;
                }

                public String name() {
                    return this.name;
                }

                public String quantity() {
                    return this.quantity;
                }
            }
        }
        """
      And the compilation error should contain the following text:
        """
        error: incompatible types: java.lang.Integer cannot be converted to java.lang.String
        """

    Scenario: with cell containing mixed literal text and placeholder reference
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class MixedLiteralPlaceholderCellFeature {
      }
      """
      And the following feature file:
        """
        Feature: Mixed Literal and Placeholder Cell Test
          Scenario Outline: Test with cell mixing literal text and placeholder
            Given the following items:
              | name   | priority        |
              | <name> | High <quantity> |
              | Backup | 10              |
            Examples:
              | name   | quantity |
              | Widget | 10       |
              | Gadget | 5        |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Mixed Literal and Placeholder Cell Test
         */
        @DisplayName("MixedLiteralPlaceholderCellFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MixedLiteralPlaceholderCellFeature.feature")
        public class MixedLiteralPlaceholderCellFeatureTest extends MixedLiteralPlaceholderCellFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name   | quantity
                            Widget | 10
                            Gadget | 5
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with cell mixing literal text and placeholder")
            public void scenario_1(String name, Integer quantity) {
                /*
                 * Given the following items:
                 *   | name   | priority        |
                 *   | <name> | High <quantity> |
                 *   | Backup | 10              |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        "High <quantity>".replaceAll("<quantity>", quantity.toString())
                                ),
                                new ItemsParam(
                                        "Backup",
                                        "10"
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String priority;

                public ItemsParam(String name, String priority) {
                    this.name = name;
                    this.priority = priority;
                }

                public String name() {
                    return this.name;
                }

                public String priority() {
                    return this.priority;
                }
            }
        }
        """

  Rule: Type inference for Long type combines Examples values and data table literal values

    Scenario: with only references to Examples values that are all longs
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class LongPlaceholderOnlyFeature {
      }
      """
      And the following feature file:
        """
        Feature: Long Placeholder Only Test
          Scenario Outline: Test with long placeholder-only column
            Given the following items:
              | name   | fileSize   |
              | <name> | <fileSize> |
            Examples:
              | name      | fileSize       |
              | Document  | 9876543210     |
              | Archive   | 12345678901234 |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Long Placeholder Only Test
         */
        @DisplayName("LongPlaceholderOnlyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/LongPlaceholderOnlyFeature.feature")
        public class LongPlaceholderOnlyFeatureTest extends LongPlaceholderOnlyFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name     | fileSize
                            Document | 9876543210
                            Archive  | 12345678901234
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with long placeholder-only column")
            public void scenario_1(String name, Long fileSize) {
                /*
                 * Given the following items:
                 *   | name   | fileSize   |
                 *   | <name> | <fileSize> |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        fileSize
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final Long fileSize;

                public ItemsParam(String name, Long fileSize) {
                    this.name = name;
                    this.fileSize = fileSize;
                }

                public String name() {
                    return this.name;
                }

                public Long fileSize() {
                    return this.fileSize;
                }
            }
        }
        """

    Scenario: with only references to Examples values that are mixed type
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class LongMixedExamplesFeature {
      }
      """
      And the following feature file:
        """
        Feature: Long Mixed Examples Test
          Scenario Outline: Test with mixed type examples
            Given the following items:
              | name   | fileSize   |
              | <name> | <fileSize> |
            Examples:
              | name     | fileSize       |
              | Document | 9876543210     |
              | Archive  | unknown        |
              | Backup   | 12345678901234 |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Long Mixed Examples Test
         */
        @DisplayName("LongMixedExamplesFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/LongMixedExamplesFeature.feature")
        public class LongMixedExamplesFeatureTest extends LongMixedExamplesFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name     | fileSize
                            Document | 9876543210
                            Archive  | unknown
                            Backup   | 12345678901234
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with mixed type examples")
            public void scenario_1(String name, String fileSize) {
                /*
                 * Given the following items:
                 *   | name   | fileSize   |
                 *   | <name> | <fileSize> |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        fileSize
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String fileSize;

                public ItemsParam(String name, String fileSize) {
                    this.name = name;
                    this.fileSize = fileSize;
                }

                public String name() {
                    return this.name;
                }

                public String fileSize() {
                    return this.fileSize;
                }
            }
        }
        """

    Scenario: with references to Examples values that are mixed type and literal values that are all longs
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class LongMixedExamplesLiteralLongsFeature {
      }
      """
      And the following feature file:
        """
        Feature: Long Mixed Examples with Literal Longs Test
          Scenario Outline: Test with mixed examples and literal longs
            Given the following items:
              | name   | fileSize       |
              | <name> | <fileSize>     |
              | Extra1 | 5555555555555  |
              | Extra2 | 6666666666666  |
            Examples:
              | name     | fileSize       |
              | Document | 9876543210     |
              | Archive  | unknown        |
              | Backup   | 12345678901234 |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Long Mixed Examples with Literal Longs Test
         */
        @DisplayName("LongMixedExamplesLiteralLongsFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/LongMixedExamplesLiteralLongsFeature.feature")
        public class LongMixedExamplesLiteralLongsFeatureTest extends LongMixedExamplesLiteralLongsFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name     | fileSize
                            Document | 9876543210
                            Archive  | unknown
                            Backup   | 12345678901234
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with mixed examples and literal longs")
            public void scenario_1(String name, String fileSize) {
                /*
                 * Given the following items:
                 *   | name   | fileSize      |
                 *   | <name> | <fileSize>    |
                 *   | Extra1 | 5555555555555 |
                 *   | Extra2 | 6666666666666 |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        fileSize
                                ),
                                new ItemsParam(
                                        "Extra1",
                                        "5555555555555"
                                ),
                                new ItemsParam(
                                        "Extra2",
                                        "6666666666666"
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String fileSize;

                public ItemsParam(String name, String fileSize) {
                    this.name = name;
                    this.fileSize = fileSize;
                }

                public String name() {
                    return this.name;
                }

                public String fileSize() {
                    return this.fileSize;
                }
            }
        }
        """

    Scenario: with references to Examples values that are all longs and literal values that are also text
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class LongLiteralTextFeature {
      }
      """
      And the following feature file:
        """
        Feature: Long Literal Text Row Test
          Scenario Outline: Test with literal text in data table
            Given the following items:
              | name   | fileSize       |
              | <name> | <fileSize>     |
              | Extra1 | unknown        |
              | Extra2 | 5555555555555  |
            Examples:
              | name     | fileSize       |
              | Document | 9876543210     |
              | Archive  | 12345678901234 |
        """
      When the generator is run
      Then the following java source file should be be generated:
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Long Literal Text Row Test
         */
        @DisplayName("LongLiteralTextFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/LongLiteralTextFeature.feature")
        public class LongLiteralTextFeatureTest extends LongLiteralTextFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name     | fileSize
                            Document | 9876543210
                            Archive  | 12345678901234
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with literal text in data table")
            public void scenario_1(String name, Long fileSize) {
                /*
                 * Given the following items:
                 *   | name   | fileSize      |
                 *   | <name> | <fileSize>    |
                 *   | Extra1 | unknown       |
                 *   | Extra2 | 5555555555555 |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        fileSize
                                ),
                                new ItemsParam(
                                        "Extra1",
                                        "unknown"
                                ),
                                new ItemsParam(
                                        "Extra2",
                                        "5555555555555"
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String fileSize;

                public ItemsParam(String name, String fileSize) {
                    this.name = name;
                    this.fileSize = fileSize;
                }

                public String name() {
                    return this.name;
                }

                public String fileSize() {
                    return this.fileSize;
                }
            }
        }
        """
      And the compilation error should contain the following text:
        """
        error: incompatible types: java.lang.Long cannot be converted to java.lang.String
        """

    Scenario: with multiple step invocations
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class LongMultipleStepsFeature {
      }
      """
      And the following feature file:
        """
        Feature: Long Multiple Steps Test
          Scenario Outline: Test with multiple steps having different data table types
            Given the following items:
              | name   | fileSize      |
              | File1  | 9876543210    |
              | File2  | 1234567890123 |
            And the following items:
              | name  | fileSize |
              | File3 | unknown  |
              | File4 | 5555555  |
            And the following items:
              | name   | fileSize   |
              | <name> | <fileSize> |
            Examples:
              | name  | fileSize       |
              | File5 | 9999999999999  |
              | File6 | 8888888888888  |
        """
      When the generator is run
      Then the following java source file should be be generated:
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Long Multiple Steps Test
         */
        @DisplayName("LongMultipleStepsFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/LongMultipleStepsFeature.feature")
        public class LongMultipleStepsFeatureTest extends LongMultipleStepsFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name  | fileSize
                            File5 | 9999999999999
                            File6 | 8888888888888
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with multiple steps having different data table types")
            public void scenario_1(String name, Long fileSize) {
                /*
                 * Given the following items:
                 *   | name  | fileSize      |
                 *   | File1 | 9876543210    |
                 *   | File2 | 1234567890123 |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        "File1",
                                        "9876543210"
                                ),
                                new ItemsParam(
                                        "File2",
                                        "1234567890123"
                                )
                        ));
                /*
                 * And the following items:
                 *   | name  | fileSize |
                 *   | File3 | unknown  |
                 *   | File4 | 5555555  |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        "File3",
                                        "unknown"
                                ),
                                new ItemsParam(
                                        "File4",
                                        "5555555"
                                )
                        ));
                /*
                 * And the following items:
                 *   | name   | fileSize   |
                 *   | <name> | <fileSize> |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        fileSize
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String fileSize;

                public ItemsParam(String name, String fileSize) {
                    this.name = name;
                    this.fileSize = fileSize;
                }

                public String name() {
                    return this.name;
                }

                public String fileSize() {
                    return this.fileSize;
                }
            }
        }
        """
      And the compilation error should contain the following text:
        """
        error: incompatible types: java.lang.Long cannot be converted to java.lang.String
        """

    Scenario: with cell containing mixed literal text and long placeholder reference
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class MixedLiteralLongPlaceholderFeature {
      }
      """
      And the following feature file:
        """
        Feature: Mixed Literal and Long Placeholder Cell Test
          Scenario Outline: Test with cell mixing literal text and long placeholder
            Given the following items:
              | name   | sizeInfo           |
              | <name> | Size: <fileSize> B |
              | Backup | 500                |
            Examples:
              | name     | fileSize       |
              | Document | 9876543210     |
              | Archive  | 12345678901234 |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Mixed Literal and Long Placeholder Cell Test
         */
        @DisplayName("MixedLiteralLongPlaceholderFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MixedLiteralLongPlaceholderFeature.feature")
        public class MixedLiteralLongPlaceholderFeatureTest extends MixedLiteralLongPlaceholderFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name     | fileSize
                            Document | 9876543210
                            Archive  | 12345678901234
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with cell mixing literal text and long placeholder")
            public void scenario_1(String name, Long fileSize) {
                /*
                 * Given the following items:
                 *   | name   | sizeInfo           |
                 *   | <name> | Size: <fileSize> B |
                 *   | Backup | 500                |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        "Size: <fileSize> B".replaceAll("<fileSize>", fileSize.toString())
                                ),
                                new ItemsParam(
                                        "Backup",
                                        "500"
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String sizeInfo;

                public ItemsParam(String name, String sizeInfo) {
                    this.name = name;
                    this.sizeInfo = sizeInfo;
                }

                public String name() {
                    return this.name;
                }

                public String sizeInfo() {
                    return this.sizeInfo;
                }
            }
        }
        """

  Rule: Type inference for double type combines Examples values and data table literal values

    Scenario: with only references to Examples values that are all doubles
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class DoublePlaceholderOnlyFeature {
      }
      """
      And the following feature file:
        """
        Feature: Double Placeholder Only Test
          Scenario Outline: Test with double placeholder-only column
            Given the following items:
              | name   | price   |
              | <name> | <price> |
            Examples:
              | name   | price  |
              | Widget | 19.99  |
              | Gadget | 299.50 |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Double Placeholder Only Test
         */
        @DisplayName("DoublePlaceholderOnlyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/DoublePlaceholderOnlyFeature.feature")
        public class DoublePlaceholderOnlyFeatureTest extends DoublePlaceholderOnlyFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name   | price
                            Widget | 19.99
                            Gadget | 299.50
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with double placeholder-only column")
            public void scenario_1(String name, Double price) {
                /*
                 * Given the following items:
                 *   | name   | price   |
                 *   | <name> | <price> |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        price
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final Double price;

                public ItemsParam(String name, Double price) {
                    this.name = name;
                    this.price = price;
                }

                public String name() {
                    return this.name;
                }

                public Double price() {
                    return this.price;
                }
            }
        }
        """

    Scenario: with only references to Examples values that are mixed type
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class DoubleMixedExamplesFeature {
      }
      """
      And the following feature file:
        """
        Feature: Double Mixed Examples Test
          Scenario Outline: Test with mixed type examples
            Given the following items:
              | name   | price   |
              | <name> | <price> |
            Examples:
              | name   | price   |
              | Widget | 19.99   |
              | Gadget | unknown |
              | Tool   | 299.50  |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Double Mixed Examples Test
         */
        @DisplayName("DoubleMixedExamplesFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/DoubleMixedExamplesFeature.feature")
        public class DoubleMixedExamplesFeatureTest extends DoubleMixedExamplesFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name   | price
                            Widget | 19.99
                            Gadget | unknown
                            Tool   | 299.50
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with mixed type examples")
            public void scenario_1(String name, String price) {
                /*
                 * Given the following items:
                 *   | name   | price   |
                 *   | <name> | <price> |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        price
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String price;

                public ItemsParam(String name, String price) {
                    this.name = name;
                    this.price = price;
                }

                public String name() {
                    return this.name;
                }

                public String price() {
                    return this.price;
                }
            }
        }
        """

    Scenario: with references to Examples values that are mixed type and literal values that are all doubles
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class DoubleMixedExamplesLiteralDoublesFeature {
      }
      """
      And the following feature file:
        """
        Feature: Double Mixed Examples with Literal Doubles Test
          Scenario Outline: Test with mixed examples and literal doubles
            Given the following items:
              | name   | price   |
              | <name> | <price> |
              | Extra1 | 49.99   |
              | Extra2 | 99.50   |
            Examples:
              | name   | price   |
              | Widget | 19.99   |
              | Gadget | unknown |
              | Tool   | 299.50  |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Double Mixed Examples with Literal Doubles Test
         */
        @DisplayName("DoubleMixedExamplesLiteralDoublesFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/DoubleMixedExamplesLiteralDoublesFeature.feature")
        public class DoubleMixedExamplesLiteralDoublesFeatureTest extends DoubleMixedExamplesLiteralDoublesFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name   | price
                            Widget | 19.99
                            Gadget | unknown
                            Tool   | 299.50
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with mixed examples and literal doubles")
            public void scenario_1(String name, String price) {
                /*
                 * Given the following items:
                 *   | name   | price   |
                 *   | <name> | <price> |
                 *   | Extra1 | 49.99   |
                 *   | Extra2 | 99.50   |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        price
                                ),
                                new ItemsParam(
                                        "Extra1",
                                        "49.99"
                                ),
                                new ItemsParam(
                                        "Extra2",
                                        "99.50"
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String price;

                public ItemsParam(String name, String price) {
                    this.name = name;
                    this.price = price;
                }

                public String name() {
                    return this.name;
                }

                public String price() {
                    return this.price;
                }
            }
        }
        """

    Scenario: with references to Examples values that are all doubles and literal values that are also text
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class DoubleLiteralTextFeature {
      }
      """
      And the following feature file:
        """
        Feature: Double Literal Text Row Test
          Scenario Outline: Test with literal text in data table
            Given the following items:
              | name   | price   |
              | <name> | <price> |
              | Extra1 | unknown |
              | Extra2 | 49.99   |
            Examples:
              | name   | price  |
              | Widget | 19.99  |
              | Gadget | 299.50 |
        """
      When the generator is run
      Then the following java source file should be be generated:
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Double Literal Text Row Test
         */
        @DisplayName("DoubleLiteralTextFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/DoubleLiteralTextFeature.feature")
        public class DoubleLiteralTextFeatureTest extends DoubleLiteralTextFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name   | price
                            Widget | 19.99
                            Gadget | 299.50
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with literal text in data table")
            public void scenario_1(String name, Double price) {
                /*
                 * Given the following items:
                 *   | name   | price   |
                 *   | <name> | <price> |
                 *   | Extra1 | unknown |
                 *   | Extra2 | 49.99   |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        price
                                ),
                                new ItemsParam(
                                        "Extra1",
                                        "unknown"
                                ),
                                new ItemsParam(
                                        "Extra2",
                                        "49.99"
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String price;

                public ItemsParam(String name, String price) {
                    this.name = name;
                    this.price = price;
                }

                public String name() {
                    return this.name;
                }

                public String price() {
                    return this.price;
                }
            }
        }
        """
      And the compilation error should contain the following text:
        """
        error: incompatible types: java.lang.Double cannot be converted to java.lang.String
        """

    Scenario: with multiple step invocations
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class DoubleMultipleStepsFeature {
      }
      """
      And the following feature file:
        """
        Feature: Double Multiple Steps Test
          Scenario Outline: Test with multiple steps having different data table types
            Given the following items:
              | name   | price |
              | Item1  | 19.99 |
              | Item2  | 29.50 |
            And the following items:
              | name  | price   |
              | Item3 | unknown |
              | Item4 | 49.99   |
            And the following items:
              | name   | price   |
              | <name> | <price> |
            Examples:
              | name  | price  |
              | Item5 | 99.99  |
              | Item6 | 199.50 |
        """
      When the generator is run
      Then the following java source file should be be generated:
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Double Multiple Steps Test
         */
        @DisplayName("DoubleMultipleStepsFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/DoubleMultipleStepsFeature.feature")
        public class DoubleMultipleStepsFeatureTest extends DoubleMultipleStepsFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name  | price
                            Item5 | 99.99
                            Item6 | 199.50
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with multiple steps having different data table types")
            public void scenario_1(String name, Double price) {
                /*
                 * Given the following items:
                 *   | name  | price |
                 *   | Item1 | 19.99 |
                 *   | Item2 | 29.50 |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        "Item1",
                                        "19.99"
                                ),
                                new ItemsParam(
                                        "Item2",
                                        "29.50"
                                )
                        ));
                /*
                 * And the following items:
                 *   | name  | price   |
                 *   | Item3 | unknown |
                 *   | Item4 | 49.99   |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        "Item3",
                                        "unknown"
                                ),
                                new ItemsParam(
                                        "Item4",
                                        "49.99"
                                )
                        ));
                /*
                 * And the following items:
                 *   | name   | price   |
                 *   | <name> | <price> |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        price
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String price;

                public ItemsParam(String name, String price) {
                    this.name = name;
                    this.price = price;
                }

                public String name() {
                    return this.name;
                }

                public String price() {
                    return this.price;
                }
            }
        }
        """
      And the compilation error should contain the following text:
        """
        error: incompatible types: java.lang.Double cannot be converted to java.lang.String
        """

    Scenario: with cell containing mixed literal text and double placeholder reference
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class MixedLiteralDoublePlaceholderFeature {
      }
      """
      And the following feature file:
        """
        Feature: Mixed Literal and Double Placeholder Cell Test
          Scenario Outline: Test with cell mixing literal text and double placeholder
            Given the following items:
              | name   | priceTag      |
              | <name> | USD <price>   |
              | Backup | 0.00          |
            Examples:
              | name   | price  |
              | Widget | 19.99  |
              | Gadget | 299.50 |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Mixed Literal and Double Placeholder Cell Test
         */
        @DisplayName("MixedLiteralDoublePlaceholderFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MixedLiteralDoublePlaceholderFeature.feature")
        public class MixedLiteralDoublePlaceholderFeatureTest extends MixedLiteralDoublePlaceholderFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name   | price
                            Widget | 19.99
                            Gadget | 299.50
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with cell mixing literal text and double placeholder")
            public void scenario_1(String name, Double price) {
                /*
                 * Given the following items:
                 *   | name   | priceTag    |
                 *   | <name> | USD <price> |
                 *   | Backup | 0.00        |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        "USD <price>".replaceAll("<price>", price.toString())
                                ),
                                new ItemsParam(
                                        "Backup",
                                        "0.00"
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String priceTag;

                public ItemsParam(String name, String priceTag) {
                    this.name = name;
                    this.priceTag = priceTag;
                }

                public String name() {
                    return this.name;
                }

                public String priceTag() {
                    return this.priceTag;
                }
            }
        }
        """

  Rule: Type inference for boolean type combines Examples values and data table literal values

    Scenario: with only references to Examples values that are all booleans
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class BooleanPlaceholderOnlyFeature {
      }
      """
      And the following feature file:
        """
        Feature: Boolean Placeholder Only Test
          Scenario Outline: Test with boolean placeholder-only column
            Given the following items:
              | name   | enabled   |
              | <name> | <enabled> |
            Examples:
              | name    | enabled |
              | Feature | true    |
              | Debug   | false   |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Boolean Placeholder Only Test
         */
        @DisplayName("BooleanPlaceholderOnlyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/BooleanPlaceholderOnlyFeature.feature")
        public class BooleanPlaceholderOnlyFeatureTest extends BooleanPlaceholderOnlyFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name    | enabled
                            Feature | true
                            Debug   | false
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with boolean placeholder-only column")
            public void scenario_1(String name, Boolean enabled) {
                /*
                 * Given the following items:
                 *   | name   | enabled   |
                 *   | <name> | <enabled> |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        enabled
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final Boolean enabled;

                public ItemsParam(String name, Boolean enabled) {
                    this.name = name;
                    this.enabled = enabled;
                }

                public String name() {
                    return this.name;
                }

                public Boolean enabled() {
                    return this.enabled;
                }
            }
        }
        """

    Scenario: with only references to Examples values that are mixed type
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class BooleanMixedExamplesFeature {
      }
      """
      And the following feature file:
        """
        Feature: Boolean Mixed Examples Test
          Scenario Outline: Test with mixed type examples
            Given the following items:
              | name   | enabled   |
              | <name> | <enabled> |
            Examples:
              | name    | enabled |
              | Feature | true    |
              | Debug   | maybe   |
              | Beta    | false   |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Boolean Mixed Examples Test
         */
        @DisplayName("BooleanMixedExamplesFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/BooleanMixedExamplesFeature.feature")
        public class BooleanMixedExamplesFeatureTest extends BooleanMixedExamplesFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name    | enabled
                            Feature | true
                            Debug   | maybe
                            Beta    | false
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with mixed type examples")
            public void scenario_1(String name, String enabled) {
                /*
                 * Given the following items:
                 *   | name   | enabled   |
                 *   | <name> | <enabled> |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        enabled
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String enabled;

                public ItemsParam(String name, String enabled) {
                    this.name = name;
                    this.enabled = enabled;
                }

                public String name() {
                    return this.name;
                }

                public String enabled() {
                    return this.enabled;
                }
            }
        }
        """

    Scenario: with references to Examples values that are mixed type and literal values that are all booleans
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class BooleanMixedExamplesLiteralBooleansFeature {
      }
      """
      And the following feature file:
        """
        Feature: Boolean Mixed Examples with Literal Booleans Test
          Scenario Outline: Test with mixed examples and literal booleans
            Given the following items:
              | name   | enabled   |
              | <name> | <enabled> |
              | Extra1 | true      |
              | Extra2 | false     |
            Examples:
              | name    | enabled |
              | Feature | true    |
              | Debug   | maybe   |
              | Beta    | false   |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Boolean Mixed Examples with Literal Booleans Test
         */
        @DisplayName("BooleanMixedExamplesLiteralBooleansFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/BooleanMixedExamplesLiteralBooleansFeature.feature")
        public class BooleanMixedExamplesLiteralBooleansFeatureTest extends BooleanMixedExamplesLiteralBooleansFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name    | enabled
                            Feature | true
                            Debug   | maybe
                            Beta    | false
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with mixed examples and literal booleans")
            public void scenario_1(String name, String enabled) {
                /*
                 * Given the following items:
                 *   | name   | enabled   |
                 *   | <name> | <enabled> |
                 *   | Extra1 | true      |
                 *   | Extra2 | false     |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        enabled
                                ),
                                new ItemsParam(
                                        "Extra1",
                                        "true"
                                ),
                                new ItemsParam(
                                        "Extra2",
                                        "false"
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String enabled;

                public ItemsParam(String name, String enabled) {
                    this.name = name;
                    this.enabled = enabled;
                }

                public String name() {
                    return this.name;
                }

                public String enabled() {
                    return this.enabled;
                }
            }
        }
        """

    Scenario: with references to Examples values that are all booleans and literal values that are also text
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class BooleanLiteralTextFeature {
      }
      """
      And the following feature file:
        """
        Feature: Boolean Literal Text Row Test
          Scenario Outline: Test with literal text in data table
            Given the following items:
              | name   | enabled   |
              | <name> | <enabled> |
              | Extra1 | maybe     |
              | Extra2 | true      |
            Examples:
              | name    | enabled |
              | Feature | true    |
              | Debug   | false   |
        """
      When the generator is run
      Then the following java source file should be be generated:
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Boolean Literal Text Row Test
         */
        @DisplayName("BooleanLiteralTextFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/BooleanLiteralTextFeature.feature")
        public class BooleanLiteralTextFeatureTest extends BooleanLiteralTextFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name    | enabled
                            Feature | true
                            Debug   | false
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with literal text in data table")
            public void scenario_1(String name, Boolean enabled) {
                /*
                 * Given the following items:
                 *   | name   | enabled   |
                 *   | <name> | <enabled> |
                 *   | Extra1 | maybe     |
                 *   | Extra2 | true      |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        enabled
                                ),
                                new ItemsParam(
                                        "Extra1",
                                        "maybe"
                                ),
                                new ItemsParam(
                                        "Extra2",
                                        "true"
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String enabled;

                public ItemsParam(String name, String enabled) {
                    this.name = name;
                    this.enabled = enabled;
                }

                public String name() {
                    return this.name;
                }

                public String enabled() {
                    return this.enabled;
                }
            }
        }
        """
      And the compilation error should contain the following text:
        """
        error: incompatible types: java.lang.Boolean cannot be converted to java.lang.String
        """

    Scenario: with multiple step invocations
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class BooleanMultipleStepsFeature {
      }
      """
      And the following feature file:
        """
        Feature: Boolean Multiple Steps Test
          Scenario Outline: Test with multiple steps having different data table types
            Given the following items:
              | name  | enabled |
              | Flag1 | true    |
              | Flag2 | false   |
            And the following items:
              | name  | enabled |
              | Flag3 | maybe   |
              | Flag4 | true    |
            And the following items:
              | name   | enabled   |
              | <name> | <enabled> |
            Examples:
              | name  | enabled |
              | Flag5 | true    |
              | Flag6 | false   |
        """
      When the generator is run
      Then the following java source file should be be generated:
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Boolean Multiple Steps Test
         */
        @DisplayName("BooleanMultipleStepsFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/BooleanMultipleStepsFeature.feature")
        public class BooleanMultipleStepsFeatureTest extends BooleanMultipleStepsFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name  | enabled
                            Flag5 | true
                            Flag6 | false
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with multiple steps having different data table types")
            public void scenario_1(String name, Boolean enabled) {
                /*
                 * Given the following items:
                 *   | name  | enabled |
                 *   | Flag1 | true    |
                 *   | Flag2 | false   |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        "Flag1",
                                        "true"
                                ),
                                new ItemsParam(
                                        "Flag2",
                                        "false"
                                )
                        ));
                /*
                 * And the following items:
                 *   | name  | enabled |
                 *   | Flag3 | maybe   |
                 *   | Flag4 | true    |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        "Flag3",
                                        "maybe"
                                ),
                                new ItemsParam(
                                        "Flag4",
                                        "true"
                                )
                        ));
                /*
                 * And the following items:
                 *   | name   | enabled   |
                 *   | <name> | <enabled> |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        enabled
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String enabled;

                public ItemsParam(String name, String enabled) {
                    this.name = name;
                    this.enabled = enabled;
                }

                public String name() {
                    return this.name;
                }

                public String enabled() {
                    return this.enabled;
                }
            }
        }
        """
      And the compilation error should contain the following text:
        """
        error: incompatible types: java.lang.Boolean cannot be converted to java.lang.String
        """

    Scenario: with cell containing mixed literal text and boolean placeholder reference
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class MixedLiteralBooleanPlaceholderFeature {
      }
      """
      And the following feature file:
        """
        Feature: Mixed Literal and Boolean Placeholder Cell Test
          Scenario Outline: Test with cell mixing literal text and boolean placeholder
            Given the following items:
              | name   | status             |
              | <name> | Active: <enabled>  |
              | Backup | false              |
            Examples:
              | name    | enabled |
              | Feature | true    |
              | Debug   | false   |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Mixed Literal and Boolean Placeholder Cell Test
         */
        @DisplayName("MixedLiteralBooleanPlaceholderFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MixedLiteralBooleanPlaceholderFeature.feature")
        public class MixedLiteralBooleanPlaceholderFeatureTest extends MixedLiteralBooleanPlaceholderFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name    | enabled
                            Feature | true
                            Debug   | false
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with cell mixing literal text and boolean placeholder")
            public void scenario_1(String name, Boolean enabled) {
                /*
                 * Given the following items:
                 *   | name   | status            |
                 *   | <name> | Active: <enabled> |
                 *   | Backup | false             |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        "Active: <enabled>".replaceAll("<enabled>", enabled.toString())
                                ),
                                new ItemsParam(
                                        "Backup",
                                        "false"
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String status;

                public ItemsParam(String name, String status) {
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

  Rule: Type inference for character type combines Examples values and data table literal values

    Scenario: with only references to Examples values that are all characters
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class CharacterPlaceholderOnlyFeature {
      }
      """
      And the following feature file:
        """
        Feature: Character Placeholder Only Test
          Scenario Outline: Test with character placeholder-only column
            Given the following items:
              | name   | grade   |
              | <name> | <grade> |
            Examples:
              | name  | grade |
              | Alice | A     |
              | Bob   | B     |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Character Placeholder Only Test
         */
        @DisplayName("CharacterPlaceholderOnlyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/CharacterPlaceholderOnlyFeature.feature")
        public class CharacterPlaceholderOnlyFeatureTest extends CharacterPlaceholderOnlyFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name  | grade
                            Alice | A
                            Bob   | B
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with character placeholder-only column")
            public void scenario_1(String name, Character grade) {
                /*
                 * Given the following items:
                 *   | name   | grade   |
                 *   | <name> | <grade> |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        grade
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final Character grade;

                public ItemsParam(String name, Character grade) {
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

    Scenario: with only references to Examples values that are mixed type
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class CharacterMixedExamplesFeature {
      }
      """
      And the following feature file:
        """
        Feature: Character Mixed Examples Test
          Scenario Outline: Test with mixed type examples
            Given the following items:
              | name   | grade   |
              | <name> | <grade> |
            Examples:
              | name    | grade |
              | Alice   | A     |
              | Bob     | NA    |
              | Charlie | B     |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Character Mixed Examples Test
         */
        @DisplayName("CharacterMixedExamplesFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/CharacterMixedExamplesFeature.feature")
        public class CharacterMixedExamplesFeatureTest extends CharacterMixedExamplesFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name    | grade
                            Alice   | A
                            Bob     | NA
                            Charlie | B
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with mixed type examples")
            public void scenario_1(String name, String grade) {
                /*
                 * Given the following items:
                 *   | name   | grade   |
                 *   | <name> | <grade> |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        grade
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String grade;

                public ItemsParam(String name, String grade) {
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

    Scenario: with references to Examples values that are mixed type and literal values that are all characters
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class CharacterMixedExamplesLiteralCharsFeature {
      }
      """
      And the following feature file:
        """
        Feature: Character Mixed Examples with Literal Chars Test
          Scenario Outline: Test with mixed examples and literal characters
            Given the following items:
              | name   | grade   |
              | <name> | <grade> |
              | Extra1 | C       |
              | Extra2 | D       |
            Examples:
              | name    | grade |
              | Alice   | A     |
              | Bob     | NA    |
              | Charlie | B     |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Character Mixed Examples with Literal Chars Test
         */
        @DisplayName("CharacterMixedExamplesLiteralCharsFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/CharacterMixedExamplesLiteralCharsFeature.feature")
        public class CharacterMixedExamplesLiteralCharsFeatureTest extends CharacterMixedExamplesLiteralCharsFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name    | grade
                            Alice   | A
                            Bob     | NA
                            Charlie | B
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with mixed examples and literal characters")
            public void scenario_1(String name, String grade) {
                /*
                 * Given the following items:
                 *   | name   | grade   |
                 *   | <name> | <grade> |
                 *   | Extra1 | C       |
                 *   | Extra2 | D       |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        grade
                                ),
                                new ItemsParam(
                                        "Extra1",
                                        "C"
                                ),
                                new ItemsParam(
                                        "Extra2",
                                        "D"
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String grade;

                public ItemsParam(String name, String grade) {
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

    Scenario: with references to Examples values that are all characters and literal values that are also text
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class CharacterLiteralTextFeature {
      }
      """
      And the following feature file:
        """
        Feature: Character Literal Text Row Test
          Scenario Outline: Test with literal text in data table
            Given the following items:
              | name   | grade   |
              | <name> | <grade> |
              | Extra1 | NA      |
              | Extra2 | C       |
            Examples:
              | name  | grade |
              | Alice | A     |
              | Bob   | B     |
        """
      When the generator is run
      Then the following java source file should be be generated:
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Character Literal Text Row Test
         */
        @DisplayName("CharacterLiteralTextFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/CharacterLiteralTextFeature.feature")
        public class CharacterLiteralTextFeatureTest extends CharacterLiteralTextFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name  | grade
                            Alice | A
                            Bob   | B
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with literal text in data table")
            public void scenario_1(String name, Character grade) {
                /*
                 * Given the following items:
                 *   | name   | grade   |
                 *   | <name> | <grade> |
                 *   | Extra1 | NA      |
                 *   | Extra2 | C       |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        grade
                                ),
                                new ItemsParam(
                                        "Extra1",
                                        "NA"
                                ),
                                new ItemsParam(
                                        "Extra2",
                                        "C"
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String grade;

                public ItemsParam(String name, String grade) {
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
      And the compilation error should contain the following text:
        """
        error: incompatible types: java.lang.Character cannot be converted to java.lang.String
        """

    Scenario: with multiple step invocations
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class CharacterMultipleStepsFeature {
      }
      """
      And the following feature file:
        """
        Feature: Character Multiple Steps Test
          Scenario Outline: Test with multiple steps having different data table types
            Given the following items:
              | name   | grade |
              | Alice  | A     |
              | Bob    | B     |
            And the following items:
              | name    | grade |
              | Charlie | NA    |
              | Dave    | C     |
            And the following items:
              | name   | grade   |
              | <name> | <grade> |
            Examples:
              | name  | grade |
              | Eve   | E     |
              | Frank | F     |
        """
      When the generator is run
      Then the following java source file should be be generated:
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Character Multiple Steps Test
         */
        @DisplayName("CharacterMultipleStepsFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/CharacterMultipleStepsFeature.feature")
        public class CharacterMultipleStepsFeatureTest extends CharacterMultipleStepsFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name  | grade
                            Eve   | E
                            Frank | F
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with multiple steps having different data table types")
            public void scenario_1(String name, Character grade) {
                /*
                 * Given the following items:
                 *   | name  | grade |
                 *   | Alice | A     |
                 *   | Bob   | B     |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        "Alice",
                                        "A"
                                ),
                                new ItemsParam(
                                        "Bob",
                                        "B"
                                )
                        ));
                /*
                 * And the following items:
                 *   | name    | grade |
                 *   | Charlie | NA    |
                 *   | Dave    | C     |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        "Charlie",
                                        "NA"
                                ),
                                new ItemsParam(
                                        "Dave",
                                        "C"
                                )
                        ));
                /*
                 * And the following items:
                 *   | name   | grade   |
                 *   | <name> | <grade> |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        grade
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String grade;

                public ItemsParam(String name, String grade) {
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
      And the compilation error should contain the following text:
        """
        error: incompatible types: java.lang.Character cannot be converted to java.lang.String
        """

    Scenario: with cell containing mixed literal text and character placeholder reference
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;
      import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_OBJECT_PARAMS;

      @Feature2JUnit
      @Feature2JUnitOptions(dataTableParameterType = LIST_OF_OBJECT_PARAMS)
      public abstract class MixedLiteralCharacterPlaceholderFeature {
      }
      """
      And the following feature file:
        """
        Feature: Mixed Literal and Character Placeholder Cell Test
          Scenario Outline: Test with cell mixing literal text and character placeholder
            Given the following items:
              | name   | gradeInfo       |
              | <name> | Grade: <grade>  |
              | Backup | X               |
            Examples:
              | name  | grade |
              | Alice | A     |
              | Bob   | B     |
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
        import org.junit.jupiter.api.TestMethodOrder;
        import org.junit.jupiter.params.ParameterizedTest;
        import org.junit.jupiter.params.provider.CsvSource;

        /**
         * Feature: Mixed Literal and Character Placeholder Cell Test
         */
        @DisplayName("MixedLiteralCharacterPlaceholderFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MixedLiteralCharacterPlaceholderFeature.feature")
        public class MixedLiteralCharacterPlaceholderFeatureTest extends MixedLiteralCharacterPlaceholderFeature {
            public void theFollowingItems(List<ItemsParam> items) {
                Assertions.fail("Step is not yet implemented");
            }

            @ParameterizedTest(
                    name = "Example {index}: [{arguments}]"
            )
            @CsvSource(
                    useHeadersInDisplayName = true,
                    delimiter = '|',
                    textBlock = \"\"\"
                            name  | grade
                            Alice | A
                            Bob   | B
                            \"\"\"
            )
            @Order(1)
            @DisplayName("Scenario Outline: Test with cell mixing literal text and character placeholder")
            public void scenario_1(String name, Character grade) {
                /*
                 * Given the following items:
                 *   | name   | gradeInfo      |
                 *   | <name> | Grade: <grade> |
                 *   | Backup | X              |
                 */
                theFollowingItems(
                        List.of(
                                new ItemsParam(
                                        name,
                                        "Grade: <grade>".replaceAll("<grade>", grade.toString())
                                ),
                                new ItemsParam(
                                        "Backup",
                                        "X"
                                )
                        ));
            }

            public static class ItemsParam {
                private final String name;

                private final String gradeInfo;

                public ItemsParam(String name, String gradeInfo) {
                    this.name = name;
                    this.gradeInfo = gradeInfo;
                }

                public String name() {
                    return this.name;
                }

                public String gradeInfo() {
                    return this.gradeInfo;
                }
            }
        }
        """

