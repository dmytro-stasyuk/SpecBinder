package dev.specbinder.examples.commonusecases.glob.user;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Concrete test for Registration.specb, placed next to it. The generated
 * RegistrationScenarios lands in this package because the glob found the spec here.
 */
public class RegistrationTest extends RegistrationScenarios {

    private final Set<String> accounts = new HashSet<>();
    private final List<String> welcomeEmailsSent = new ArrayList<>();
    private String registeredEmail;
    private String message;

    @Override
    public void iAmOnTheRegistrationPage() {
    }

    @Override
    public void aUserWithEmail$p1AlreadyExists(String email) {
        accounts.add(email);
    }

    @Override
    public void iRegisterWithEmail$p1AndPassword$p2(String email, String password) {
        if (!accounts.add(email)) {
            message = "Email already in use";
            return;
        }
        registeredEmail = email;
        welcomeEmailsSent.add(email);
    }

    @Override
    public void myAccountShouldBeCreated() {
        assertTrue(accounts.contains(registeredEmail), "No account was created");
    }

    @Override
    public void iShouldReceiveAWelcomeEmail() {
        assertEquals(List.of(registeredEmail), welcomeEmailsSent);
    }

    @Override
    public void iShouldSee$p1(String expectedMessage) {
        assertEquals(expectedMessage, message);
    }
}
