package dev.specbinder.examples.featureprocessor.steps;

import org.junit.jupiter.api.Assertions;

public interface PasswordSteps {

    default void givenTheUserIsOnTheForgotPasswordPage() {
        // TODO: Implement step
    }

    default void whenTheUserEntersEmail$p1(String p1) {
        // TODO: Implement step
    }

    default void whenTheUserClicksTheResetPasswordButton() {
        // TODO: Implement step
    }

    default void thenAPasswordResetEmailShouldBeSent() {
        // TODO: Implement step
    }

    default void thenTheUserShouldSeeAConfirmationMessage() {
        // TODO: Implement step
    }
}
