package dev.specbinder.examples.goingfurther.multipletests;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/** Spring Boot entry point for the browser-tested pricing application. */
@SpringBootApplication
public class PricingWebApplication {

    /** Creates the application class; Spring Boot instantiates it on startup. */
    public PricingWebApplication() {
    }

    /**
     * Starts the pricing web application.
     *
     * @param args command-line arguments, passed on to Spring Boot
     */
    public static void main(String[] args) {
        SpringApplication.run(PricingWebApplication.class, args);
    }
}
