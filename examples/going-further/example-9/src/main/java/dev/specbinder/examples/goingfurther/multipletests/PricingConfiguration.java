package dev.specbinder.examples.goingfurther.multipletests;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/** Shared application configuration for the bean and UI tests. */
@Configuration(proxyBeanMethods = false)
public class PricingConfiguration {

    /** Creates the configuration; Spring instantiates it when building the application context. */
    public PricingConfiguration() {
    }

    /**
     * Registers the pricing service as a bean.
     *
     * @return the pricing service shared by the application
     */
    @Bean
    public CartPricingService cartPricingService() {
        return new CartPricingService();
    }
}
