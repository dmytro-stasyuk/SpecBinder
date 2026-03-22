Feature: MappingStepParameters
  As a developer
  I want to specify parameters in Gherkin steps using double quotes
  So that they are extracted as method parameters for easy access in step implementations

  Rule: Parameters in double quotes are extracted from step text and then are replaced with placeholders: $p1, $p2, etc.
  - method signatures receive parameters named: p1, p2, p3, etc., all of type String

    Scenario: Step with one quoted parameter
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
        """
        Feature: One Parameter
          Scenario: Test
            Given user "John" exists
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: One Parameter
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void user$p1Exists(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user "John" exists
                 */
                user$p1Exists("John");
            }
        }
        """

    Scenario: Step with two quoted parameters
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
        """
        Feature: Two Parameters
          Scenario: Test
            When user "Alice" sends message "Hello"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Two Parameters
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void user$p1SendsMessage$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * When user "Alice" sends message "Hello"
                 */
                user$p1SendsMessage$p2("Alice", "Hello");
            }
        }
        """

    Scenario: Step with three quoted parameters
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
        """
        Feature: Three Parameters
          Scenario: Test
            Then order "12345" for customer "Bob" has status "shipped"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Integer;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Three Parameters
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void order$p1ForCustomer$p2HasStatus$p3(Integer p1, String p2, String p3) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Then order "12345" for customer "Bob" has status "shipped"
                 */
                order$p1ForCustomer$p2HasStatus$p3(12345, "Bob", "shipped");
            }
        }
        """

    Scenario: Step with parameter containing spaces
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
        """
        Feature: Parameter With Spaces
          Scenario: Test
            When I search for "hello world"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Parameter With Spaces
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void iSearchFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * When I search for "hello world"
                 */
                iSearchFor$p1("hello world");
            }
        }
        """

    Scenario: Step with parameter containing special characters
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
        """
        Feature: Special Characters Parameter
          Scenario: Test
            Given password is "P@ssw0rd!"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Special Characters Parameter
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void passwordIs$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given password is "P@ssw0rd!"
                 */
                passwordIs$p1("P@ssw0rd!");
            }
        }
        """

    Scenario: Step with parameter at the beginning
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
        """
        Feature: Parameter At Beginning
          Scenario: Test
            Given "Admin" role is assigned
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Parameter At Beginning
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void $p1RoleIsAssigned(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given "Admin" role is assigned
                 */
                $p1RoleIsAssigned("Admin");
            }
        }
        """

    Scenario: Step with consecutive quoted parameters
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
        """
        Feature: Consecutive Parameters
          Scenario: Test
            Given transfer from "ACC001" to "ACC002" completes
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Consecutive Parameters
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void transferFrom$p1To$p2Completes(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given transfer from "ACC001" to "ACC002" completes
                 */
                transferFrom$p1To$p2Completes("ACC001", "ACC002");
            }
        }
        """

  Rule: if a quoted parameter is empty (""), then there is no parameter passed to the step method

    Scenario: Step with empty quoted parameter
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
        """
        Feature: Empty Parameter
          Scenario: Test
            When field is set to ""
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Empty Parameter
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void fieldIsSetTo() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * When field is set to ""
                 */
                fieldIsSetTo();
            }
        }
        """

  Rule: quoted parameters with only whitespace characters are extracted as-is and passed as String parameters

    Scenario: Step with blank quoted parameter
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
      """
      Feature: Blank Parameter
      Scenario: Test
          Given name is "   "
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Blank Parameter
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
          public void nameIs$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Test")
          public void scenario_1() {
              /*
               * Given name is "   "
               */
              nameIs$p1("   ");
          }
      }
      """

  Rule: All extracted parameters are of type String regardless of the content of quoted parameters (numbers, dates, etc.)
  - type conversion is the responsibility of the step implementation

    Scenario: Numeric parameter is typed as String
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
        """
        Feature: Numeric Parameter
          Scenario: Test
            When quantity is set to "42"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Integer;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Numeric Parameter
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void quantityIsSetTo$p1(Integer p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * When quantity is set to "42"
                 */
                quantityIsSetTo$p1(42);
            }
        }
        """

    Scenario: Boolean-like parameter is typed as String
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
        """
        Feature: Boolean Parameter
          Scenario: Test
            Given feature flag is "true"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.Boolean;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Boolean Parameter
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void featureFlagIs$p1(Boolean p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given feature flag is "true"
                 */
                featureFlagIs$p1(true);
            }
        }
        """

    Scenario: Date-like parameter is typed as String
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
      }
      """
      Given the following feature file:
        """
        Feature: Date Parameter
          Scenario: Test
            When date is set to "2024-12-20"
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.SourceFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Date Parameter
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void dateIsSetTo$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * When date is set to "2024-12-20"
                 */
                dateIsSetTo$p1("2024-12-20");
            }
        }
        """