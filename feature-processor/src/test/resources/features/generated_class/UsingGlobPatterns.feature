Feature: UsingGlobPatterns
  As a developer organizing feature files in a hierarchical directory structure
  I want to use glob patterns in the @Feature2JUnit annotation to match multiple feature files
  So that I can generate test classes for all matching feature files without annotating a separate class for each one

  Rule: When annotation value contains glob pattern characters (*, **), all matching feature files generate separate test classes
  - generated class name in this case is derived from the feature file name

    Scenario: Pattern matching single feature file in same directory
      Given the following base class:
      """
      package com.example.features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit("**/*.feature")
      public abstract class UserFeatures {
      }
      """
      And a feature file under path "features/UserLogin.feature" with the following content:
      """
      Feature: User Login
        Scenario: Successful login
          Given user exists
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import com.example.features.UserFeatures;
      import dev.specbinder.annotations.output.FeatureFilePath;
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
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UserLogin.feature")
      public class UserLoginTest extends UserFeatures {
          public void givenUserExists() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Successful login")
          public void scenario_1() {
              /*
               * Given user exists
               */
              givenUserExists();
          }
      }
      """

    Scenario: Pattern matching multiple feature files in same directory
      Given the following base class:
      """
      package com.example.features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit("features/**/*.feature")
      public abstract class UserFeatures {
      }
      """
      And a feature file under path "features/UserLogin.feature" with the following content:
      """
      Feature: User Login
        Scenario: Login test
          Given user exists
      """
      And a feature file under path "features/UserRegistration.feature" with the following content:
      """
      Feature: User Registration
        Scenario: Registration test
          Given user registers
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import com.example.features.UserFeatures;
      import dev.specbinder.annotations.output.FeatureFilePath;
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
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UserLogin.feature")
      public class UserLoginTest extends UserFeatures {
          public void givenUserExists() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Login test")
          public void scenario_1() {
              /*
               * Given user exists
               */
              givenUserExists();
          }
      }
      """
      And the following class should be generated:
      """
      package features;

      import com.example.features.UserFeatures;
      import dev.specbinder.annotations.output.FeatureFilePath;
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
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/UserRegistration.feature")
      public class UserRegistrationTest extends UserFeatures {
          public void givenUserRegisters() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Registration test")
          public void scenario_1() {
              /*
               * Given user registers
               */
              givenUserRegisters();
          }
      }
      """

    Scenario: Pattern matching files in subdirectories using double asterisk
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit("features/**/*.feature")
      public abstract class AllFeatures {
      }
      """
      And a feature file under path "features/user/Login.feature" with the following content:
      """
      Feature: User Login
        Scenario: Login
          Given user logs in
      """
      And a feature file under path "features/user/Registration.feature" with the following content:
      """
      Feature: User Registration
        Scenario: Register
          Given user registers
      """
      And a feature file under path "features/admin/Dashboard.feature" with the following content:
      """
      Feature: Admin Dashboard
        Scenario: View dashboard
          Given admin views dashboard
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features.user;

      import com.example.AllFeatures;
      import dev.specbinder.annotations.output.FeatureFilePath;
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
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/user/Login.feature")
      public class LoginTest extends AllFeatures {
          public void givenUserLogsIn() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Login")
          public void scenario_1() {
              /*
               * Given user logs in
               */
              givenUserLogsIn();
          }
      }
      """
      And the following class should be generated:
      """
      package features.user;

      import com.example.AllFeatures;
      import dev.specbinder.annotations.output.FeatureFilePath;
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
      @DisplayName("Registration")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/user/Registration.feature")
      public class RegistrationTest extends AllFeatures {
          public void givenUserRegisters() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Register")
          public void scenario_1() {
              /*
               * Given user registers
               */
              givenUserRegisters();
          }
      }
      """
      And the following class should be generated:
      """
      package features.admin;

      import com.example.AllFeatures;
      import dev.specbinder.annotations.output.FeatureFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Admin Dashboard
       */
      @DisplayName("Dashboard")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/admin/Dashboard.feature")
      public class DashboardTest extends AllFeatures {
          public void givenAdminViewsDashboard() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: View dashboard")
          public void scenario_1() {
              /*
               * Given admin views dashboard
               */
              givenAdminViewsDashboard();
          }
      }
      """

    Scenario: Pattern with specific subdirectory prefix
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit("features/user/**/*.feature")
      public abstract class UserFeatures {
      }
      """
      And a feature file under path "features/user/Login.feature" with the following content:
      """
      Feature: User Login
        Scenario: Login
          Given user logs in
      """
      And a feature file under path "features/user/auth/TwoFactor.feature" with the following content:
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
      Then the following class should be generated:
      """
      package features.user;

      import com.example.UserFeatures;
      import dev.specbinder.annotations.output.FeatureFilePath;
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
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/user/Login.feature")
      public class LoginTest extends UserFeatures {
          public void givenUserLogsIn() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Login")
          public void scenario_1() {
              /*
               * Given user logs in
               */
              givenUserLogsIn();
          }
      }
      """
      And the following class should be generated:
      """
      package features.user.auth;

      import com.example.UserFeatures;
      import dev.specbinder.annotations.output.FeatureFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Two Factor Authentication
       */
      @DisplayName("TwoFactor")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/user/auth/TwoFactor.feature")
      public class TwoFactorTest extends UserFeatures {
          public void givenUserEnablesTwoFactorAuthentication() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Enable 2FA")
          public void scenario_1() {
              /*
               * Given user enables two factor authentication
               */
              givenUserEnablesTwoFactorAuthentication();
          }
      }
      """

  Rule: Pattern matching respects generator options from the annotated class

    Scenario: Custom suffix applied to all generated classes from pattern
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit("features/**/*.feature")
      @Feature2JUnitOptions(classSuffixIfAbstract = "TestCases")
      public abstract class Features {
      }
      """
      And a feature file under path "features/Login.feature" with the following content:
      """
      Feature: Login
        Scenario: Test login
          Given user logs in
      """
      And a feature file under path "features/Logout.feature" with the following content:
      """
      Feature: Logout
        Scenario: Test logout
          Given user logs out
      """
      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import com.example.Features;
      import dev.specbinder.annotations.output.FeatureFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Login
       */
      @DisplayName("Login")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/Login.feature")
      public class LoginTest extends Features {
          public void givenUserLogsIn() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Test login")
          public void scenario_1() {
              /*
               * Given user logs in
               */
              givenUserLogsIn();
          }
      }
      """
      And the following class should be generated:
      """
      package features;

      import com.example.Features;
      import dev.specbinder.annotations.output.FeatureFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Logout
       */
      @DisplayName("Logout")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("features/Logout.feature")
      public class LogoutTest extends Features {
          public void givenUserLogsOut() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Test logout")
          public void scenario_1() {
              /*
               * Given user logs out
               */
              givenUserLogsOut();
          }
      }
      """

  Rule: Pattern matching behavior with edge cases

    Scenario: No files match the pattern
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit("nonexistent/**/*.feature")
      public abstract class Features {
      }
      """
      And a feature file under path "features/UserLogin.feature" with the following content:
      """
      Feature: User Login
        Scenario: Successful login
          Given user exists
      """
      When the generator is run
      Then the generator should report an error:
      """
      No feature files found matching pattern 'nonexistent/**/*.feature'
      """

  Rule: Pattern matching with file name conflicts should result in generator error
  - When a glob pattern matches multiple feature files with the same filename in different directories
  - the generator would attempt to create classes with identical names in the same package.

    Scenario: Multiple feature files with same name in different directories
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit("features/**/*.feature")
      public abstract class Features {
      }
      """
      And a feature file under path "features/user/Login.feature" with the following content:
      """
      Feature: User Login
        Scenario: User login test
      """
      And a feature file under path "features/admin/Login.feature" with the following content:
      """
      Feature: Admin Login
        Scenario: Admin login test
      """
      When the generator is run
      Then the generator should report an error:
      """
      Duplicate generated class name 'LoginScenarios' from feature file pattern 'features/**/*.feature'.
      """

