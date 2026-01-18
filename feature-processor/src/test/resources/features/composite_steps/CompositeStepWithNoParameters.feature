Feature: CompositeStepsWithNoParameters
  As a developer using the Feature2JUnit generator
  I want to use composite step pattern to group related sub-steps under a higher-level abstraction
  So that I can create reusable step compositions without implementing additional glue code, similar to JBehave's textual composite steps

  Composite step pattern detection:
  - When enableCompositeSteps option is enabled, the generator detects Given/When/Then/And/But steps followed by one or more '*' keyword steps
  - The parent GWT step becomes a composite step container
  - The '*' steps become sub-steps executed within the composite step's lambda body
  - Only steps immediately following the parent step with '*' keyword are considered sub-steps
  - Detection stops when a non-'*' step is encountered
  - For each detected composite step, a method is generated with the step name
  - The method includes a varargs Consumer parameter (Runnable, Consumer<String> or BiConsumer<String,String>) as the last parameter
  - The method body checks if composite.length > 0 and executes the lambda using stream().forEach()
  - If composite is empty, "Assertions.fail("Step is not yet implemented")" is called instead
  - Method naming:
  -- Composite step methods use the same naming conventions as regular step methods

  Rule: when composite step doesn't have any parameters, Runnable is used as the composite step parameter

    Scenario: composite step without parameters
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true)
      public abstract class UserLogin {

      }
      """
      And the following feature file:
      """
      Feature: User Login
        Scenario: User performs login
          Given user is on login page
          * navigate to login form
          * verify login form is displayed
          * check security elements are present
          When user submits credentials
          * enter username
          * enter password
          * click login button
          Then user should be logged in
          * verify dashboard is displayed
          * check user profile is loaded
          * confirm session is active
      """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import static java.util.Arrays.stream;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.Runnable;
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
        @FeatureFilePath("com/example/UserLogin.feature")
        public class UserLoginTest extends UserLogin {
            protected void givenUserIsOnLoginPage(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void givenNavigateToLoginForm() {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenVerifyLoginFormIsDisplayed() {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenCheckSecurityElementsArePresent() {
                Assertions.fail("Step is not yet implemented");
            }

            protected void whenUserSubmitsCredentials(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void whenEnterUsername() {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenEnterPassword() {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenClickLoginButton() {
                Assertions.fail("Step is not yet implemented");
            }

            protected void thenUserShouldBeLoggedIn(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void thenVerifyDashboardIsDisplayed() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenCheckUserProfileIsLoaded() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenConfirmSessionIsActive() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: User performs login")
            public void scenario_1() {
                /*
                 * Given user is on login page
                 */
                givenUserIsOnLoginPage(() -> {
                    givenNavigateToLoginForm();
                    givenVerifyLoginFormIsDisplayed();
                    givenCheckSecurityElementsArePresent();
                });
                /*
                 * When user submits credentials
                 */
                whenUserSubmitsCredentials(() -> {
                    whenEnterUsername();
                    whenEnterPassword();
                    whenClickLoginButton();
                });
                /*
                 * Then user should be logged in
                 */
                thenUserShouldBeLoggedIn(() -> {
                    thenVerifyDashboardIsDisplayed();
                    thenCheckUserProfileIsLoaded();
                    thenConfirmSessionIsActive();
                });
            }
        }
        """

  Rule: And & But keyword leading steps are also considered for composite step detection

    Scenario: composite step with And and But keywords after Given keyword step
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true)
      public abstract class UserRegistration {

      }
      """
      And the following feature file:
      """
      Feature: User Registration
        Scenario: User completes registration process
          Given user is on registration page
          * navigate to registration form
          * verify form fields are present
          And user has valid email address
          * check email format
          * verify email domain exists
          But user password is weak
          * password is too short
          * password lacks special characters
          When user submits registration form
          Then registration should be successful
      """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import static java.util.Arrays.stream;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.Runnable;
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
        @FeatureFilePath("com/example/UserRegistration.feature")
        public class UserRegistrationTest extends UserRegistration {
            protected void givenUserIsOnRegistrationPage(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void givenNavigateToRegistrationForm() {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenVerifyFormFieldsArePresent() {
                Assertions.fail("Step is not yet implemented");
            }

            protected void givenUserHasValidEmailAddress(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void givenCheckEmailFormat() {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenVerifyEmailDomainExists() {
                Assertions.fail("Step is not yet implemented");
            }

            protected void givenUserPasswordIsWeak(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void givenPasswordIsTooShort() {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenPasswordLacksSpecialCharacters() {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenUserSubmitsRegistrationForm() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenRegistrationShouldBeSuccessful() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: User completes registration process")
            public void scenario_1() {
                /*
                 * Given user is on registration page
                 */
                givenUserIsOnRegistrationPage(() -> {
                    givenNavigateToRegistrationForm();
                    givenVerifyFormFieldsArePresent();
                });
                /*
                 * And user has valid email address
                 */
                givenUserHasValidEmailAddress(() -> {
                    givenCheckEmailFormat();
                    givenVerifyEmailDomainExists();
                });
                /*
                 * But user password is weak
                 */
                givenUserPasswordIsWeak(() -> {
                    givenPasswordIsTooShort();
                    givenPasswordLacksSpecialCharacters();
                });
                /*
                 * When user submits registration form
                 */
                whenUserSubmitsRegistrationForm();
                /*
                 * Then registration should be successful
                 */
                thenRegistrationShouldBeSuccessful();
            }
        }
        """

    Scenario: composite step with And and But keywords after When keyword step
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true)
      public abstract class UserPayment {

      }
      """
      And the following feature file:
      """
      Feature: User Payment
        Scenario: User processes payment transaction
          When user initiates payment process
          * select payment method
          * enter payment details
          And user confirms payment amount
          * verify total amount
          * check currency conversion
          But user payment method has issues
          * card is expired
          * insufficient funds detected
          Then payment should be processed
      """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import static java.util.Arrays.stream;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.Runnable;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: User Payment
         */
        @DisplayName("UserPayment")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/UserPayment.feature")
        public class UserPaymentTest extends UserPayment {
            protected void whenUserInitiatesPaymentProcess(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void whenSelectPaymentMethod() {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenEnterPaymentDetails() {
                Assertions.fail("Step is not yet implemented");
            }

            protected void whenUserConfirmsPaymentAmount(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void whenVerifyTotalAmount() {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenCheckCurrencyConversion() {
                Assertions.fail("Step is not yet implemented");
            }

            protected void whenUserPaymentMethodHasIssues(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void whenCardIsExpired() {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenInsufficientFundsDetected() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenPaymentShouldBeProcessed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: User processes payment transaction")
            public void scenario_1() {
                /*
                 * When user initiates payment process
                 */
                whenUserInitiatesPaymentProcess(() -> {
                    whenSelectPaymentMethod();
                    whenEnterPaymentDetails();
                });
                /*
                 * And user confirms payment amount
                 */
                whenUserConfirmsPaymentAmount(() -> {
                    whenVerifyTotalAmount();
                    whenCheckCurrencyConversion();
                });
                /*
                 * But user payment method has issues
                 */
                whenUserPaymentMethodHasIssues(() -> {
                    whenCardIsExpired();
                    whenInsufficientFundsDetected();
                });
                /*
                 * Then payment should be processed
                 */
                thenPaymentShouldBeProcessed();
            }
        }
        """

    Scenario: composite step with And and But keywords after Then keyword step
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true)
      public abstract class UserProfile {

      }
      """
      And the following feature file:
      """
      Feature: User Profile
        Scenario: User profile validation results
          Given user has completed profile setup
          When user profile is validated
          Then user profile should be complete
          * verify all required fields are filled
          * check profile photo is uploaded
          * confirm contact information is valid
          And user profile should be visible
          * profile appears in search results
          * profile shows correct information
          But user profile has privacy restrictions
          * some fields are hidden from public
          * contact details require permission
      """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import static java.util.Arrays.stream;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.Runnable;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: User Profile
         */
        @DisplayName("UserProfile")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/UserProfile.feature")
        public class UserProfileTest extends UserProfile {
            public void givenUserHasCompletedProfileSetup() {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenUserProfileIsValidated() {
                Assertions.fail("Step is not yet implemented");
            }

            protected void thenUserProfileShouldBeComplete(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void thenVerifyAllRequiredFieldsAreFilled() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenCheckProfilePhotoIsUploaded() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenConfirmContactInformationIsValid() {
                Assertions.fail("Step is not yet implemented");
            }

            protected void thenUserProfileShouldBeVisible(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void thenProfileAppearsInSearchResults() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenProfileShowsCorrectInformation() {
                Assertions.fail("Step is not yet implemented");
            }

            protected void thenUserProfileHasPrivacyRestrictions(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void thenSomeFieldsAreHiddenFromPublic() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenContactDetailsRequirePermission() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: User profile validation results")
            public void scenario_1() {
                /*
                 * Given user has completed profile setup
                 */
                givenUserHasCompletedProfileSetup();
                /*
                 * When user profile is validated
                 */
                whenUserProfileIsValidated();
                /*
                 * Then user profile should be complete
                 */
                thenUserProfileShouldBeComplete(() -> {
                    thenVerifyAllRequiredFieldsAreFilled();
                    thenCheckProfilePhotoIsUploaded();
                    thenConfirmContactInformationIsValid();
                });
                /*
                 * And user profile should be visible
                 */
                thenUserProfileShouldBeVisible(() -> {
                    thenProfileAppearsInSearchResults();
                    thenProfileShowsCorrectInformation();
                });
                /*
                 * But user profile has privacy restrictions
                 */
                thenUserProfileHasPrivacyRestrictions(() -> {
                    thenSomeFieldsAreHiddenFromPublic();
                    thenContactDetailsRequirePermission();
                });
            }
        }
        """

