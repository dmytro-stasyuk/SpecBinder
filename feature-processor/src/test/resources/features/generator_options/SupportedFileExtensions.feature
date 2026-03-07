Feature: SupportedFileExtensions
  As a test developer using Gherkin
  I want to configure which file extensions the annotation processor recognizes as specification files
  So that I can use custom file extensions beyond the default .feature and .specb

  Rule: By default the processor discovers files with .feature and .specb extensions

    Scenario: convention-based discovery finds .feature files by default
      Given the following base class:
      """
      package com.example.features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class UserFeatures {
      }
      """
      And a feature file under path "com/example/features/Login.feature" with the following content:
      """
      Feature: User Login
        Scenario: Successful login
          Given user exists
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example.features;

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
      @FeatureFilePath("com/example/features/Login.feature")
      public class LoginTest extends UserFeatures {
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

    Scenario: convention-based discovery finds .specb files by default
      Given the following base class:
      """
      package com.example.features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class UserFeatures {
      }
      """
      And a feature file under path "com/example/features/Login.specb" with the following content:
      """
      Feature: User Login
        Scenario: Successful login
          Given user exists
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example.features;

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
      @FeatureFilePath("com/example/features/Login.specb")
      public class LoginTest extends UserFeatures {
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

    Scenario: convention-based discovery finds both .feature and .specb files in the same package
      Given the following base class:
      """
      package com.example.features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class UserFeatures {
      }
      """
      And a feature file under path "com/example/features/Login.feature" with the following content:
      """
      Feature: User Login
        Scenario: Login test
          Given user logs in
      """
      And a feature file under path "com/example/features/Registration.specb" with the following content:
      """
      Feature: User Registration
        Scenario: Registration test
          Given user registers
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example.features;

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
      @FeatureFilePath("com/example/features/Login.feature")
      public class LoginTest extends UserFeatures {
          public void userLogsIn() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Login test")
          public void scenario_1() {
              /*
               * Given user logs in
               */
              userLogsIn();
          }
      }
      """
      And the following class should be generated:
      """
      package com.example.features;

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
      @FeatureFilePath("com/example/features/Registration.specb")
      public class RegistrationTest extends UserFeatures {
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

  Rule: when supportedFileExtensions is set to a single extension, only files with that extension are discovered

    Scenario: only .specb files are discovered when supportedFileExtensions is set to "specb"
      Given the following base class:
      """
      package com.example.features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(supportedFileExtensions = {"specb"})
      public abstract class UserFeatures {
      }
      """
      And a feature file under path "com/example/features/Login.specb" with the following content:
      """
      Feature: User Login
        Scenario: Successful login
          Given user exists
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example.features;

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
      @FeatureFilePath("com/example/features/Login.specb")
      public class LoginTest extends UserFeatures {
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

    Scenario: .feature files are ignored when supportedFileExtensions is set to "specb"
      Given the following base class:
      """
      package com.example.features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(supportedFileExtensions = {"specb"})
      public abstract class UserFeatures {
      }
      """
      And a feature file under path "com/example/features/Login.feature" with the following content:
      """
      Feature: User Login
        Scenario: Successful login
          Given user exists
      """
      When the generator is run
      Then the generator should report an error:
      """
      No feature files found matching pattern 'com/example/features/*.specb'
      """

    Scenario: only .feature files are discovered when supportedFileExtensions is set to "feature"
      Given the following base class:
      """
      package com.example.features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(supportedFileExtensions = {"feature"})
      public abstract class UserFeatures {
      }
      """
      And a feature file under path "com/example/features/Login.feature" with the following content:
      """
      Feature: User Login
        Scenario: Successful login
          Given user exists
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example.features;

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
      @FeatureFilePath("com/example/features/Login.feature")
      public class LoginTest extends UserFeatures {
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

    Scenario: .specb files are ignored when supportedFileExtensions is set to "feature"
      Given the following base class:
      """
      package com.example.features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(supportedFileExtensions = {"feature"})
      public abstract class UserFeatures {
      }
      """
      And a feature file under path "com/example/features/Login.specb" with the following content:
      """
      Feature: User Login
        Scenario: Successful login
          Given user exists
      """
      When the generator is run
      Then the generator should report an error:
      """
      No feature files found matching pattern 'com/example/features/*.feature'
      """

  Rule: When supportedFileExtensions is set to multiple extensions, files with any of those extensions are discovered

    Scenario: files with all listed extensions are discovered
      Given the following base class:
      """
      package com.example.features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(supportedFileExtensions = {"feature", "specb", "gherkin"})
      public abstract class UserFeatures {
      }
      """
      And a feature file under path "com/example/features/Login.feature" with the following content:
      """
      Feature: User Login
        Scenario: Login test
          Given user logs in
      """
      And a feature file under path "com/example/features/Registration.specb" with the following content:
      """
      Feature: User Registration
        Scenario: Registration test
          Given user registers
      """
      And a feature file under path "com/example/features/Payment.gherkin" with the following content:
      """
      Feature: Payment
        Scenario: Payment test
          Given user pays
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example.features;

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
      @FeatureFilePath("com/example/features/Login.feature")
      public class LoginTest extends UserFeatures {
          public void userLogsIn() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Login test")
          public void scenario_1() {
              /*
               * Given user logs in
               */
              userLogsIn();
          }
      }
      """
      And the following class should be generated:
      """
      package com.example.features;

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
      @FeatureFilePath("com/example/features/Registration.specb")
      public class RegistrationTest extends UserFeatures {
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
      And the following class should be generated:
      """
      package com.example.features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Payment
       */
      @DisplayName("Payment")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("com/example/features/Payment.gherkin")
      public class PaymentTest extends UserFeatures {
          public void userPays() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Payment test")
          public void scenario_1() {
              /*
               * Given user pays
               */
              userPays();
          }
      }
      """

    Scenario: files with unlisted extensions are ignored
      Given the following base class:
      """
      package com.example.features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(supportedFileExtensions = {"specb"})
      public abstract class UserFeatures {
      }
      """
      And a feature file under path "com/example/features/Login.specb" with the following content:
      """
      Feature: User Login
        Scenario: Login test
          Given user logs in
      """
      And a feature file under path "com/example/features/Registration.feature" with the following content:
      """
      Feature: User Registration
        Scenario: Registration test
          Given user registers
      """
      And a feature file under path "com/example/features/Payment.gherkin" with the following content:
      """
      Feature: Payment
        Scenario: Payment test
          Given user pays
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example.features;

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
      @FeatureFilePath("com/example/features/Login.specb")
      public class LoginTest extends UserFeatures {
          public void userLogsIn() {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Login test")
          public void scenario_1() {
              /*
               * Given user logs in
               */
              userLogsIn();
          }
      }
      """
      And there should not be a class generated with name "RegistrationTest" in package "com.example.features"
      And there should not be a class generated with name "PaymentTest" in package "com.example.features"

  Rule: When an explicit file path is provided, the file is processed regardless of its extension

    Scenario: explicit path to a .txt file is processed successfully
      Given the following base class:
      """
      package com.example.features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit("com/example/features/Login.txt")
      public abstract class UserFeatures {
      }
      """
      And a feature file under path "com/example/features/Login.txt" with the following content:
      """
      Feature: User Login
        Scenario: Successful login
          Given user exists
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example.features;

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
      @FeatureFilePath("com/example/features/Login.txt")
      public class LoginTest extends UserFeatures {
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

    Scenario: explicit path to a .bdd file is processed successfully
      Given the following base class:
      """
      package com.example.features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit("com/example/features/Login.bdd")
      public abstract class UserFeatures {
      }
      """
      And a feature file under path "com/example/features/Login.bdd" with the following content:
      """
      Feature: User Login
        Scenario: Successful login
          Given user exists
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example.features;

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
      @FeatureFilePath("com/example/features/Login.bdd")
      public class LoginTest extends UserFeatures {
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

  Rule: The supportedFileExtensions option must not be an empty array

    Scenario: empty supportedFileExtensions array causes a processing error
      Given the following base class:
      """
      package com.example.features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(supportedFileExtensions = {})
      public abstract class UserFeatures {
      }
      """
      And a feature file under path "com/example/features/Login.feature" with the following content:
      """
      Feature: User Login
        Scenario: Successful login
          Given user exists
      """
      When the generator is run
      Then the generator should report an error:
      """
      supportedFileExtensions must not be empty
      """

  Rule: The supportedFileExtensions option must not contain blank values

    Scenario: blank value in supportedFileExtensions array causes a processing error
      Given the following base class:
      """
      package com.example.features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(supportedFileExtensions = {"feature", " "})
      public abstract class UserFeatures {
      }
      """
      And a feature file under path "com/example/features/Login.feature" with the following content:
      """
      Feature: User Login
        Scenario: Successful login
          Given user exists
      """
      When the generator is run
      Then the generator should report an error:
      """
      supportedFileExtensions must not contain blank values
      """

    Scenario: empty string in supportedFileExtensions array causes a processing error
      Given the following base class:
      """
      package com.example.features;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(supportedFileExtensions = {"feature", ""})
      public abstract class UserFeatures {
      }
      """
      And a feature file under path "com/example/features/Login.feature" with the following content:
      """
      Feature: User Login
        Scenario: Successful login
          Given user exists
      """
      When the generator is run
      Then the generator should report an error:
      """
      supportedFileExtensions must not contain blank values
      """
