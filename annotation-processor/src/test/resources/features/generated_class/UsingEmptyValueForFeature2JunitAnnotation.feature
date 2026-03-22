Feature: UsingEmptyValueForFeature2JunitAnnotation
  As a developer organizing feature files to mirror my package structure
  I want to use @Feature2JUnit with an empty value to trigger convention-based feature discovery
  So that the processor automatically finds features using the class's package path as the path location,
  eliminating hardcoded file paths and making the codebase easier to refactor and maintain

  Rule: When @Feature2JUnit annotation value is empty, the assumed feature file path for finding matching feature files
  is derived from the package of the annotated class

    Scenario: Pattern matching single feature file in same directory
      Given the following base class:
      """
      package com.example.features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      public abstract class UserFeatures {
      }
      """
      And the following feature file:
      """
      Feature: User Login
        Scenario: Successful login
          Given user exists
      """
      When the generator is run
      # the path used for finding feature files should be in this case "com/example/features/*.feature"
      Then the following class should be generated:
      """
      package com.example.features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: User Login
       */
      @DisplayName("UserFeatures")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("com/example/features/UserFeatures.feature")
      public class UserFeaturesTest extends UserFeatures {
          public void userExists() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Successful login")
          public void scenario_1() {
              /*
               * Given user exists
               */
              userExists();
          }
      }
      """

    Scenario: Pattern matching multiple feature files in same directory
      Given the following base class:
      """
      package com.example.features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      public abstract class UserFeatures {
      }
      """
      And a feature file under path "com/example/features/UserLogin.feature" with the following content:
      """
      Feature: User Login
        Scenario: Login test
          Given user exists
      """
      And a feature file under path "com/example/features/UserRegistration.feature" with the following content:
      """
      Feature: User Registration
        Scenario: Registration test
          Given user registers
      """
      When the generator is run
      # the path used for finding feature files should be in this case "com/example/features/*.feature"
      Then the following class should be generated:
      """
      package com.example.features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: User Login
       */
      @DisplayName("UserLogin")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("com/example/features/UserLogin.feature")
      public class UserLoginTest extends UserFeatures {
          public void userExists() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Login test")
          public void scenario_1() {
              /*
               * Given user exists
               */
              userExists();
          }
      }
      """
      And the following class should be generated:
      """
      package com.example.features;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: User Registration
       */
      @DisplayName("UserRegistration")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("com/example/features/UserRegistration.feature")
      public class UserRegistrationTest extends UserFeatures {
          public void userRegisters() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Registration test")
          public void scenario_1() {
              /*
               * Given user registers
               */
              userRegisters();
          }
      }
      """

    Scenario: should avoid generating test class for the unmatched feature files outside the package path
      Given the following base class:
      """
      package com.example.user;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      public abstract class UserFeatures {
      }
      """
      And a feature file under path "com/example/user/Login.feature" with the following content:
      """
      Feature: User Login
        Scenario: Login
          Given user logs in
      """
      And a feature file under path "com/example/user/auth/TwoFactor.feature" with the following content:
      """
      Feature: Two Factor Authentication
        Scenario: Enable 2FA
          Given user enables two factor authentication
      """
      And a feature file under path "features/admin/Dashboard.feature" with the following content:
      """
      Feature: Admin Dashboard
        Scenario: View dashboard
          Given admin views dashboard
      """
      When the generator is run
      Then there should not be a class generated with name "TwoFactorTest" in package "com.example.user.auth"
      And there should not be a class generated with name "DashboardTest" in package "features.admin"
      And the following class should be generated:
      """
      package com.example.user;

      import dev.specbinder.annotations.output.SourceFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: User Login
       */
      @DisplayName("Login")
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("com/example/user/Login.feature")
      public class LoginTest extends UserFeatures {
          public void userLogsIn() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Login")
          public void scenario_1() {
              /*
               * Given user logs in
               */
              userLogsIn();
          }
      }
      """
