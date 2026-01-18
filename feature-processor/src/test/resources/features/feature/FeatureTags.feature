Feature: FeatureTags
  As a developer managing test execution in CI/CD pipelines
  I want Gherkin feature tags to be mapped to JUnit @Tag annotations
  So that I can filter which tests to run based on context (e.g., run only @smoke tests on PR, @regression on release)

  Rule: Feature tags are converted to JUnit @Tag annotations on the class

    Scenario: single feature tag becomes @Tag annotation
      Given the following base class:
      """
      package com.example.tests;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class SmokeTests {
      }
      """
      And the following feature file:
      """
      @smoke
      Feature: Smoke Tests
        Critical tests that must pass
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example.tests;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.Tag;

      /**
       * Feature: Smoke Tests
       *   Critical tests that must pass
       */
      @Tag("smoke")
      @DisplayName("SmokeTests")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @FeatureFilePath("com/example/tests/SmokeTests.feature")
      public class SmokeTestsTest extends SmokeTests {
      }
      """

  Rule: Multiple feature tags result in @Tags container annotation which contains an array of @Tag annotations, one for each Gherkin tag

    Scenario: multiple feature tags
      Given the following base class:
      """
      package com.example.api;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class UserApiTests {
      }
      """
      And the following feature file:
      """
      @smoke @regression @api
      Feature: User API
        Testing user management endpoints
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example.api;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.Tag;
      import org.junit.jupiter.api.Tags;

      /**
       * Feature: User API
       *   Testing user management endpoints
       */
      @Tags({
              @Tag("smoke"),
              @Tag("regression"),
              @Tag("api")
      })
      @DisplayName("UserApiTests")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @FeatureFilePath("com/example/api/UserApiTests.feature")
      public class UserApiTestsTest extends UserApiTests {
      }
      """


