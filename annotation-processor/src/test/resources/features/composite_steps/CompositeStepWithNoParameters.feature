Feature: CompositeStepsWithNoParameters
  As a developer using the Gherkin2JUnit generator
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

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(enableCompositeSteps = true)
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/UserLogin.feature")
        public class UserLoginTest extends UserLogin {
            protected void userIsOnLoginPage(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void navigateToLoginForm() {
                Assertions.fail("Step is not yet implemented");
            }

            public void verifyLoginFormIsDisplayed() {
                Assertions.fail("Step is not yet implemented");
            }

            public void checkSecurityElementsArePresent() {
                Assertions.fail("Step is not yet implemented");
            }

            protected void userSubmitsCredentials(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void enterUsername() {
                Assertions.fail("Step is not yet implemented");
            }

            public void enterPassword() {
                Assertions.fail("Step is not yet implemented");
            }

            public void clickLoginButton() {
                Assertions.fail("Step is not yet implemented");
            }

            protected void userShouldBeLoggedIn(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void verifyDashboardIsDisplayed() {
                Assertions.fail("Step is not yet implemented");
            }

            public void checkUserProfileIsLoaded() {
                Assertions.fail("Step is not yet implemented");
            }

            public void confirmSessionIsActive() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: User performs login")
            public void scenario_1() {
                /*
                 * Given user is on login page
                 */
                userIsOnLoginPage(() -> {
                    navigateToLoginForm();
                    verifyLoginFormIsDisplayed();
                    checkSecurityElementsArePresent();
                });
                /*
                 * When user submits credentials
                 */
                userSubmitsCredentials(() -> {
                    enterUsername();
                    enterPassword();
                    clickLoginButton();
                });
                /*
                 * Then user should be logged in
                 */
                userShouldBeLoggedIn(() -> {
                    verifyDashboardIsDisplayed();
                    checkUserProfileIsLoaded();
                    confirmSessionIsActive();
                });
            }
        }
        """

  Rule: And & But keyword leading steps are also considered for composite step detection

    Scenario: composite step with And and But keywords after Given keyword step
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(enableCompositeSteps = true)
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/UserRegistration.feature")
        public class UserRegistrationTest extends UserRegistration {
            protected void userIsOnRegistrationPage(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void navigateToRegistrationForm() {
                Assertions.fail("Step is not yet implemented");
            }

            public void verifyFormFieldsArePresent() {
                Assertions.fail("Step is not yet implemented");
            }

            protected void userHasValidEmailAddress(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void checkEmailFormat() {
                Assertions.fail("Step is not yet implemented");
            }

            public void verifyEmailDomainExists() {
                Assertions.fail("Step is not yet implemented");
            }

            protected void userPasswordIsWeak(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void passwordIsTooShort() {
                Assertions.fail("Step is not yet implemented");
            }

            public void passwordLacksSpecialCharacters() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userSubmitsRegistrationForm() {
                Assertions.fail("Step is not yet implemented");
            }

            public void registrationShouldBeSuccessful() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: User completes registration process")
            public void scenario_1() {
                /*
                 * Given user is on registration page
                 */
                userIsOnRegistrationPage(() -> {
                    navigateToRegistrationForm();
                    verifyFormFieldsArePresent();
                });
                /*
                 * And user has valid email address
                 */
                userHasValidEmailAddress(() -> {
                    checkEmailFormat();
                    verifyEmailDomainExists();
                });
                /*
                 * But user password is weak
                 */
                userPasswordIsWeak(() -> {
                    passwordIsTooShort();
                    passwordLacksSpecialCharacters();
                });
                /*
                 * When user submits registration form
                 */
                userSubmitsRegistrationForm();
                /*
                 * Then registration should be successful
                 */
                registrationShouldBeSuccessful();
            }
        }
        """

    Scenario: composite step with And and But keywords after When keyword step
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(enableCompositeSteps = true)
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/UserPayment.feature")
        public class UserPaymentTest extends UserPayment {
            protected void userInitiatesPaymentProcess(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void selectPaymentMethod() {
                Assertions.fail("Step is not yet implemented");
            }

            public void enterPaymentDetails() {
                Assertions.fail("Step is not yet implemented");
            }

            protected void userConfirmsPaymentAmount(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void verifyTotalAmount() {
                Assertions.fail("Step is not yet implemented");
            }

            public void checkCurrencyConversion() {
                Assertions.fail("Step is not yet implemented");
            }

            protected void userPaymentMethodHasIssues(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void cardIsExpired() {
                Assertions.fail("Step is not yet implemented");
            }

            public void insufficientFundsDetected() {
                Assertions.fail("Step is not yet implemented");
            }

            public void paymentShouldBeProcessed() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: User processes payment transaction")
            public void scenario_1() {
                /*
                 * When user initiates payment process
                 */
                userInitiatesPaymentProcess(() -> {
                    selectPaymentMethod();
                    enterPaymentDetails();
                });
                /*
                 * And user confirms payment amount
                 */
                userConfirmsPaymentAmount(() -> {
                    verifyTotalAmount();
                    checkCurrencyConversion();
                });
                /*
                 * But user payment method has issues
                 */
                userPaymentMethodHasIssues(() -> {
                    cardIsExpired();
                    insufficientFundsDetected();
                });
                /*
                 * Then payment should be processed
                 */
                paymentShouldBeProcessed();
            }
        }
        """

    Scenario: composite step with And and But keywords after Then keyword step
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Gherkin2JUnit;
      import dev.specbinder.annotations.Gherkin2JUnitOptions;

      @Gherkin2JUnit
      @Gherkin2JUnitOptions(enableCompositeSteps = true)
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/UserProfile.feature")
        public class UserProfileTest extends UserProfile {
            public void userHasCompletedProfileSetup() {
                Assertions.fail("Step is not yet implemented");
            }

            public void userProfileIsValidated() {
                Assertions.fail("Step is not yet implemented");
            }

            protected void userProfileShouldBeComplete(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void verifyAllRequiredFieldsAreFilled() {
                Assertions.fail("Step is not yet implemented");
            }

            public void checkProfilePhotoIsUploaded() {
                Assertions.fail("Step is not yet implemented");
            }

            public void confirmContactInformationIsValid() {
                Assertions.fail("Step is not yet implemented");
            }

            protected void userProfileShouldBeVisible(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void profileAppearsInSearchResults() {
                Assertions.fail("Step is not yet implemented");
            }

            public void profileShowsCorrectInformation() {
                Assertions.fail("Step is not yet implemented");
            }

            protected void userProfileHasPrivacyRestrictions(Runnable... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(r -> r.run());
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void someFieldsAreHiddenFromPublic() {
                Assertions.fail("Step is not yet implemented");
            }

            public void contactDetailsRequirePermission() {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: User profile validation results")
            public void scenario_1() {
                /*
                 * Given user has completed profile setup
                 */
                userHasCompletedProfileSetup();
                /*
                 * When user profile is validated
                 */
                userProfileIsValidated();
                /*
                 * Then user profile should be complete
                 */
                userProfileShouldBeComplete(() -> {
                    verifyAllRequiredFieldsAreFilled();
                    checkProfilePhotoIsUploaded();
                    confirmContactInformationIsValid();
                });
                /*
                 * And user profile should be visible
                 */
                userProfileShouldBeVisible(() -> {
                    profileAppearsInSearchResults();
                    profileShowsCorrectInformation();
                });
                /*
                 * But user profile has privacy restrictions
                 */
                userProfileHasPrivacyRestrictions(() -> {
                    someFieldsAreHiddenFromPublic();
                    contactDetailsRequirePermission();
                });
            }
        }
        """

