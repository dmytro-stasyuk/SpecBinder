package dev.specbinder.processor.gherkin;

import dev.specbinder.processor.config.GeneratorOptions;
import dev.specbinder.processor.exception.ProcessingException;
import dev.specbinder.processor.support.LoggingSupport;
import io.cucumber.gherkin.GherkinParser;
import io.cucumber.messages.types.Envelope;
import io.cucumber.messages.types.Feature;
import io.cucumber.messages.types.GherkinDocument;

import javax.annotation.processing.Filer;
import javax.annotation.processing.ProcessingEnvironment;
import javax.tools.FileObject;
import javax.tools.StandardLocation;
import java.io.ByteArrayInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Optional;
import java.util.stream.Stream;

/**
 * Parses a Gherkin feature file and extracts the Feature object.
 */
public class FeatureFileParser implements LoggingSupport {

    private final ProcessingEnvironment processingEnv;
    private GherkinParser gherkinParser;

    /**
     * Creates a FeatureFileParser instance.
     *
     * @param processingEnv the processing environment used to access the file system
     */
    public FeatureFileParser(ProcessingEnvironment processingEnv) {

        this.processingEnv = processingEnv;

        gherkinParser = GherkinParser.builder().includePickles(false).build();
    }

    public ProcessingEnvironment getProcessingEnv() {
        return processingEnv;
    }

    /**
     * Parses a Gherkin feature file using the provided file path and returns the Feature object.
     *
     * <p>Options are passed in per call rather than held as a field because they are resolved per
     * annotated element (and are inheritable), while this parser is constructed once.
     *
     * @param featureFilePath the path to the feature file, relative to the classpath
     * @param options         the resolved generator options for the annotated class
     * @return the Feature object extracted from the Gherkin document
     * @throws IOException if an error occurs while reading the file or parsing the Gherkin document
     */
    public Feature parseUsingPath(String featureFilePath, GeneratorOptions options) throws IOException {

        String fileContent = loadFileContent(featureFilePath);

        SpecTextStripper textStripper = SpecTextStripper.from(options);
        boolean textWasStripped = textStripper.isEnabled();
        if (textWasStripped) {
            fileContent = textStripper.strip(fileContent);
        }

        InputStream inputStream = new ByteArrayInputStream(fileContent.getBytes(StandardCharsets.UTF_8));

        Stream<Envelope> envelopeStream = gherkinParser.parse(featureFilePath, inputStream);

        Optional<Envelope> gherkinDocEnvelope = envelopeStream.filter(
                envelope -> envelope.getGherkinDocument().isPresent()
        ).findFirst();
        if (gherkinDocEnvelope.isPresent()
                && gherkinDocEnvelope.get().getGherkinDocument().isPresent()
                && gherkinDocEnvelope.get().getGherkinDocument().get().getFeature().isPresent()
        ) {
            GherkinDocument gherkinDocument = gherkinDocEnvelope.get().getGherkinDocument().get();
            Feature feature = gherkinDocument.getFeature().orElse(null);
            return feature;
        } else {
            String strippedHint = textWasStripped
                    ? " (text was stripped from this file before parsing - check that a stripPatterns or"
                    + " stripBetweenPatterns match has not removed a Feature, Rule or Scenario line)"
                    : "";
            throw new ProcessingException(
                    "Unable to parse Feature from the specified gherkin document: " + featureFilePath + strippedHint);
        }
    }

    String loadFileContent(String featureFilePath) throws IOException {

//        logWarning("Loading feature file, featureFilePath = '" + featureFilePath + "'");

        Filer filer = processingEnv.getFiler();
        try {

            FileObject specFile = null;
//            try {
//                specFile = filer.getResource(StandardLocation.SOURCE_PATH, "", featureFilePath);
//                logWarning("Found feature file in SOURCE_PATH: " + featureFilePath);
//            } catch (FileNotFoundException e) {
//                // silently ignore this attempted location
//                logWarning("Could not find feature file in SOURCE_PATH: " + featureFilePath);
//            }
//            if (specFile == null) {
//                try {
//                    specFile = filer.getResource(StandardLocation.SOURCE_OUTPUT, "", featureFilePath);
//                    logWarning("Found feature file in SOURCE_OUTPUT: " + featureFilePath);
//                } catch (FileNotFoundException e) {
//                    // silently ignore this attempted location
//                    logWarning("Could not find feature file in SOURCE_OUTPUT: " + featureFilePath);
//                }
//            }
//            if (specFile == null) {
//                try {
//                    specFile = filer.getResource(StandardLocation.CLASS_OUTPUT, "", featureFilePath);
//                    logWarning("Found feature file in CLASS_OUTPUT: " + featureFilePath);
//                } catch (FileNotFoundException e) {
//                    // silently ignore this attempted location
//                    logWarning("Could not find feature file in CLASS_OUTPUT: " + featureFilePath);
//                }
//            }

//            if (specFile == null) {
            // works from IDE & maven lifecycle build goal
            specFile = filer.getResource(StandardLocation.CLASS_PATH, "", featureFilePath);
//            logWarning("Found feature file in CLASS_PATH: " + featureFilePath);
//            }

//            logWarning("Reading feature file content from: " + specFile.toUri());
            CharSequence charContent = specFile.getCharContent(false);
            String featureContent = charContent.toString();

            return featureContent;

        } catch (FileNotFoundException e) {
            logWarning("Could not find feature file in CLASS_PATH: " + featureFilePath);
            throw e;
        }
    }
}