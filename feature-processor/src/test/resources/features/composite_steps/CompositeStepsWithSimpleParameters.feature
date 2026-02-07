Feature: CompositeStepsWithSimpleParameters
  As a developer using the Feature2JUnit generator
  I want to use composite step pattern to group related sub-steps under a higher-level abstraction
  So that I can create reusable step compositions without implementing additional glue code, similar to JBehave's textual composite steps

  Rule: Parameters from the parent composite step (quoted strings) are extracted and numbered as p1, p2, p3, etc.
  - The method includes parameters for each quoted value in the parent step text
  - Parameter types default to String
  - for composite steps with 1 parameter, Consumer<String> is used
  - for composite steps with 2 parameters, BiConsumer<String, String> is used
  - for composite steps with 3 parameters, org.apache.commons.lang3.function.TriConsumer<String, String, String> is used
  - having more than 3 parameters is not supported and should result in a generation error
  - The last method parameter is a varargs array of the appropriate functional interface type for sub-step lambdas
  - Call site generation with lambda:
  -- In test methods, composite steps are invoked with the extracted parameter values
  -- The lambda parameters match the number of parameters from the parent step (p1, p2, etc.)

    Scenario: composite step with a single parameter
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true)
      public abstract class ProductCatalog {

      }
      """
      And the following feature file:
      """
      Feature: Product Catalog
        Scenario: Search for product
          Given user searches for product "Laptop"
          * open search page
          * enter search term "Laptop"
          * click search button
          * filter results by category
          When search results are displayed
          Then product "Laptop" should be found
      """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import static java.util.Arrays.stream;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.String;
        import java.util.function.Consumer;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Product Catalog
         */
        @DisplayName("ProductCatalog")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/ProductCatalog.feature")
        public class ProductCatalogTest extends ProductCatalog {
            protected void givenUserSearchesForProduct$p1(String p1, Consumer<String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void givenOpenSearchPage() {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenEnterSearchTerm$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenClickSearchButton() {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenFilterResultsByCategory() {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenSearchResultsAreDisplayed() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenProduct$p1ShouldBeFound(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Search for product")
            public void scenario_1() {
                /*
                 * Given user searches for product "Laptop"
                 */
                givenUserSearchesForProduct$p1("Laptop", (p1) -> {
                    givenOpenSearchPage();
                    givenEnterSearchTerm$p1("Laptop");
                    givenClickSearchButton();
                    givenFilterResultsByCategory();
                });
                /*
                 * When search results are displayed
                 */
                whenSearchResultsAreDisplayed();
                /*
                 * Then product "Laptop" should be found
                 */
                thenProduct$p1ShouldBeFound("Laptop");
            }
        }
        """

    Scenario: composite step with two parameters
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true)
      public abstract class UserManagement {

      }
      """
      And the following feature file:
      """
      Feature: User Management
          Scenario: Create new user
          Given admin "Bob" wants to create a new user "Alex"
          * navigate to "User Management" page
          * click on "Create User" button
          * fill in user details for "Alex"
          * submit the form
          * verify user "Alex" is created
      """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import static java.util.Arrays.stream;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.String;
        import java.util.function.BiConsumer;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: User Management
         */
        @DisplayName("UserManagement")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/UserManagement.feature")
        public class UserManagementTest extends UserManagement {
            protected void givenAdmin$p1WantsToCreateANewUser$p2(String p1, String p2,
                    BiConsumer<String, String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1, p2));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void givenNavigateTo$p1Page(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenClickOn$p1Button(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenFillInUserDetailsFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenSubmitTheForm() {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenVerifyUser$p1IsCreated(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Create new user")
            public void scenario_1() {
                /*
                 * Given admin "Bob" wants to create a new user "Alex"
                 */
                givenAdmin$p1WantsToCreateANewUser$p2("Bob", "Alex", (p1, p2) -> {
                    givenNavigateTo$p1Page("User Management");
                    givenClickOn$p1Button("Create User");
                    givenFillInUserDetailsFor$p1("Alex");
                    givenSubmitTheForm();
                    givenVerifyUser$p1IsCreated("Alex");
                });
            }
        }
        """

    Scenario: composite step with three parameters
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true)
      public abstract class BookingSystem {

      }
      """
      And the following feature file:
      """
      Feature: Booking System
        Scenario: Book hotel room
          Given customer "Sarah" books room "Deluxe Suite" for date "2024-12-25"
          * verify customer $p1 has valid account
          * check room $p2 is available on $p3
          * calculate price for $p2 on $p3
          * reserve room $p2 for customer $p1
          * send confirmation to customer $p1
          When booking is processed
          Then booking should be confirmed for "Sarah"
      """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import static java.util.Arrays.stream;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.String;
        import javax.annotation.processing.Generated;
        import org.apache.commons.lang3.function.TriConsumer;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Booking System
         */
        @DisplayName("BookingSystem")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/BookingSystem.feature")
        public class BookingSystemTest extends BookingSystem {
            protected void givenCustomer$p1BooksRoom$p2ForDate$p3(String p1, String p2, String p3,
                    TriConsumer<String, String, String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1, p2, p3));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void givenVerifyCustomer$p1HasValidAccount(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenCheckRoom$p1IsAvailableOn$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenCalculatePriceFor$p1On$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenReserveRoom$p1ForCustomer$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenSendConfirmationToCustomer$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenBookingIsProcessed() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenBookingShouldBeConfirmedFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Book hotel room")
            public void scenario_1() {
                /*
                 * Given customer "Sarah" books room "Deluxe Suite" for date "2024-12-25"
                 */
                givenCustomer$p1BooksRoom$p2ForDate$p3("Sarah", "Deluxe Suite", "2024-12-25", (p1, p2, p3) -> {
                    givenVerifyCustomer$p1HasValidAccount(p1);
                    givenCheckRoom$p1IsAvailableOn$p2(p2, p3);
                    givenCalculatePriceFor$p1On$p2(p2, p3);
                    givenReserveRoom$p1ForCustomer$p2(p2, p1);
                    givenSendConfirmationToCustomer$p1(p1);
                });
                /*
                 * When booking is processed
                 */
                whenBookingIsProcessed();
                /*
                 * Then booking should be confirmed for "Sarah"
                 */
                thenBookingShouldBeConfirmedFor$p1("Sarah");
            }
        }
        """

    Scenario: composite step with more than three parameters
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true)
      public abstract class ExcessiveParameters {

      }
      """
      And the following feature file:
      """
      Feature: Excessive Parameters
        Scenario: Too many parameters
          Given step with "one" then "two" then "three" then "four" parameters
          * sub-step one
          * sub-step two
      """
      When the generator is run
      Then the generator should report an error:
      """
      Composite steps with 4 parameters not yet supported. Only 0-3 parameters are currently supported.
      """

  Rule: Sub-steps can reference parameters from the parent step using $p1, $p2, $p3 syntax
  - Sub-step calls within the lambda use the lambda parameters when $pN references are present
  - Sub-steps generate their own step methods as usual

    Scenario: Composite step with one parameter and references to it in sub-steps
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true)
      public abstract class CustomerService {

      }
      """
      And the following feature file:
      """
      Feature: Customer Service
        Scenario: Process customer request
          Given customer "Alice" submits a support request
          * verify customer $p1 is registered
          * create ticket for customer $p1
          * assign agent to customer $p1
          * send confirmation to $p1
          When request is processed
          Then customer "Alice" should receive confirmation
      """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import static java.util.Arrays.stream;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.String;
        import java.util.function.Consumer;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Customer Service
         */
        @DisplayName("CustomerService")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/CustomerService.feature")
        public class CustomerServiceTest extends CustomerService {
            protected void givenCustomer$p1SubmitsASupportRequest(String p1,
                    Consumer<String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void givenVerifyCustomer$p1IsRegistered(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenCreateTicketForCustomer$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenAssignAgentToCustomer$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenSendConfirmationTo$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenRequestIsProcessed() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenCustomer$p1ShouldReceiveConfirmation(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Process customer request")
            public void scenario_1() {
                /*
                 * Given customer "Alice" submits a support request
                 */
                givenCustomer$p1SubmitsASupportRequest("Alice", (p1) -> {
                    givenVerifyCustomer$p1IsRegistered(p1);
                    givenCreateTicketForCustomer$p1(p1);
                    givenAssignAgentToCustomer$p1(p1);
                    givenSendConfirmationTo$p1(p1);
                });
                /*
                 * When request is processed
                 */
                whenRequestIsProcessed();
                /*
                 * Then customer "Alice" should receive confirmation
                 */
                thenCustomer$p1ShouldReceiveConfirmation("Alice");
            }
        }
        """

    Scenario: Composite step with two parameters and references to them in sub-steps
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true)
      public abstract class OrderProcessing {

      }
      """
      And the following feature file:
      """
      Feature: Order Processing
        Scenario: Process customer order
          Given customer "John" places order for "Smartphone"
          * verify customer $p1 is registered
          * check product $p2 is available
          * calculate price for $p2
          * create order for customer $p1
          When order is submitted
          Then order should be confirmed for "John"
      """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import static java.util.Arrays.stream;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.String;
        import java.util.function.BiConsumer;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Order Processing
         */
        @DisplayName("OrderProcessing")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/OrderProcessing.feature")
        public class OrderProcessingTest extends OrderProcessing {
            protected void givenCustomer$p1PlacesOrderFor$p2(String p1, String p2,
                    BiConsumer<String, String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1, p2));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void givenVerifyCustomer$p1IsRegistered(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenCheckProduct$p1IsAvailable(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenCalculatePriceFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenCreateOrderForCustomer$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenOrderIsSubmitted() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenOrderShouldBeConfirmedFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Process customer order")
            public void scenario_1() {
                /*
                 * Given customer "John" places order for "Smartphone"
                 */
                givenCustomer$p1PlacesOrderFor$p2("John", "Smartphone", (p1, p2) -> {
                    givenVerifyCustomer$p1IsRegistered(p1);
                    givenCheckProduct$p1IsAvailable(p2);
                    givenCalculatePriceFor$p1(p2);
                    givenCreateOrderForCustomer$p1(p1);
                });
                /*
                 * When order is submitted
                 */
                whenOrderIsSubmitted();
                /*
                 * Then order should be confirmed for "John"
                 */
                thenOrderShouldBeConfirmedFor$p1("John");
            }
        }
        """

    Scenario: Composite step with three parameters and references to them in sub-steps
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true)
      public abstract class TravelBooking {

      }
      """
      And the following feature file:
      """
      Feature: Travel Booking
          Scenario: Book flight and hotel
          Given traveler "Emma" books flight "FL123" and hotel "Grand Hotel"
          * verify traveler $p1 has valid passport
          * check flight $p2 availability on $p3
          * check hotel $p3 availability on $p3
          * reserve flight $p2 for traveler $p1
          * reserve hotel $p3 for traveler $p1
          When booking is completed
          Then booking confirmation should be sent to "Emma"
      """
      When the generator is run
      Then the following class should be generated:
      """
      package com.example;

      import static java.util.Arrays.stream;

      import dev.specbinder.annotations.output.FeatureFilePath;
      import java.lang.String;
      import javax.annotation.processing.Generated;
      import org.apache.commons.lang3.function.TriConsumer;
      import org.junit.jupiter.api.Assertions;
      import org.junit.jupiter.api.DisplayName;
      import org.junit.jupiter.api.MethodOrderer;
      import org.junit.jupiter.api.Order;
      import org.junit.jupiter.api.Test;
      import org.junit.jupiter.api.TestMethodOrder;

      /**
       * Feature: Travel Booking
       */
      @DisplayName("TravelBooking")
      @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @FeatureFilePath("com/example/TravelBooking.feature")
      public class TravelBookingTest extends TravelBooking {
          protected void givenTraveler$p1BooksFlight$p2AndHotel$p3(String p1, String p2, String p3,
                  TriConsumer<String, String, String>... composite) {
              if (composite.length > 0) {
                  stream(composite).forEach(action -> action.accept(p1, p2, p3));
              } else {
                  Assertions.fail("Step is not yet implemented");
              }
          }

          public void givenVerifyTraveler$p1HasValidPassport(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void givenCheckFlight$p1AvailabilityOn$p2(String p1, String p2) {
              Assertions.fail("Step is not yet implemented");
          }

          public void givenCheckHotel$p1AvailabilityOn$p2(String p1, String p2) {
              Assertions.fail("Step is not yet implemented");
          }

          public void givenReserveFlight$p1ForTraveler$p2(String p1, String p2) {
              Assertions.fail("Step is not yet implemented");
          }

          public void givenReserveHotel$p1ForTraveler$p2(String p1, String p2) {
              Assertions.fail("Step is not yet implemented");
          }

          public void whenBookingIsCompleted() {
              Assertions.fail("Step is not yet implemented");
          }

          public void thenBookingConfirmationShouldBeSentTo$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Book flight and hotel")
          public void scenario_1() {
              /*
               * Given traveler "Emma" books flight "FL123" and hotel "Grand Hotel"
               */
              givenTraveler$p1BooksFlight$p2AndHotel$p3("Emma", "FL123", "Grand Hotel", (p1, p2, p3) -> {
                  givenVerifyTraveler$p1HasValidPassport(p1);
                  givenCheckFlight$p1AvailabilityOn$p2(p2, p3);
                  givenCheckHotel$p1AvailabilityOn$p2(p3, p3);
                  givenReserveFlight$p1ForTraveler$p2(p2, p1);
                  givenReserveHotel$p1ForTraveler$p2(p3, p1);
              });
              /*
               * When booking is completed
               */
              whenBookingIsCompleted();
              /*
               * Then booking confirmation should be sent to "Emma"
               */
              thenBookingConfirmationShouldBeSentTo$p1("Emma");
          }
      }
      """

  Rule: Sub-steps can have their own parameters (quoted strings) in addition to $pN references

    Scenario: Composite step with one parameter and references to it in sub-steps with their own parameters
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true)
      public abstract class NotificationService {

      }
      """
      And the following feature file:
      """
      Feature: Notification Service
        Scenario: Send notification to user
          Given user "Bob" receives a notification
          * send email to $p1 with subject "Welcome"
          * send SMS to $p1 with message "Thank you"
          * log notification sent to $p1 with status "Success"
          When notification is delivered
          Then user "Bob" should be notified
      """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import static java.util.Arrays.stream;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.String;
        import java.util.function.Consumer;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Notification Service
         */
        @DisplayName("NotificationService")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/NotificationService.feature")
        public class NotificationServiceTest extends NotificationService {
            protected void givenUser$p1ReceivesANotification(String p1, Consumer<String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void givenSendEmailTo$p1WithSubject$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenSendSmsTo$p1WithMessage$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenLogNotificationSentTo$p1WithStatus$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenNotificationIsDelivered() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenUser$p1ShouldBeNotified(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Send notification to user")
            public void scenario_1() {
                /*
                 * Given user "Bob" receives a notification
                 */
                givenUser$p1ReceivesANotification("Bob", (p1) -> {
                    givenSendEmailTo$p1WithSubject$p2(p1, "Welcome");
                    givenSendSmsTo$p1WithMessage$p2(p1, "Thank you");
                    givenLogNotificationSentTo$p1WithStatus$p2(p1, "Success");
                });
                /*
                 * When notification is delivered
                 */
                whenNotificationIsDelivered();
                /*
                 * Then user "Bob" should be notified
                 */
                thenUser$p1ShouldBeNotified("Bob");
            }
        }
        """

    Scenario: Composite step with two parameters and references to it in sub-steps with their own parameters
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true)
      public abstract class PaymentProcessing {

      }
      """
      And the following feature file:
      """
      Feature: Payment Processing
        Scenario: Process payment for customer
          Given customer "Alice" makes payment of "100.00"
          * validate customer $p1 with method "Credit Card"
          * charge amount $p2 to customer $p1
          * send receipt to $p1 with amount $p2
          * send receipt "120" to $p1
          * log transaction for $p1 with status "Completed"
          When payment is processed
          Then payment should be confirmed for "Alice"
      """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import static java.util.Arrays.stream;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.Integer;
        import java.lang.String;
        import java.util.function.BiConsumer;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Payment Processing
         */
        @DisplayName("PaymentProcessing")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/PaymentProcessing.feature")
        public class PaymentProcessingTest extends PaymentProcessing {
            protected void givenCustomer$p1MakesPaymentOf$p2(String p1, String p2,
                    BiConsumer<String, String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1, p2));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void givenValidateCustomer$p1WithMethod$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenChargeAmount$p1ToCustomer$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenSendReceiptTo$p1WithAmount$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenSendReceipt$p1To$p2(Integer p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenLogTransactionFor$p1WithStatus$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenPaymentIsProcessed() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenPaymentShouldBeConfirmedFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Process payment for customer")
            public void scenario_1() {
                /*
                 * Given customer "Alice" makes payment of "100.00"
                 */
                givenCustomer$p1MakesPaymentOf$p2("Alice", "100.00", (p1, p2) -> {
                    givenValidateCustomer$p1WithMethod$p2(p1, "Credit Card");
                    givenChargeAmount$p1ToCustomer$p2(p2, p1);
                    givenSendReceiptTo$p1WithAmount$p2(p1, p2);
                    givenSendReceipt$p1To$p2(120, p1);
                    givenLogTransactionFor$p1WithStatus$p2(p1, "Completed");
                });
                /*
                 * When payment is processed
                 */
                whenPaymentIsProcessed();
                /*
                 * Then payment should be confirmed for "Alice"
                 */
                thenPaymentShouldBeConfirmedFor$p1("Alice");
            }
        }
        """

    Scenario: Composite step with sub-steps containing Long parameters
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true)
      public abstract class DataProcessing {

      }
      """
      And the following feature file:
      """
      Feature: Data Processing
        Scenario: Process large dataset
          Given user "Bob" processes dataset with ID "999999999999"
          * load dataset "999999999999" from storage
          * validate user $p1 has access to dataset "999999999999"
          * calculate checksum for dataset "999999999999"
          When processing is complete
          Then user "Bob" should see results
      """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import static java.util.Arrays.stream;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.Long;
        import java.lang.String;
        import java.util.function.BiConsumer;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Data Processing
         */
        @DisplayName("DataProcessing")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/DataProcessing.feature")
        public class DataProcessingTest extends DataProcessing {
            protected void givenUser$p1ProcessesDatasetWithId$p2(String p1, String p2,
                    BiConsumer<String, String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1, p2));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void givenLoadDataset$p1FromStorage(Long p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenValidateUser$p1HasAccessToDataset$p2(String p1, Long p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenCalculateChecksumForDataset$p1(Long p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenProcessingIsComplete() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenUser$p1ShouldSeeResults(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Process large dataset")
            public void scenario_1() {
                /*
                 * Given user "Bob" processes dataset with ID "999999999999"
                 */
                givenUser$p1ProcessesDatasetWithId$p2("Bob", "999999999999", (p1, p2) -> {
                    givenLoadDataset$p1FromStorage(999999999999L);
                    givenValidateUser$p1HasAccessToDataset$p2(p1, 999999999999L);
                    givenCalculateChecksumForDataset$p1(999999999999L);
                });
                /*
                 * When processing is complete
                 */
                whenProcessingIsComplete();
                /*
                 * Then user "Bob" should see results
                 */
                thenUser$p1ShouldSeeResults("Bob");
            }
        }
        """

    Scenario: Composite step with sub-steps containing Boolean parameters
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true)
      public abstract class FeatureToggle {

      }
      """
      And the following feature file:
      """
      Feature: Feature Toggle
        Scenario: Enable feature for user
          Given user "Alice" enables feature with debug "true"
          * check if user $p1 has admin rights
          * enable feature flag "true" for user $p1
          * set debug mode to "true"
          * send notification "false" to user $p1
          When configuration is saved
          Then feature should be enabled for "Alice"
      """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import static java.util.Arrays.stream;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.Boolean;
        import java.lang.String;
        import java.util.function.BiConsumer;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Feature Toggle
         */
        @DisplayName("FeatureToggle")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/FeatureToggle.feature")
        public class FeatureToggleTest extends FeatureToggle {
            protected void givenUser$p1EnablesFeatureWithDebug$p2(String p1, String p2,
                    BiConsumer<String, String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1, p2));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void givenCheckIfUser$p1HasAdminRights(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenEnableFeatureFlag$p1ForUser$p2(Boolean p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenSetDebugModeTo$p1(Boolean p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenSendNotification$p1ToUser$p2(Boolean p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenConfigurationIsSaved() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenFeatureShouldBeEnabledFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Enable feature for user")
            public void scenario_1() {
                /*
                 * Given user "Alice" enables feature with debug "true"
                 */
                givenUser$p1EnablesFeatureWithDebug$p2("Alice", "true", (p1, p2) -> {
                    givenCheckIfUser$p1HasAdminRights(p1);
                    givenEnableFeatureFlag$p1ForUser$p2(true, p1);
                    givenSetDebugModeTo$p1(true);
                    givenSendNotification$p1ToUser$p2(false, p1);
                });
                /*
                 * When configuration is saved
                 */
                whenConfigurationIsSaved();
                /*
                 * Then feature should be enabled for "Alice"
                 */
                thenFeatureShouldBeEnabledFor$p1("Alice");
            }
        }
        """

    Scenario: Composite step with sub-steps containing Double parameters
      Given the following base class:
      """
      package com.example;

      import dev.specbinder.annotations.Feature2JUnit;
      import dev.specbinder.annotations.Feature2JUnitOptions;

      @Feature2JUnit
      @Feature2JUnitOptions(enableCompositeSteps = true)
      public abstract class PricingEngine {

      }
      """
      And the following feature file:
      """
      Feature: Pricing Engine
        Scenario: Calculate discounted price
          Given customer "John" purchases item with price "99.99"
          * load product with price "99.99" from catalog
          * apply discount rate "0.15" for customer $p1
          * calculate tax with rate "8.5" on price "99.99"
          * round final price to "2" decimals
          When order is finalized
          Then customer "John" should see total price
      """
      When the generator is run
      Then the following class should be generated:
        """
        package com.example;

        import static java.util.Arrays.stream;

        import dev.specbinder.annotations.output.FeatureFilePath;
        import java.lang.Double;
        import java.lang.Integer;
        import java.lang.String;
        import java.util.function.BiConsumer;
        import javax.annotation.processing.Generated;
        import org.junit.jupiter.api.Assertions;
        import org.junit.jupiter.api.DisplayName;
        import org.junit.jupiter.api.MethodOrderer;
        import org.junit.jupiter.api.Order;
        import org.junit.jupiter.api.Test;
        import org.junit.jupiter.api.TestMethodOrder;

        /**
         * Feature: Pricing Engine
         */
        @DisplayName("PricingEngine")
        @Generated("dev.specbinder.feature2junit.Feature2JUnitGenerator")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @FeatureFilePath("com/example/PricingEngine.feature")
        public class PricingEngineTest extends PricingEngine {
            protected void givenCustomer$p1PurchasesItemWithPrice$p2(String p1, String p2,
                    BiConsumer<String, String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1, p2));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void givenLoadProductWithPrice$p1FromCatalog(Double p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenApplyDiscountRate$p1ForCustomer$p2(Double p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenCalculateTaxWithRate$p1OnPrice$p2(Double p1, Double p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void givenRoundFinalPriceTo$p1Decimals(Integer p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void whenOrderIsFinalized() {
                Assertions.fail("Step is not yet implemented");
            }

            public void thenCustomer$p1ShouldSeeTotalPrice(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Calculate discounted price")
            public void scenario_1() {
                /*
                 * Given customer "John" purchases item with price "99.99"
                 */
                givenCustomer$p1PurchasesItemWithPrice$p2("John", "99.99", (p1, p2) -> {
                    givenLoadProductWithPrice$p1FromCatalog(99.99);
                    givenApplyDiscountRate$p1ForCustomer$p2(0.15, p1);
                    givenCalculateTaxWithRate$p1OnPrice$p2(8.5, 99.99);
                    givenRoundFinalPriceTo$p1Decimals(2);
                });
                /*
                 * When order is finalized
                 */
                whenOrderIsFinalized();
                /*
                 * Then customer "John" should see total price
                 */
                thenCustomer$p1ShouldSeeTotalPrice("John");
            }
        }
        """


