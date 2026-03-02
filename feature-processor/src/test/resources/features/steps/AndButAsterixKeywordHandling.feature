Feature: AndButAsterixKeywordHandling
  As a developer writing feature files with multiple step keywords
  I want the generator to correctly inherit step keywords for And, But, and *
  So that the generated method names accurately reflect the intended behavior

  Rule: And, But, and * keywords inherit the previous step's keyword
  - the method name generation uses the inherited keyword as the first word
  If there is no previous step, processing throws an exception

    Scenario: And keyword inherits from Given
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
        Feature: And Inheritance
          Scenario: Test
            Given user exists
            And user is authenticated
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: And Inheritance
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void userExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userIsAuthenticated() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                userExists();
                /*
                 * And user is authenticated
                 */
                userIsAuthenticated();
            }
        }
        """

    Scenario: And keyword inherits from When
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
        Feature: And Inheritance When
          Scenario: Test
            When user logs in
            And user clicks button
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: And Inheritance When
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void userLogsIn() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userClicksButton() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * When user logs in
                 */
                userLogsIn();
                /*
                 * And user clicks button
                 */
                userClicksButton();
            }
        }
        """

    Scenario: But keyword inherits from Then
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
        Feature: But Inheritance
          Scenario: Test
            Then password is visible
            But username is not visible
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: But Inheritance
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void passwordIsVisible() {
                Assertions.fail("Step is not yet implemented");
            }

            public void usernameIsNotVisible() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Then password is visible
                 */
                passwordIsVisible();
                /*
                 * But username is not visible
                 */
                usernameIsNotVisible();
            }
        }
        """

    Scenario: Asterisk keyword inherits from previous step
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
        Feature: Asterisk Inheritance
          Scenario: Test
            Given system is ready
            * database is connected
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Asterisk Inheritance
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void systemIsReady() {
                Assertions.fail("Step is not yet implemented");
            }

            public void databaseIsConnected() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given system is ready
                 */
                systemIsReady();
                /*
                 * * database is connected
                 */
                databaseIsConnected();
            }
        }
        """

    Scenario: Multiple And keywords chain inheritance
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
        Feature: Multiple And Chain
          Scenario: Test
            Given user exists
            And user is active
            And user has permissions
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Multiple And Chain
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void userExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userIsActive() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userHasPermissions() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                userExists();
                /*
                 * And user is active
                 */
                userIsActive();
                /*
                 * And user has permissions
                 */
                userHasPermissions();
            }
        }
        """

    Scenario: If And, But and * are all used after a step with Given/When/Then keyword they all chain inheritance
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
        Feature: Mixed Keywords Chain
          Scenario: Test
            Given user exists
            And user is active
            But user is not locked
            * user has permissions
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Mixed Keywords Chain
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void userExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userIsActive() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userIsNotLocked() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userHasPermissions() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                userExists();
                /*
                 * And user is active
                 */
                userIsActive();
                /*
                 * But user is not locked
                 */
                userIsNotLocked();
                /*
                 * * user has permissions
                 */
                userHasPermissions();
            }
        }
        """

    Scenario: If And, But steps are used after * step which is used after Given/When/Then keyword step
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
        Feature: And But After Asterisk Chain
          Scenario: Test
            Given user exists
            * user is active
            And user has permissions
            But user is not locked
        """
      When the generator is run
      Then the following class should be generated:
        """
        package features;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: And But After Asterisk Chain
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void userExists() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userIsActive() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userHasPermissions() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userIsNotLocked() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given user exists
                 */
                userExists();
                /*
                 * * user is active
                 */
                userIsActive();
                /*
                 * And user has permissions
                 */
                userHasPermissions();
                /*
                 * But user is not locked
                 */
                userIsNotLocked();
            }
        }
        """

  Rule: And, But, and * keywords require a previous step with a GWT annotation
  - If And/But/* is the first step in a scenario, an error is reported
  - Error messages include the line number where the issue occurred

    Scenario: And keyword without any previous step should fail
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
        Feature: And Without Previous Step
          Scenario: Test
            And user is authenticated
        """
      When the generator is run
      Then the generator should report an error:
        """
        Step on line - 3 starts with 'And', but there are no previous scenario steps defined
        """

    Scenario: But keyword without any previous step should fail
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
        Feature: But Without Previous Step
          Scenario: Test
            But user is not admin
        """
      When the generator is run
      Then the generator should report an error:
        """
        Step on line - 3 starts with 'And', but there are no previous scenario steps defined
        """

    Scenario: Asterisk keyword without any previous step should fail
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
        Feature: Asterisk Without Previous Step
          Scenario: Test
            * system is ready
        """
      When the generator is run
      Then the generator should report an error:
        """
        Step on line - 3 starts with 'And', but there are no previous scenario steps defined
        """
