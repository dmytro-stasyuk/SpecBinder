package dev.specbinder.feature2junit.steps;

import java.io.IOException;
import java.net.URI;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Comparator;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Stream;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TestOutputDirectoryManager {

    private static final Logger logger = LoggerFactory.getLogger(TestOutputDirectoryManager.class);
    private final String baseOutputDir;

    public TestOutputDirectoryManager(String baseOutputDir) {
        this.baseOutputDir = baseOutputDir;
    }
    
    public String getBaseOutputDir() {
        return baseOutputDir;
    }

    /**
     * Extracts the feature file path from a scenario URI.
     * 
     * @param scenarioUri the URI from the scenario
     * @return the extracted feature file path
     */
    public String extractFeatureFilePath(URI scenarioUri) {
        String fullPath = scenarioUri.toString();

        // Extract path after "classpath:" prefix for Cucumber URIs
        if (fullPath.startsWith("classpath:")) {
            return fullPath.substring("classpath:".length());
        } else {
            // Extract path after "src/test/resources/" for file URIs
            String marker = "src/test/resources/";
            int index = fullPath.indexOf(marker);
            if (index != -1) {
                return fullPath.substring(index + marker.length());
            } else {
                // Fallback to the full path
                return fullPath;
            }
        }
    }

    /**
     * Creates and clears the output directory structure based on the feature file path and scenario line number.
     * 
     * @param featureFilePath the path to the feature file
     * @param scenarioLineNumber the line number where the scenario starts
     * @return the path to the created output directory
     * @throws IOException if directory operations fail
     */
    public Path prepareOutputDirectory(String featureFilePath, int scenarioLineNumber) throws IOException {
        if (featureFilePath == null) {
            return null;
        }

        // Extract directory path and filename from feature file path
        Path featurePath = Paths.get(featureFilePath);
        Path featureDir = featurePath.getParent();
        String filename = featurePath.getFileName().toString();
        
        // Remove file extension from filename
        String filenameWithoutExtension = filename;
        int lastDotIndex = filename.lastIndexOf('.');
        if (lastDotIndex > 0) {
            filenameWithoutExtension = filename.substring(0, lastDotIndex);
        }
        
        // Build output directory path including filename without extension and scenario line number
        Path outputDir = Paths.get(baseOutputDir);
        if (featureDir != null) {
            outputDir = outputDir.resolve(featureDir);
        }
        outputDir = outputDir.resolve(filenameWithoutExtension);
        outputDir = outputDir.resolve("Scenario_line_" + scenarioLineNumber);
        
        // If directory exists, clear it completely
        if (Files.exists(outputDir)) {
            Files.walk(outputDir)
                .sorted(Comparator.reverseOrder())
                .forEach(path -> {
                    try {
                        Files.delete(path);
                    } catch (IOException e) {
                        throw new RuntimeException("Failed to delete: " + path, e);
                    }
                });
        }
        
        // Create the directory structure
        Files.createDirectories(outputDir);
        
        return outputDir;
    }

    /**
     * Clears the output directory for a specific feature file.
     * 
     * @param featureFilePath the path to the feature file
     * @throws IOException if directory operations fail
     */
    public void clearFeatureFileDirectory(String featureFilePath) throws IOException {
        // Extract the directory path from the feature file path
        Path featurePath = Paths.get(featureFilePath);
        Path featureDir = featurePath.getParent();
        
        // Build the output directory path for this feature file
        Path baseOutputDir = Paths.get(this.baseOutputDir);
        Path featureOutputDir = (featureDir != null) ? baseOutputDir.resolve(featureDir) : baseOutputDir;
        
        if (Files.exists(featureOutputDir)) {
            logger.info("Clearing feature file directory: {}", featureOutputDir);
            try (Stream<Path> paths = Files.walk(featureOutputDir)) {
                paths.sorted((a, b) -> b.compareTo(a)) // Delete files before directories
                     .filter(path -> !path.equals(featureOutputDir)) // Don't delete the directory itself
                     .forEach(path -> {
                         try {
                             Files.deleteIfExists(path);
                         } catch (IOException e) {
                             logger.warn("Failed to delete path: {}", path, e);
                         }
                     });
            }
        }
    }

    /**
     * Derives the feature file path from the provided base class information.
     * Returns the path if @Feature2JUnit annotation exists with no value or empty value.
     * 
     * @param baseClassContent the Java class content
     * @param baseClassName the class name
     * @param baseClassPackage the package name
     * @return the derived feature file path, or null if conditions are not met
     */
    public String deriveFeatureFilePathFromBaseClass(String baseClassContent, String baseClassName, String baseClassPackage) {
        if (baseClassContent == null || baseClassName == null) {
            return null;
        }
        
        // Check if @Feature2JUnit annotation exists and has no value or empty value
        if (!hasEmptyFeature2JUnitAnnotation(baseClassContent)) {
            return null;
        }
        
        // Build the feature file path: package/ClassName.feature
        StringBuilder pathBuilder = new StringBuilder();
        
        if (baseClassPackage != null && !baseClassPackage.isEmpty()) {
            pathBuilder.append(baseClassPackage.replace('.', '/'));
            pathBuilder.append('/');
        }
        
        pathBuilder.append(baseClassName);
        pathBuilder.append(".feature");
        
        return pathBuilder.toString();
    }
    
    /**
     * Checks if the class content contains a @Feature2JUnit annotation with no value or empty value.
     * 
     * @param classContent the Java class content
     * @return true if @Feature2JUnit exists with no value or empty value
     */
    private boolean hasEmptyFeature2JUnitAnnotation(String classContent) {
        // Pattern to match @Feature2JUnit with no parameters, empty parameters, or empty value
        Pattern pattern = Pattern.compile(
            "@Feature2JUnit\\s*(?:\\(\\s*\\)|\\(\\s*value\\s*=\\s*\"\"\\s*\\))?",
            Pattern.CASE_INSENSITIVE
        );
        
        Matcher matcher = pattern.matcher(classContent);
        return matcher.find();
    }
}
