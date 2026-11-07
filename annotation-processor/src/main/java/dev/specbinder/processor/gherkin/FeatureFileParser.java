package dev.specbinder.processor.gherkin;

import dev.specbinder.processor.config.GeneratorOptions;
import dev.specbinder.processor.exception.ProcessingException;
import dev.specbinder.processor.support.LoggingSupport;
import dev.specbinder.specreader.SpecKeywords;
import dev.specbinder.specreader.SpecParser;
import dev.specbinder.specreader.SpecParser.ParsedSpec;
import dev.specbinder.specreader.SpecTextStripper;
import io.cucumber.messages.types.Feature;

import javax.annotation.processing.Filer;
import javax.annotation.processing.ProcessingEnvironment;
import javax.tools.FileObject;
import javax.tools.StandardLocation;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Parses a Gherkin spec file and extracts its Feature objects, one per spec in the file.
 */
public class FeatureFileParser implements LoggingSupport {

    private final ProcessingEnvironment processingEnv;

    /**
     * Creates a FeatureFileParser instance.
     *
     * @param processingEnv the processing environment used to access the file system
     */
    public FeatureFileParser(ProcessingEnvironment processingEnv) {

        this.processingEnv = processingEnv;
    }

    public ProcessingEnvironment getProcessingEnv() {
        return processingEnv;
    }

    /**
     * Parses a Gherkin spec file using the provided file path and returns one Feature per spec in the file.
     * A file usually holds a single spec; a file holding several top-level Feature keywords (or their synonyms)
     * yields one Feature per keyword, in file order, with line numbers that point into the original file.
     *
     * <p>Options are passed in per call rather than held as a field because they are resolved per
     * annotated element (and are inheritable), while this parser is constructed once.
     *
     * @param featureFilePath the path to the feature file, relative to the classpath
     * @param options         the resolved generator options for the annotated class
     * @return the Feature objects extracted from the spec file, never empty
     * @throws IOException if an error occurs while reading the file or parsing the Gherkin document
     */
    public List<Feature> parseUsingPath(String featureFilePath, GeneratorOptions options) throws IOException {

        String fileContent = loadFileContent(featureFilePath);

        SpecKeywords keywords;
        try {
            keywords = SpecKeywords.of(fileContent, options.getKeywordLanguages(), options.getKeywordSynonyms());
        } catch (IllegalArgumentException e) {
            throw new ProcessingException("In spec file - '" + featureFilePath + "': " + e.getMessage(), e);
        }

        boolean textWasStripped;
        try {
            SpecTextStripper textStripper =
                    SpecTextStripper.of(options.getStripPatterns(), options.getStripBetweenPatterns());
            textWasStripped = textStripper.isEnabled();
            if (textWasStripped) {
                fileContent = textStripper.strip(fileContent, keywords.stepKeywords());
            }
        } catch (IllegalArgumentException e) {
            throw new ProcessingException(e.getMessage(), e);
        }

        List<Feature> features = new ArrayList<>();
        for (String specContent : SpecFileSplitter.split(fileContent, keywords.featureKeywords())) {
            features.add(parseFeature(featureFilePath, specContent, keywords, textWasStripped));
        }
        return features;
    }

    private Feature parseFeature(String featureFilePath, String content, SpecKeywords keywords,
                                 boolean textWasStripped) {

        ParsedSpec parsedSpec = SpecParser.parse(featureFilePath, content, keywords);

        String strippedHint = textWasStripped
                ? " (text was stripped from this file before parsing - check that a stripPatterns or"
                + " stripBetweenPatterns match has not removed a Feature, Rule or Scenario line)"
                : "";

        if (parsedSpec.firstParseError().isPresent()) {
            throw new ProcessingException("In spec file - '" + featureFilePath + "': "
                    + ParseErrorMessage.of(parsedSpec.firstParseError().get()) + strippedHint);
        }
        if (parsedSpec.feature().isPresent()) {
            return parsedSpec.feature().get();
        }
        throw new ProcessingException(
                "Unable to parse Feature from the specified gherkin document: " + featureFilePath + strippedHint);
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