package dev.specbinder.examples.goingfurther.multipletests;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/** Spring Boot entry point for the browser-tested pricing application. */
@SpringBootApplication
public class PricingWebApplication {

    public static void main(String[] args) {
        SpringApplication.run(PricingWebApplication.class, args);
    }
}
