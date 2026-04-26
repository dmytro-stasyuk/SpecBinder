package dev.specbinder.reporter.steps;

import dev.specbinder.reporter.ReportPathsTestSeam;
import io.cucumber.java.After;
import io.cucumber.java.Before;
import io.cucumber.java.Scenario;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import org.junit.platform.engine.discovery.DiscoverySelectors;
import org.junit.platform.launcher.Launcher;
import org.junit.platform.launcher.LauncherDiscoveryRequest;
import org.junit.platform.launcher.core.LauncherDiscoveryRequestBuilder;
import org.junit.platform.launcher.core.LauncherFactory;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

public class Steps {

    /** Subdirectory inside the scenario workspace where the listener writes its JSON. */
    private static final String REPORTS_SUBDIR = "specbinder-reports";

    private Path scenarioDir;
    private Path reportsDir;
    private final List<String> pendingSources = new ArrayList<>();
    private FixtureCompiler.Compiled compiledFixture;

    @Before
    public void prepareWorkspace(Scenario scenario) throws IOException {
        scenarioDir = ScenarioWorkspace.prepare(scenario);
        reportsDir = scenarioDir.resolve(REPORTS_SUBDIR);
        // Pin the listener's output to this scenario's workspace so the produced JSON
        // is logically grouped with its input feature/spec file.
        ReportPathsTestSeam.redirectReportsTo(reportsDir);
        pendingSources.clear();
        compiledFixture = null;
    }

    @After
    public void clearTestSeam() {
        ReportPathsTestSeam.clearRedirect();
    }

    @Given("a feature file under path {string} with the following content:")
    public void aFeatureFileUnderPathWithTheFollowingContent(String relativePath, String content) throws IOException {
        Path target = scenarioDir.resolve(relativePath);
        Files.createDirectories(target.getParent());
        Files.writeString(target, content);
    }

    @Given("the following SpecBinder marker class:")
    public void theFollowingSpecBinderMarkerClass(String source) {
        // Buffer the marker source; it will be compiled together with the generated
        // test class so the latter can extend it.
        pendingSources.add(source);
    }

    @Given("the following SpecBinder-generated test class:")
    public void theFollowingSpecBinderGeneratedTestClass(String source) throws IOException, ClassNotFoundException {
        pendingSources.add(source);
        compiledFixture = FixtureCompiler.compileAndLoad(List.copyOf(pendingSources), scenarioDir);
        pendingSources.clear();
    }

    @When("the test class is executed")
    public void theTestClassIsExecuted() {
        if (compiledFixture == null) {
            throw new IllegalStateException("no fixture has been compiled yet");
        }
        Launcher launcher = LauncherFactory.create();
        LauncherDiscoveryRequest request = LauncherDiscoveryRequestBuilder.request()
                .selectors(DiscoverySelectors.selectClass(compiledFixture.loadedClass))
                .build();
        launcher.execute(request);
    }

    @Then("the produced report at {string} should match:")
    public void theProducedReportShouldMatch(String relativePath, String expectedJson) throws IOException {
        Path reportFile = reportsDir.resolve(relativePath);
        if (!Files.exists(reportFile)) {
            throw new AssertionError("expected report file " + reportFile + " was not produced");
        }
        String actual = Files.readString(reportFile);
        JsonApprovals.assertMatches(expectedJson, actual);
    }

    @Then("no report file should be produced at {string}")
    public void noReportFileShouldBeProducedAt(String relativePath) {
        Path reportFile = reportsDir.resolve(relativePath);
        if (Files.exists(reportFile)) {
            throw new AssertionError("expected NO report file at " + reportFile
                    + ", but one was produced");
        }
    }
}
