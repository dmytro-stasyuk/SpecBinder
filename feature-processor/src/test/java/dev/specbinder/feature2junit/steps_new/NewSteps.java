package dev.specbinder.feature2junit.steps_new;

import io.cucumber.java.Before;
import io.cucumber.java.Scenario;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import org.junit.jupiter.api.Assertions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.tools.*;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.fail;

public class NewSteps {

    private static final Logger logger = LoggerFactory.getLogger(NewSteps.class);

    private final TestOutputDirectoryManager directoryManager = new TestOutputDirectoryManager("target/feature-tests-output");
    private static final Set<String> executedFeatureFiles = new HashSet<>();

    private Path currentOutputDirectory;
    private String lastBaseClassPackage;
    private String lastBaseClassName;
    private String lastBaseClassContent;
    private String compilationError;

    @Before
    public void beforeEach(Scenario scenario) throws IOException {
        // Capture feature file information
        if (scenario == null) {
            throw new IllegalArgumentException("Scenario cannot be null in Before hook");
        }

        logger.info("Executing Scenario: {}", scenario.getName());
        String currentFeatureFilePath = directoryManager.extractFeatureFilePath(scenario.getUri());

        // Clear the feature file's directory on first encounter
        if (currentFeatureFilePath != null && !executedFeatureFiles.contains(currentFeatureFilePath)) {
            directoryManager.clearFeatureFileDirectory(currentFeatureFilePath);
            executedFeatureFiles.add(currentFeatureFilePath);
        }

        int scenarioLineNumber = scenario.getLine();
        currentOutputDirectory = directoryManager.prepareOutputDirectory(currentFeatureFilePath, scenarioLineNumber);

        // Clear any previous compilation error
        compilationError = null;
    }

    @Given("the following base class:")
    public void the_following_base_class(String docString) throws IOException {

        // Parse package name
        String packageName = JavaSourceParser.extractPackageName(docString);

        // Parse class name
        String className = JavaSourceParser.extractClassName(docString);

        if (className == null) {
            throw new IllegalArgumentException("Could not extract class name from the provided class definition");
        }

        // Store base class information for potential use in subsequent steps
        lastBaseClassPackage = packageName;
        lastBaseClassName = className;
        lastBaseClassContent = docString;

        // Use the current output directory that was already prepared
        Path outputDir = currentOutputDirectory;

        // Add package directory structure if the package exists
        if (packageName != null && !packageName.isEmpty()) {
            String[] packageParts = packageName.split("\\.");
            for (String part : packageParts) {
                outputDir = outputDir.resolve(part);
            }
        }

        // Ensure directory exists
        Files.createDirectories(outputDir);

        // Create the Java file
        Path javaFile = outputDir.resolve(className + ".java");
        Files.write(javaFile, docString.getBytes());
    }


    @Given("the following feature file:")
    public void the_following_feature_file(String docString) throws IOException {

        // Derive the feature file path from the last base class
        String featureFilePath = directoryManager.deriveFeatureFilePathFromBaseClass(
                lastBaseClassContent, lastBaseClassName, lastBaseClassPackage);

        if (featureFilePath == null) {
            throw new IllegalStateException("Cannot derive feature file path. No base class information available or @Feature2JUnit annotation not found/has value.");
        }

        // Use the current output directory as the base
        Path outputDir = currentOutputDirectory;

        // Parse the path to extract directory structure and filename
        Path featurePath = Paths.get(featureFilePath);
        Path parentDir = featurePath.getParent();

        // Add any parent directories from the path
        if (parentDir != null) {
            outputDir = outputDir.resolve(parentDir);
        }

        // Ensure directory exists
        Files.createDirectories(outputDir);

        // Create the feature file
        String filename = featurePath.getFileName().toString();
        Path featureFile = outputDir.resolve(filename);
        Files.write(featureFile, docString.getBytes());
    }

    @Given("a feature file under path {string} with the following content:")
    public void a_feature_file_under_path_with_the_following_content(String path, String docString) throws IOException {

        // Use the current output directory as the base
        Path outputDir = currentOutputDirectory;

        // Parse the path to extract directory structure and filename
        Path featurePath = Paths.get(path);
        Path parentDir = featurePath.getParent();

        // Add any parent directories from the path
        if (parentDir != null) {
            outputDir = outputDir.resolve(parentDir);
        }

        // Ensure directory exists
        Files.createDirectories(outputDir);

        // Create the feature file
        String filename = featurePath.getFileName().toString();
        Path featureFile = outputDir.resolve(filename);
        Files.write(featureFile, docString.getBytes());
    }

