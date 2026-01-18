package dev.specbinder.examples.featureprocessor.steps;

public interface UserManagementSteps {

    default void givenTheAdminIsOnTheUserManagementPage() {
        // TODO: Implement step
    }

    default void whenTheAdminSearchesForUser$p1(String p1) {
        // TODO: Implement step
    }

    default void whenTheAdminClicksTheDeactivateButton() {
        // TODO: Implement step
    }

    default void whenTheAdminConfirmsTheDeactivation() {
        // TODO: Implement step
    }

    default void thenTheUserAccountShouldBeDeactivated() {
        // TODO: Implement step
    }

    default void thenTheUserShouldNoLongerBeAbleToLogIn() {
        // TODO: Implement step
    }
}
