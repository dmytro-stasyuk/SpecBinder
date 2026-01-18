Feature: MappingFeatureBlock
  As a developer reviewing or maintaining generated test code
  I want the feature description to appear as JavaDoc comments in the generated class
  So that I can quickly understand the purpose without switching to the original feature file

  Rule: "Feature:" keyword should be mapped to a javadoc comment in the generated class followed by the feature name
  and description lines verbatim

    Scenario: with the keyword and name
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
      Feature: feature name
      """

      When the generator is run
      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;

      /**
       * Feature: feature name
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
      }
      """

    Scenario: with the keyword, name and description lines
      Given the following base class:
      """
      package features;

      import dev.specbinder.annotations.Feature2JUnit;

      @Feature2JUnit
      public abstract class MyFeature {
      }
      """
      And the following feature file:
      """
      Feature: feature name
        feature description line 1
        feature description line 2
      """

      When the generator is run

      Then the following class should be generated:
      """
      package features;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import javax.annotation.processing.Generated;
      import org.junit.jupiter.api.DisplayName;

      /**
       * Feature: feature name
       *   feature description line 1
       *   feature description line 2
       */
      @DisplayName("MyFeature")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @FeatureFilePath("features/MyFeature.feature")
      public class MyFeatureTest extends MyFeature {
      }
      """