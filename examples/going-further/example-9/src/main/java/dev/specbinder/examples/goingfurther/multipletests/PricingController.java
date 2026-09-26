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

    public PricingController(CartPricingService pricing) {
        this.pricing = pricing;
    }

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
