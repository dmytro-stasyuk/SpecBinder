package dev.specbinder.processor.gherkin;

import io.cucumber.messages.types.Step;

import java.util.ArrayList;
import java.util.List;

/**
 * Represents a composite step pattern where a Given/When/Then/And/But step is followed by
 * one or more steps using the '*' keyword.
 */
class CompositeStepGroup {

    private final Step parentStep;
    private final List<Step> subSteps;

    public CompositeStepGroup(Step parentStep) {
        this.parentStep = parentStep;
        this.subSteps = new ArrayList<>();
    }

    public void addSubStep(Step subStep) {
        this.subSteps.add(subStep);
    }

    public Step getParentStep() {
        return parentStep;
    }

    public List<Step> getSubSteps() {
        return subSteps;
    }

    public boolean hasSubSteps() {
        return !subSteps.isEmpty();
    }

    public int size() {
        return 1 + subSteps.size();  // parent + sub-steps
    }
}
