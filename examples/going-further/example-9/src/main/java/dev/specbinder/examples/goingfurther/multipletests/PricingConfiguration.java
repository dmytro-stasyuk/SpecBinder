package dev.specbinder.examples.goingfurther.multipletests;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/** Shared application configuration for the bean and UI tests. */
@Configuration(proxyBeanMethods = false)
public class PricingConfiguration {

    @Bean
    public CartPricingService cartPricingService() {
        return new CartPricingService();
    }
}
