package dev.specbinder.processor.reporting;

import io.cucumber.plugin.ConcurrentEventListener;
import io.cucumber.plugin.event.*;

/**
 * A Cucumber plugin that provides detailed step reporting compatible with IntelliJ IDEA.
 * This plugin formats step output in a way that IntelliJ can parse and display in the test tree.
 *
 * While individual steps won't appear as separate tree nodes (this is a JUnit Platform Engine limitation),
 * this reporter uses special formatting that IntelliJ recognizes for better visibility.
 */
public class DetailedStepReporter implements ConcurrentEventListener {

    private static final String TEAMCITY_TEST_STARTED = "##teamcity[testStarted name='%s' locationHint='%s']";
    private static final String TEAMCITY_TEST_FINISHED = "##teamcity[testFinished name='%s' duration='%d']";
    private static final String TEAMCITY_TEST_FAILED = "##teamcity[testFailed name='%s' message='%s' details='%s']";

    @Override
    public void setEventPublisher(EventPublisher publisher) {
        publisher.registerHandlerFor(TestCaseStarted.class, this::handleTestCaseStarted);
        publisher.registerHandlerFor(TestStepStarted.class, this::handleTestStepStarted);
        publisher.registerHandlerFor(TestStepFinished.class, this::handleTestStepFinished);
        publisher.registerHandlerFor(TestCaseFinished.class, this::handleTestCaseFinished);
    }

    private void handleTestCaseStarted(TestCaseStarted event) {
        String scenarioName = event.getTestCase().getName();
        System.out.println("\n┌─ Scenario: " + scenarioName);
    }

    private void handleTestStepStarted(TestStepStarted event) {
        TestStep testStep = event.getTestStep();

        if (testStep instanceof PickleStepTestStep) {
            PickleStepTestStep pickleStep = (PickleStepTestStep) testStep;
            String stepText = pickleStep.getStep().getText();
            String keyword = pickleStep.getStep().getKeyword().trim();
            int line = pickleStep.getStep().getLine();

            // Format for IntelliJ using TeamCity service messages
            String stepName = keyword + " " + stepText;
            String location = pickleStep.getUri().toString() + ":" + line;

            System.out.println(String.format(TEAMCITY_TEST_STARTED,
                escape(stepName),
                escape(location)));
        }
    }

    private void handleTestStepFinished(TestStepFinished event) {
        TestStep testStep = event.getTestStep();

        if (testStep instanceof PickleStepTestStep) {
            PickleStepTestStep pickleStep = (PickleStepTestStep) testStep;
            String stepText = pickleStep.getStep().getText();
            String keyword = pickleStep.getStep().getKeyword().trim();
            String stepName = keyword + " " + stepText;

            Result result = event.getResult();
            long duration = result.getDuration() != null ? result.getDuration().toMillis() : 0;

            // Report result
            if (result.getStatus() == Status.FAILED) {
                String message = result.getError() != null ? result.getError().getMessage() : "Step failed";
                String details = result.getError() != null ? getStackTrace(result.getError()) : "";
                System.out.println(String.format(TEAMCITY_TEST_FAILED,
                    escape(stepName),
                    escape(message),
                    escape(details)));
            }

            System.out.println(String.format(TEAMCITY_TEST_FINISHED,
                escape(stepName),
                duration));

            // Visual indicator
            String statusSymbol = getStatusSymbol(result.getStatus());
            System.out.println("│  " + statusSymbol + " " + keyword + " " + stepText);
        }
    }

    private void handleTestCaseFinished(TestCaseFinished event) {
        System.out.println("└─");
    }

    private String getStatusSymbol(Status status) {
        switch (status) {
            case PASSED: return "✓";
            case FAILED: return "✗";
            case SKIPPED: return "○";
            case PENDING: return "⊝";
            case UNDEFINED: return "?";
            default: return "-";
        }
    }

    private String escape(String text) {
        if (text == null) return "";
        return text
            .replace("|", "||")
            .replace("'", "|'")
            .replace("\n", "|n")
            .replace("\r", "|r")
            .replace("[", "|[")
            .replace("]", "|]");
    }

    private String getStackTrace(Throwable error) {
        if (error == null) return "";
        StringBuilder sb = new StringBuilder();
        sb.append(error.toString()).append("\n");
        for (StackTraceElement element : error.getStackTrace()) {
            sb.append("  at ").append(element.toString()).append("\n");
        }
        return sb.toString();
    }
}
