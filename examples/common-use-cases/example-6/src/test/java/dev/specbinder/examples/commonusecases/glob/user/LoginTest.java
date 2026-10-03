package dev.specbinder.examples.commonusecases.glob.user;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Concrete test for Login.specb, placed next to it. The generated
 * LoginScenarios lands in this package because the glob found the spec here.
 */
public class LoginTest extends LoginScenarios {

    private static final Map<String, String> REGISTERED_ACCOUNTS = Map.of("alice@example.com", "secret123");

    private String currentPage;
    private String username;
    private String password;
    private String message;

    @Override
    public void iAmOnTheLoginPage() {
        currentPage = "login";
    }

    @Override
    public void iEnterUsername$p1(String username) {
        this.username = username;
    }

    @Override
    public void iEnterPassword$p1(String password) {
        this.password = password;
    }

    @Override
    public void iClickTheLoginButton() {
        if (password.equals(REGISTERED_ACCOUNTS.get(username))) {
            currentPage = "dashboard";
        } else {
            message = "Invalid credentials";
        }
    }

    @Override
    public void iShouldBeRedirectedToTheDashboard() {
        assertEquals("dashboard", currentPage);
    }

    @Override
    public void iShouldSee$p1(String expectedMessage) {
        assertEquals(expectedMessage, message);
    }
}