    @When("the generator is run")
    public void the_generator_is_run() throws IOException {

        // Find all Java source files in the output directory
        List<Path> javaFiles = new ArrayList<>();
        try (Stream<Path> paths = Files.walk(currentOutputDirectory)) {
            paths.filter(Files::isRegularFile)
                    .filter(path -> path.toString().endsWith(".java"))
                    .forEach(javaFiles::add);
        }

        if (javaFiles.isEmpty()) {
            logger.warn("No Java source files found to compile in directory: {}", currentOutputDirectory);
            return; // No Java files to compile
        }

        // Get the Java compiler
        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        if (compiler == null) {
            throw new IllegalStateException("Java compiler not available. Ensure you're running with a JDK, not just a JRE.");
        }

        // Set up compilation
        DiagnosticCollector<JavaFileObject> diagnostics = new DiagnosticCollector<>();
        StandardJavaFileManager fileManager = compiler.getStandardFileManager(diagnostics, null, null);

        try {
            // Configure file manager locations to include the output directory for resources
            fileManager.setLocation(StandardLocation.CLASS_PATH,
                    List.of(currentOutputDirectory.toFile()));

            // Convert paths to file objects
            Iterable<? extends JavaFileObject> compilationUnits = fileManager.getJavaFileObjectsFromPaths(javaFiles);

            // Set compilation options
            List<String> options = new ArrayList<>();
            options.add("-d"); // Output directory for class files
            options.add(currentOutputDirectory.toString());
            options.add("-s"); // Output directory for generated source files
            options.add(currentOutputDirectory.toString());
            options.add("-cp"); // Classpath
            options.add(System.getProperty("java.class.path") + System.getProperty("path.separator") + currentOutputDirectory.toString());

            // Compile
            JavaCompiler.CompilationTask task = compiler.getTask(
                    null, // Writer for additional output
                    fileManager,
                    diagnostics,
                    options,
                    null, // Classes to process for annotations
                    compilationUnits
            );

            boolean success = task.call();

            // Log all diagnostics regardless of success/failure
            if (!diagnostics.getDiagnostics().isEmpty()) {
                logger.info("Compilation diagnostics:");
                diagnostics.getDiagnostics().forEach(diagnostic ->
                        logger.info("  " + diagnostic.toString())
                );
            }

            if (!success) {
                StringBuilder errorMessage = new StringBuilder("Compilation failed:\n");
                diagnostics.getDiagnostics().forEach(diagnostic ->
                        errorMessage.append(diagnostic.toString()).append("\n")
                );
                compilationError = errorMessage.toString();
            } else {
                logger.info("Compilation succeeded");
            }

        } catch (Exception e) {
            /**
             * Capture exception message as compilation error, strip the exception type from the start of the message
             * if present, as we only want the user-friendly message.
             */
            String message = e.getMessage();
            // Strip exception class name if present (format: "package.ClassName: message")
            if (message != null && message.contains("Exception: ")) {
                int colonIndex = message.indexOf("Exception: ");
                message = message.substring(colonIndex + "Exception: ".length());
            }
            compilationError = message;
        } finally {
            fileManager.close();
        }
    }


    @Then("the generator should report an error:")
    public void theGeneratorShouldReportAnError(String expectedErrorMessage) {

        if (compilationError == null) {
            fail("Expected compilation error but compilation succeeded");
        }

        // Check if the expected error message matches the actual error exactly
        Assertions.assertEquals(expectedErrorMessage.trim(), compilationError.trim(),
                "Expected error message does not match exactly");
    }

    @Then("the following class should be generated:")
    public void a_class_named_should_be_generated_with_content(String classContent) throws IOException {

        // Parse package name and class name from expected content
        String packageName = JavaSourceParser.extractPackageName(classContent);
        String className = JavaSourceParser.extractClassName(classContent);

        if (className == null) {
            throw new IllegalArgumentException("Could not extract class name from the expected class content");
        }

        // Build the path to the expected generated file
        Path expectedFilePath = currentOutputDirectory;

        // Add package directory structure if package exists
        if (packageName != null && !packageName.isEmpty()) {
            String[] packageParts = packageName.split("\\.");
            for (String part : packageParts) {
                expectedFilePath = expectedFilePath.resolve(part);
            }
        }

        // Add the class filename
        expectedFilePath = expectedFilePath.resolve(className + ".java");

        // Verify the file exists
        if (!Files.exists(expectedFilePath)) {
            // Check if there was a generator error that might explain why the file wasn't generated
            String errorMsg = "Expected generated class file not found at path:\n" + expectedFilePath;
            if (compilationError != null) {
                errorMsg += "\nCompilation error:\n" + compilationError;
            }
            fail(errorMsg);
        }

        // Read the actual generated content
        String actualContent = Files.readString(expectedFilePath);

        // Compare the content (normalize line endings and trim whitespace for cross-platform compatibility)
        String normalizedExpected = classContent.replaceAll("\\r\\n", "\n").replaceAll("\\r", "\n").trim();
        String normalizedActual = actualContent.replaceAll("\\r\\n", "\n").replaceAll("\\r", "\n").trim();

        Assertions.assertEquals(normalizedExpected, normalizedActual,
                "Generated class content does not match expected content for file: " + expectedFilePath);

        if (compilationError != null) {
            fail("Expected generated class file found, but there was a compilation error:\n" + compilationError);
        }
    }


    @Then("there should not be a class generated with name {string} in package {string}")
    public void thereShouldNotBeAClassGeneratedWithNameInPackage(String className, String packageName) {
        // Build the path to the file that should not exist
        Path expectedFilePath = currentOutputDirectory;

        // Add package directory structure if package exists
        if (packageName != null && !packageName.isEmpty()) {
            String[] packageParts = packageName.split("\\.");
            for (String part : packageParts) {
                expectedFilePath = expectedFilePath.resolve(part);
            }
        }

        // Add the class filename
        expectedFilePath = expectedFilePath.resolve(className + ".java");

        // Verify the file does NOT exist
        if (Files.exists(expectedFilePath)) {
            fail("Class " + className + " in package " + packageName +
                    " should not have been generated, but was found at: " + expectedFilePath);
        }
    }
}
