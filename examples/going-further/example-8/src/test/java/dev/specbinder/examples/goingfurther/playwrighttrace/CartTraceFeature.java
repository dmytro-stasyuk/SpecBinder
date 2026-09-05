package dev.specbinder.examples.goingfurther.playwrighttrace;

import com.microsoft.playwright.Page;
import com.microsoft.playwright.assertions.PlaywrightAssertions;
import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.annotations.Gherkin2JUnitOptions;
import dev.specbinder.reporter.SpecBinderReporter;
import org.junit.jupiter.api.extension.ExtendWith;

import java.nio.file.Path;

/**
 * Marker class for the CartTrace spec, with its step methods implemented inline. Each step drives a
 * real browser against the bundled {@code web/cart.html} page, so every step produces browser
 * activity worth tracing.
 * <p>
 * Two extensions, in this order:
 * <ul>
 *     <li>{@link SpecBinderReporter} — writes the JSON execution report, and raises the execution
 *     boundaries the trace listener subscribes to.</li>
 *     <li>{@link PlaywrightTracing} — owns the browser and registers that listener.</li>
 * </ul>
 * Both are {@code @Inherited}, so putting them on this abstract marker covers every generated
 * {@code …Scenarios} subclass that JUnit actually runs.
 * <p>
 * {@code shouldBeAbstract = false} is the only generation option set: every step is implemented
 * right here, so the generated {@code CartTraceScenarios} can be concrete and directly runnable
 * rather than needing a hand-written subclass. Nothing about tracing depends on it — the per-step
 * trace paths ride on the report's published-entry mechanism, and {@code emitScenarioHash}, which
 * also gives the report each step's verbatim Gherkin text, is on by default.
 */
@Gherkin2JUnit("specs/CartTrace.specb")
@Gherkin2JUnitOptions(shouldBeAbstract = false)
@ExtendWith({SpecBinderReporter.class, PlaywrightTracing.class})
public abstract class CartTraceFeature {

    private static final String CART_PAGE =
            Path.of("src/test/resources/web/cart.html").toAbsolutePath().toUri().toString();

    private Page page() {
        return PlaywrightTracing.page();
    }

    public void iOpenTheCartPage() {
        page().navigate(CART_PAGE);
    }

    public void iAdd$p1ToTheCart(String item) {
        page().click("[data-add='" + item + "']");
    }

    public void iClearTheCart() {
        page().click("#clear");
    }

    public void theCartTotalShouldBe$p1(Double expected) {
        // The page renders the total to two decimals; format to match rather than parse the DOM.
        PlaywrightAssertions.assertThat(page().locator("#total")).hasText(String.format("%.2f", expected));
    }
}
