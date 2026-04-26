package dev.specbinder.processor.gherkin.utils;

import io.cucumber.messages.types.*;

import java.util.ArrayList;
import java.util.List;

/**
 * Collects Background steps from a {@link Feature} and (optionally) an enclosing {@link Rule}
 * in the order JUnit's {@code @BeforeEach} methods execute them: feature-level Background first,
 * then rule-level Background.
 *
 * <p>Used by {@code ScenarioProcessor} to assemble the canonical step list for scenario-hash
 * computation when {@code emitScenarioHash} is enabled.
 */
public final class BackgroundStepCollector {

    private BackgroundStepCollector() {
    }

    /**
     * Returns all Background steps declared at the feature level.
     *
     * @param feature the parsed Feature node, or null
     * @return list of background steps (never null)
     */
    public static List<Step> collectFeatureBackgroundSteps(Feature feature) {
        List<Step> steps = new ArrayList<>();
        if (feature == null) {
            return steps;
        }
        for (FeatureChild child : feature.getChildren()) {
            if (child.getBackground().isPresent()) {
                Background background = child.getBackground().get();
                steps.addAll(background.getSteps());
            }
        }
        return steps;
    }

    /**
     * Returns all Background steps declared inside the given rule.
     *
     * @param rule the parsed Rule node, or null
     * @return list of background steps (never null)
     */
    public static List<Step> collectRuleBackgroundSteps(Rule rule) {
        List<Step> steps = new ArrayList<>();
        if (rule == null) {
            return steps;
        }
        for (RuleChild child : rule.getChildren()) {
            if (child.getBackground().isPresent()) {
                Background background = child.getBackground().get();
                steps.addAll(background.getSteps());
            }
        }
        return steps;
    }

    /**
     * Concatenates feature-level and rule-level background steps into a single list.
     *
     * @param featureBackgroundSteps feature-level background steps, or null
     * @param ruleBackgroundSteps    rule-level background steps, or null
     * @return combined list (never null)
     */
    public static List<Step> combine(List<Step> featureBackgroundSteps, List<Step> ruleBackgroundSteps) {
        List<Step> combined = new ArrayList<>(
                (featureBackgroundSteps == null ? 0 : featureBackgroundSteps.size())
                        + (ruleBackgroundSteps == null ? 0 : ruleBackgroundSteps.size()));
        if (featureBackgroundSteps != null) combined.addAll(featureBackgroundSteps);
        if (ruleBackgroundSteps != null) combined.addAll(ruleBackgroundSteps);
        return combined;
    }
}
