package dev.specbinder.processor.utils;

import dev.specbinder.processor.exception.ProcessingException;
import io.cucumber.messages.types.*;

import java.util.List;

/**
 * Utility class using while working steps.
 */
public class FeatureStepUtils {

    private FeatureStepUtils() {
        /**
         * utility class
         */
    }

    /**
     * Checks if a feature contains any steps with data tables.
     * @param feature the feature to check
     * @return true if the feature contains at least one step with a data table, false otherwise
     */
    public static boolean featureHasStepWithDataTable(Feature feature) {

        List<FeatureChild> featureElements = feature.getChildren();

        for (FeatureChild featureElement : featureElements) {

            if (featureElement.getBackground().isPresent()) {

                Background featureBackground = featureElement.getBackground().get();
                List<Step> steps = featureBackground.getSteps();
                if (thereIsStepWithDataTable(steps))  {
                    return true;
                }

            } else if (featureElement.getRule().isPresent()) {

                Rule rule = featureElement.getRule().get();

                if (ruleHasStepWithDataTable(rule)) {
                    return true;
                }

            } else if (featureElement.getScenario().isPresent()) {

                Scenario scenario = featureElement.getScenario().get();
                List<Step> steps = scenario.getSteps();

                if (thereIsStepWithDataTable(steps))  {
                    return true;
                }

            } else {
                throw new ProcessingException("Unsupported child element type for feature: " + featureElement);
            }
        }

        return false;
    }

    /**
     * Checks if a rule contains any steps with data tables.
     * @param rule the rule to check
     * @return true if the rule contains at least one step with a data table, false otherwise
     */
    public static boolean ruleHasStepWithDataTable(Rule rule) {

        List<RuleChild> ruleElements = rule.getChildren();

        for (RuleChild ruleElement : ruleElements) {

            if (ruleElement.getBackground().isPresent()) {

                Background background = ruleElement.getBackground().get();
                List<Step> steps = background.getSteps();
                if (thereIsStepWithDataTable(steps))  {
                    return true;
                }

            } else if (ruleElement.getScenario().isPresent()) {

                Scenario scenario = ruleElement.getScenario().get();
                List<Step> steps = scenario.getSteps();

                if (thereIsStepWithDataTable(steps))  {
                    return true;
                }

            } else {
                throw new ProcessingException("Unsupported child element type for feature: " + ruleElement);
            }
        }

        return false;
    }

    private static boolean thereIsStepWithDataTable(List<Step> steps) {
        for (Step step : steps) {
            if (step.getDataTable().isPresent()) {
                return true;
            }
        }
        return false;
    }

}
