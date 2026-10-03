package dev.specbinder.examples.goingfurther.playwrighttrace;

import com.microsoft.playwright.Page;
import com.microsoft.playwright.assertions.PlaywrightAssertions;

import java.nio.file.Path;

/**
 * Concrete test class implementing the CartTrace steps. Each step drives a real browser against
 * the bundled {@code web/cart.html} page, so every step produces browser activity worth tracing.
 */
public class CartTraceTest extends CartTraceScenarios {

    private static final String CART_PAGE =
            Path.of("src/test/resources/web/cart.html").toAbsolutePath().toUri().toString();

    private Page page() {
        return PlaywrightTracing.page();
    }

    @Override
    public void iOpenTheCartPage() {
        page().navigate(CART_PAGE);
    }

    @Override
    public void iAdd$p1ToTheCart(String item) {
        page().click("[data-add='" + item + "']");
    }

    @Override
    public void iClearTheCart() {
        page().click("#clear");
    }

    @Override
    public void theCartTotalShouldBe$p1(Double expected) {
        // The page renders the total to two decimals; format to match rather than parse the DOM.
        PlaywrightAssertions.assertThat(page().locator("#total")).hasText(String.format("%.2f", expected));
    }
}
