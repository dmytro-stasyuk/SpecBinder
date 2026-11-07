package dev.specbinder.examples.goingfurther.localization;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class CaisseTest extends CaisseScenarios {

    private Checkout checkout;

    @Override
    public void unPanierAvec$p1Articles(Integer itemCount) {
        checkout = new Checkout(itemCount);
    }

    @Override
    public void jePaieParCarte() {
        checkout.payByCard();
    }

    @Override
    public void laCommandeALeStatut$p1(String expectedStatus) {
        assertEquals(expectedStatus, checkout.isPaid() ? "payée" : "en attente");
    }

    @Override
    public void lePanierEstVide() {
        assertEquals(0, checkout.itemCount());
    }
}
