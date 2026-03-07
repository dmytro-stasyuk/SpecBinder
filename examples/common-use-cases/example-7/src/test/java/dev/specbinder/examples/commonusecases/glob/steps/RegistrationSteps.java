package dev.specbinder.examples.commonusecases.glob.steps;

public interface RegistrationSteps {

    default void iAmOnTheRegistrationPage() {
        // TODO: Implement step
    }

    default void iRegisterWithEmail$p1AndPassword$p2(String email, String password) {
        // TODO: Implement step
    }

    default void myAccountShouldBeCreated() {
        // TODO: Implement step
    }

    default void iShouldReceiveAWelcomeEmail() {
        // TODO: Implement step
    }

    default void aUserWithEmail$p1AlreadyExists(String email) {
        // TODO: Implement step
    }
}
