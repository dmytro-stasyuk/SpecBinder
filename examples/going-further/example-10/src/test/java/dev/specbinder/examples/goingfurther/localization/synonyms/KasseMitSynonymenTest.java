package dev.specbinder.examples.goingfurther.localization.synonyms;

import dev.specbinder.examples.goingfurther.localization.Checkout;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class KasseMitSynonymenTest extends KasseMitSynonymenScenarios {

    private Checkout checkout;

    @Override
    public void einWarenkorbMit$p1Artikeln(Integer itemCount) {
        checkout = new Checkout(itemCount);
    }

    @Override
    public void ichMitKarteBezahle() {
        checkout.payByCard();
    }

    @Override
    public void hatDieBestellungDenStatus$p1(String expectedStatus) {
        assertEquals(expectedStatus, checkout.isPaid() ? "bezahlt" : "offen");
    }

    @Override
    public void derWarenkorbIstLeer() {
        assertEquals(0, checkout.itemCount());
    }
}
