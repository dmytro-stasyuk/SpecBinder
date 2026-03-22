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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/ProductCatalog.feature")
        public class ProductCatalogTest extends ProductCatalog {
            protected void userSearchesForProduct$p1(String p1, Consumer<String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void openSearchPage() {
                Assertions.fail("Step is not yet implemented");
            }

            public void enterSearchTerm$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void clickSearchButton() {
                Assertions.fail("Step is not yet implemented");
            }

            public void filterResultsByCategory() {
                Assertions.fail("Step is not yet implemented");
            }

            public void searchResultsAreDisplayed() {
                Assertions.fail("Step is not yet implemented");
            }

            public void product$p1ShouldBeFound(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Search for product")
            public void scenario_1() {
                /*
                 * Given user searches for product "Laptop"
                 */
                userSearchesForProduct$p1("Laptop", (p1) -> {
                    openSearchPage();
                    enterSearchTerm$p1("Laptop");
                    clickSearchButton();
                    filterResultsByCategory();
                });
                /*
                 * When search results are displayed
                 */
                searchResultsAreDisplayed();
                /*
                 * Then product "Laptop" should be found
                 */
                product$p1ShouldBeFound("Laptop");
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/UserManagement.feature")
        public class UserManagementTest extends UserManagement {
            protected void admin$p1WantsToCreateANewUser$p2(String p1, String p2,
                    BiConsumer<String, String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1, p2));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void navigateTo$p1Page(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void clickOn$p1Button(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void fillInUserDetailsFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void submitTheForm() {
                Assertions.fail("Step is not yet implemented");
            }

            public void verifyUser$p1IsCreated(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Create new user")
            public void scenario_1() {
                /*
                 * Given admin "Bob" wants to create a new user "Alex"
                 */
                admin$p1WantsToCreateANewUser$p2("Bob", "Alex", (p1, p2) -> {
                    navigateTo$p1Page("User Management");
                    clickOn$p1Button("Create User");
                    fillInUserDetailsFor$p1("Alex");
                    submitTheForm();
                    verifyUser$p1IsCreated("Alex");
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/BookingSystem.feature")
        public class BookingSystemTest extends BookingSystem {
            protected void customer$p1BooksRoom$p2ForDate$p3(String p1, String p2, String p3,
                    TriConsumer<String, String, String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1, p2, p3));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void verifyCustomer$p1HasValidAccount(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void checkRoom$p1IsAvailableOn$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void calculatePriceFor$p1On$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void reserveRoom$p1ForCustomer$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void sendConfirmationToCustomer$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void bookingIsProcessed() {
                Assertions.fail("Step is not yet implemented");
            }

            public void bookingShouldBeConfirmedFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Book hotel room")
            public void scenario_1() {
                /*
                 * Given customer "Sarah" books room "Deluxe Suite" for date "2024-12-25"
                 */
                customer$p1BooksRoom$p2ForDate$p3("Sarah", "Deluxe Suite", "2024-12-25", (p1, p2, p3) -> {
                    verifyCustomer$p1HasValidAccount(p1);
                    checkRoom$p1IsAvailableOn$p2(p2, p3);
                    calculatePriceFor$p1On$p2(p2, p3);
                    reserveRoom$p1ForCustomer$p2(p2, p1);
                    sendConfirmationToCustomer$p1(p1);
                });
                /*
                 * When booking is processed
                 */
                bookingIsProcessed();
                /*
                 * Then booking should be confirmed for "Sarah"
                 */
                bookingShouldBeConfirmedFor$p1("Sarah");
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/CustomerService.feature")
        public class CustomerServiceTest extends CustomerService {
            protected void customer$p1SubmitsASupportRequest(String p1, Consumer<String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void verifyCustomer$p1IsRegistered(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void createTicketForCustomer$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void assignAgentToCustomer$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void sendConfirmationTo$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void requestIsProcessed() {
                Assertions.fail("Step is not yet implemented");
            }

            public void customer$p1ShouldReceiveConfirmation(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Process customer request")
            public void scenario_1() {
                /*
                 * Given customer "Alice" submits a support request
                 */
                customer$p1SubmitsASupportRequest("Alice", (p1) -> {
                    verifyCustomer$p1IsRegistered(p1);
                    createTicketForCustomer$p1(p1);
                    assignAgentToCustomer$p1(p1);
                    sendConfirmationTo$p1(p1);
                });
                /*
                 * When request is processed
                 */
                requestIsProcessed();
                /*
                 * Then customer "Alice" should receive confirmation
                 */
                customer$p1ShouldReceiveConfirmation("Alice");
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/OrderProcessing.feature")
        public class OrderProcessingTest extends OrderProcessing {
            protected void customer$p1PlacesOrderFor$p2(String p1, String p2,
                    BiConsumer<String, String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1, p2));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void verifyCustomer$p1IsRegistered(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void checkProduct$p1IsAvailable(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void calculatePriceFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void createOrderForCustomer$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void orderIsSubmitted() {
                Assertions.fail("Step is not yet implemented");
            }

            public void orderShouldBeConfirmedFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Process customer order")
            public void scenario_1() {
                /*
                 * Given customer "John" places order for "Smartphone"
                 */
                customer$p1PlacesOrderFor$p2("John", "Smartphone", (p1, p2) -> {
                    verifyCustomer$p1IsRegistered(p1);
                    checkProduct$p1IsAvailable(p2);
                    calculatePriceFor$p1(p2);
                    createOrderForCustomer$p1(p1);
                });
                /*
                 * When order is submitted
                 */
                orderIsSubmitted();
                /*
                 * Then order should be confirmed for "John"
                 */
                orderShouldBeConfirmedFor$p1("John");
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

      import dev.specbinder.annotations.output.SourceFilePath;
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
      @Generated("dev.specbinder.processor.AnnotationProcessor")
      @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
      @SourceFilePath("com/example/TravelBooking.feature")
      public class TravelBookingTest extends TravelBooking {
          protected void traveler$p1BooksFlight$p2AndHotel$p3(String p1, String p2, String p3,
                  TriConsumer<String, String, String>... composite) {
              if (composite.length > 0) {
                  stream(composite).forEach(action -> action.accept(p1, p2, p3));
              } else {
                  Assertions.fail("Step is not yet implemented");
              }
          }

          public void verifyTraveler$p1HasValidPassport(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          public void checkFlight$p1AvailabilityOn$p2(String p1, String p2) {
              Assertions.fail("Step is not yet implemented");
          }

          public void checkHotel$p1AvailabilityOn$p2(String p1, String p2) {
              Assertions.fail("Step is not yet implemented");
          }

          public void reserveFlight$p1ForTraveler$p2(String p1, String p2) {
              Assertions.fail("Step is not yet implemented");
          }

          public void reserveHotel$p1ForTraveler$p2(String p1, String p2) {
              Assertions.fail("Step is not yet implemented");
          }

          public void bookingIsCompleted() {
              Assertions.fail("Step is not yet implemented");
          }

          public void bookingConfirmationShouldBeSentTo$p1(String p1) {
              Assertions.fail("Step is not yet implemented");
          }

          @Test
          @Order(1)
          @DisplayName("Scenario: Book flight and hotel")
          public void scenario_1() {
              /*
               * Given traveler "Emma" books flight "FL123" and hotel "Grand Hotel"
               */
              traveler$p1BooksFlight$p2AndHotel$p3("Emma", "FL123", "Grand Hotel", (p1, p2, p3) -> {
                  verifyTraveler$p1HasValidPassport(p1);
                  checkFlight$p1AvailabilityOn$p2(p2, p3);
                  checkHotel$p1AvailabilityOn$p2(p3, p3);
                  reserveFlight$p1ForTraveler$p2(p2, p1);
                  reserveHotel$p1ForTraveler$p2(p3, p1);
              });
              /*
               * When booking is completed
               */
              bookingIsCompleted();
              /*
               * Then booking confirmation should be sent to "Emma"
               */
              bookingConfirmationShouldBeSentTo$p1("Emma");
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/NotificationService.feature")
        public class NotificationServiceTest extends NotificationService {
            protected void user$p1ReceivesANotification(String p1, Consumer<String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void sendEmailTo$p1WithSubject$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void sendSmsTo$p1WithMessage$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void logNotificationSentTo$p1WithStatus$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void notificationIsDelivered() {
                Assertions.fail("Step is not yet implemented");
            }

            public void user$p1ShouldBeNotified(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Send notification to user")
            public void scenario_1() {
                /*
                 * Given user "Bob" receives a notification
                 */
                user$p1ReceivesANotification("Bob", (p1) -> {
                    sendEmailTo$p1WithSubject$p2(p1, "Welcome");
                    sendSmsTo$p1WithMessage$p2(p1, "Thank you");
                    logNotificationSentTo$p1WithStatus$p2(p1, "Success");
                });
                /*
                 * When notification is delivered
                 */
                notificationIsDelivered();
                /*
                 * Then user "Bob" should be notified
                 */
                user$p1ShouldBeNotified("Bob");
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/PaymentProcessing.feature")
        public class PaymentProcessingTest extends PaymentProcessing {
            protected void customer$p1MakesPaymentOf$p2(String p1, String p2,
                    BiConsumer<String, String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1, p2));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void validateCustomer$p1WithMethod$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void chargeAmount$p1ToCustomer$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void sendReceiptTo$p1WithAmount$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void sendReceipt$p1To$p2(Integer p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void logTransactionFor$p1WithStatus$p2(String p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void paymentIsProcessed() {
                Assertions.fail("Step is not yet implemented");
            }

            public void paymentShouldBeConfirmedFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Process payment for customer")
            public void scenario_1() {
                /*
                 * Given customer "Alice" makes payment of "100.00"
                 */
                customer$p1MakesPaymentOf$p2("Alice", "100.00", (p1, p2) -> {
                    validateCustomer$p1WithMethod$p2(p1, "Credit Card");
                    chargeAmount$p1ToCustomer$p2(p2, p1);
                    sendReceiptTo$p1WithAmount$p2(p1, p2);
                    sendReceipt$p1To$p2(120, p1);
                    logTransactionFor$p1WithStatus$p2(p1, "Completed");
                });
                /*
                 * When payment is processed
                 */
                paymentIsProcessed();
                /*
                 * Then payment should be confirmed for "Alice"
                 */
                paymentShouldBeConfirmedFor$p1("Alice");
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/DataProcessing.feature")
        public class DataProcessingTest extends DataProcessing {
            protected void user$p1ProcessesDatasetWithId$p2(String p1, String p2,
                    BiConsumer<String, String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1, p2));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void loadDataset$p1FromStorage(Long p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void validateUser$p1HasAccessToDataset$p2(String p1, Long p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void calculateChecksumForDataset$p1(Long p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void processingIsComplete() {
                Assertions.fail("Step is not yet implemented");
            }

            public void user$p1ShouldSeeResults(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Process large dataset")
            public void scenario_1() {
                /*
                 * Given user "Bob" processes dataset with ID "999999999999"
                 */
                user$p1ProcessesDatasetWithId$p2("Bob", "999999999999", (p1, p2) -> {
                    loadDataset$p1FromStorage(999999999999L);
                    validateUser$p1HasAccessToDataset$p2(p1, 999999999999L);
                    calculateChecksumForDataset$p1(999999999999L);
                });
                /*
                 * When processing is complete
                 */
                processingIsComplete();
                /*
                 * Then user "Bob" should see results
                 */
                user$p1ShouldSeeResults("Bob");
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/FeatureToggle.feature")
        public class FeatureToggleTest extends FeatureToggle {
            protected void user$p1EnablesFeatureWithDebug$p2(String p1, String p2,
                    BiConsumer<String, String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1, p2));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void checkIfUser$p1HasAdminRights(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void enableFeatureFlag$p1ForUser$p2(Boolean p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void setDebugModeTo$p1(Boolean p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void sendNotification$p1ToUser$p2(Boolean p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void configurationIsSaved() {
                Assertions.fail("Step is not yet implemented");
            }

            public void featureShouldBeEnabledFor$p1(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Enable feature for user")
            public void scenario_1() {
                /*
                 * Given user "Alice" enables feature with debug "true"
                 */
                user$p1EnablesFeatureWithDebug$p2("Alice", "true", (p1, p2) -> {
                    checkIfUser$p1HasAdminRights(p1);
                    enableFeatureFlag$p1ForUser$p2(true, p1);
                    setDebugModeTo$p1(true);
                    sendNotification$p1ToUser$p2(false, p1);
                });
                /*
                 * When configuration is saved
                 */
                configurationIsSaved();
                /*
                 * Then feature should be enabled for "Alice"
                 */
                featureShouldBeEnabledFor$p1("Alice");
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

        import dev.specbinder.annotations.output.SourceFilePath;
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
        @Generated("dev.specbinder.processor.AnnotationProcessor")
        @TestMethodOrder(MethodOrderer.OrderAnnotation.class)
        @SourceFilePath("com/example/PricingEngine.feature")
        public class PricingEngineTest extends PricingEngine {
            protected void customer$p1PurchasesItemWithPrice$p2(String p1, String p2,
                    BiConsumer<String, String>... composite) {
                if (composite.length > 0) {
                    stream(composite).forEach(action -> action.accept(p1, p2));
                } else {
                    Assertions.fail("Step is not yet implemented");
                }
            }

            public void loadProductWithPrice$p1FromCatalog(Double p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void applyDiscountRate$p1ForCustomer$p2(Double p1, String p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void calculateTaxWithRate$p1OnPrice$p2(Double p1, Double p2) {
                Assertions.fail("Step is not yet implemented");
            }

            public void roundFinalPriceTo$p1Decimals(Integer p1) {
                Assertions.fail("Step is not yet implemented");
            }

            public void orderIsFinalized() {
                Assertions.fail("Step is not yet implemented");
            }

            public void customer$p1ShouldSeeTotalPrice(String p1) {
                Assertions.fail("Step is not yet implemented");
            }

            @Test
            @Order(1)
            @DisplayName("Scenario: Calculate discounted price")
            public void scenario_1() {
                /*
                 * Given customer "John" purchases item with price "99.99"
                 */
                customer$p1PurchasesItemWithPrice$p2("John", "99.99", (p1, p2) -> {
                    loadProductWithPrice$p1FromCatalog(99.99);
                    applyDiscountRate$p1ForCustomer$p2(0.15, p1);
                    calculateTaxWithRate$p1OnPrice$p2(8.5, 99.99);
                    roundFinalPriceTo$p1Decimals(2);
                });
                /*
                 * When order is finalized
                 */
                orderIsFinalized();
                /*
                 * Then customer "John" should see total price
                 */
                customer$p1ShouldSeeTotalPrice("John");
            }
        }
        """


