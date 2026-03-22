Feature: StepDocParameterWithDollarSigns
  As a developer
  I want dollar signs ($) in step doc parameter text to be handled correctly
  So that method calls work properly with JavaPoet's formatting system

  Rule: Dollar signs in DocStrings are escaped for JavaPoet
  - Dollar signs in DocString content are doubled ($$) for JavaPoet
  - This ensures JavaPoet doesn't interpret them as format placeholders

    Scenario: DocString with dollar signs
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
        Feature: DocString Dollar Signs
          Scenario: Test
            Given document contains:
              \"\"\"
              Price: $100
              Tax: $15
              Total: $115
              \"\"\"
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
         * Feature: DocString Dollar Signs
         */
        @DisplayName("MyFeature")
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("features/MyFeature.feature")
        public class MyFeatureTest extends MyFeature {
            public void documentContains(String docString) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Test")
            public void scenario_1() {
                /*
                 * Given document contains:
                 */
                documentContains(\"\"\"
                        Price: $100
                        Tax: $15
                        Total: $115
                        \"\"\");
            }
        }
        """
