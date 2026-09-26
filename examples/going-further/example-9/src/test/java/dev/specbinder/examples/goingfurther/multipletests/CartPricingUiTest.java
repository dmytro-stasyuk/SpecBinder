package dev.specbinder.examples.goingfurther.multipletests;

import com.microsoft.playwright.Browser;
import com.microsoft.playwright.BrowserContext;
import com.microsoft.playwright.Page;
import com.microsoft.playwright.Playwright;
import org.junit.jupiter.api.*;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.context.ConfigurableApplicationContext;
import specs.CartPricingScenarios;

import static com.microsoft.playwright.assertions.PlaywrightAssertions.assertThat;

@Tag("ui")
public class CartPricingUiTest extends CartPricingScenarios {

    private static ConfigurableApplicationContext application;
    private static String baseUrl;
    private static Playwright playwright;
    private static Browser browser;
    private BrowserContext browserContext;
    private Page page;

    @BeforeAll
    static void startApplicationAndBrowser() {
        application = new SpringApplicationBuilder(PricingWebApplication.class)
                .properties("server.address=127.0.0.1", "server.port=0", "spring.main.banner-mode=off")
                .run();
        baseUrl = "http://127.0.0.1:"
                + application.getEnvironment().getRequiredProperty("local.server.port");
        playwright = Playwright.create();
        browser = playwright.chromium().launch();
    }

    @BeforeEach
    void openCart() {
        // A fresh browser context isolates cookies and page state for each scenario.
        browserContext = browser.newContext();
        page = browserContext.newPage();
        page.navigate(baseUrl);
    }

    @AfterEach
    void closeCart() {
        if (browserContext != null) browserContext.close();
    }

    @AfterAll
    static void stopApplicationAndBrowser() {
        try {
            if (playwright != null) playwright.close();
        } finally {
            if (application != null) application.close();
        }
    }

    @Override
    public void aCartHolding$p1ItemsPriced$p2(Integer quantity, String unitPrice) {
        page.getByLabel("Quantity").fill(quantity.toString());
        page.getByLabel("Unit price").fill(unitPrice);
    }

    @Override
    public void aDiscountOf$p1PercentIsApplied(Integer percent) {
        page.getByLabel("Discount (%)").fill(percent.toString());
    }

    @Override
    public void theCartTotalShouldBe$p1(String expected) {
        page.getByText("Calculate total", new Page.GetByTextOptions().setExact(true)).click();
        assertThat(page.getByLabel("Cart total")).hasText(expected);
    }
}
