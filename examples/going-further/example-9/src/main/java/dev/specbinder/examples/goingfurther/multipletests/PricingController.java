package dev.specbinder.examples.goingfurther.multipletests;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.math.BigDecimal;

/** Handles the cart form and delegates pricing to the same service used by the other test layers. */
@Controller
public final class PricingController {

    private final CartPricingService pricing;

    /**
     * Creates the controller.
     *
     * @param pricing the service that calculates cart totals
     */
    public PricingController(CartPricingService pricing) {
        this.pricing = pricing;
    }

    /**
     * Calculates the total for the submitted cart form and renders it.
     *
     * @param quantity  number of items in the cart
     * @param unitPrice price of a single item
     * @param discount  discount to apply, in percent
     * @param model     model the submitted values and the calculated total are added to
     * @return the name of the view that shows the total
     */
    @PostMapping("/total")
    public String total(@RequestParam("quantity") int quantity,
                        @RequestParam("unitPrice") BigDecimal unitPrice,
                        @RequestParam("discount") int discount,
                        Model model) {
        model.addAttribute("quantity", quantity);
        model.addAttribute("unitPrice", unitPrice.toPlainString());
        model.addAttribute("discount", discount);
        model.addAttribute("total", pricing.total(quantity, unitPrice, discount).toPlainString());
        return "total";
    }
}
