package dev.specbinder.processor.reporting;

import com.fasterxml.jackson.core.util.DefaultPrettyPrinter;
import com.fasterxml.jackson.core.util.Separators;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import io.cucumber.plugin.ConcurrentEventListener;
import io.cucumber.plugin.event.EventPublisher;
import io.cucumber.plugin.event.TestRunFinished;

import java.io.FileWriter;
import java.io.Writer;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * A Cucumber plugin that generates pretty-printed JSON reports by post-processing
 * the standard Cucumber JSON output.
 * <p>
 * This plugin works in tandem with the standard 'json' plugin. You must specify both:
 * - json:target/cucumber-report/report.json (creates the standard JSON)
 * - dev.specbinder.processor.reporting.PrettyJsonPlugin:target/cucumber-report/report.json (pretty-prints it)
 * <p>
 * The PrettyJsonPlugin reads the standard JSON file after the test run finishes and
 * rewrites it with pretty-printing (indentation, proper spacing).
 * <p>
 * Usage example:
 *
 * @ConfigurationParameter( key = Constants.PLUGIN_PROPERTY_NAME,
 * value = "json:target/report.json, dev.specbinder.processor.reporting.PrettyJsonPlugin:target/report.json"
 * )
 */
public class PrettyJsonPlugin implements ConcurrentEventListener {

    private final String outputPath;

    public PrettyJsonPlugin(String outputPath) {
        this.outputPath = outputPath;
    }

    @Override
    public void setEventPublisher(EventPublisher publisher) {
        // Listen for the test run finish to post-process the JSON
        publisher.registerHandlerFor(TestRunFinished.class, this::handleTestRunFinished);

        //publisher.registerHandlerFor(TestRunStarted.class, this::handleTestRunStarted);
        //publisher.registerHandlerFor(TestSourceRead.class, this::handleTestSourceRead);
        //publisher.registerHandlerFor(TestCaseStarted.class, this::handleTestCaseStarted);
        //publisher.registerHandlerFor(TestCaseFinished.class, this::handleTestCaseFinished);
    }

    //private void handleTestCaseFinished(TestCaseFinished testCaseFinished) {
    //
    //    System.out.println("PrettyJsonPlugin: Finished test case: " + testCaseFinished.getTestCase().getName());
    //}
    //
    //private void handleTestCaseStarted(TestCaseStarted testCaseStarted) {
    //
    //    System.out.println("PrettyJsonPlugin: Starting test case: " + testCaseStarted.getTestCase().getName());
    //}
    //
    //private void handleTestSourceRead(TestSourceRead testSourceRead) {
    //
    //    System.out.println("PrettyJsonPlugin: Reading source: " + testSourceRead.getUri());
    //}
    //
    //private void handleTestRunStarted(TestRunStarted testRunStarted) {
    //
    //    System.out.println("PrettyJsonPlugin: Starting test run, will output pretty JSON to " + outputPath);
    //}

    private void handleTestRunFinished(TestRunFinished event) {
        try {
            // Wait a moment for the standard JSON plugin to finish writing
            Thread.sleep(500);

            Path jsonPath = Paths.get(outputPath);

            // Check if the standard JSON file exists
            if (!Files.exists(jsonPath)) {
                System.err.println("PrettyJsonPlugin: JSON file not found at " + outputPath);
                System.err.println("Make sure to configure the standard 'json' plugin before this plugin");
                return;
            }

            // Read the standard JSON output
            String jsonContent = new String(Files.readAllBytes(jsonPath));

            if (jsonContent.trim().isEmpty()) {
                System.err.println("PrettyJsonPlugin: JSON file is empty, skipping pretty-print");
                return;
            }

            // Parse and reformat with pretty printing
            ObjectMapper mapper = new ObjectMapper();
            mapper.enable(SerializationFeature.INDENT_OUTPUT);

            // Configure custom formatting: no space before colon, space after
            Separators customSeparators = Separators.createDefaultInstance()
                    .withObjectFieldValueSpacing(Separators.Spacing.AFTER);

            DefaultPrettyPrinter printer = new DefaultPrettyPrinter()
                    .withArrayIndenter(com.fasterxml.jackson.core.util.DefaultIndenter.SYSTEM_LINEFEED_INSTANCE)
                    .withObjectIndenter(com.fasterxml.jackson.core.util.DefaultIndenter.SYSTEM_LINEFEED_INSTANCE)
                    .withSeparators(customSeparators);

            mapper.setDefaultPrettyPrinter(printer);

            // Parse the JSON (preserves all data from standard formatter)
            Object jsonObject = mapper.readValue(jsonContent, Object.class);

            // Write pretty-printed JSON back to the same file
            try (Writer writer = new FileWriter(jsonPath.toFile())) {
                mapper.writeValue(writer, jsonObject);
            }

            System.out.println("PrettyJsonPlugin: Successfully pretty-printed JSON to " + outputPath);

        } catch (Exception e) {
            System.err.println("PrettyJsonPlugin: Failed to pretty-print JSON report: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
