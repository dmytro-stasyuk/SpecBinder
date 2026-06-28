package dev.specbinder.processor;

import com.google.auto.service.AutoService;
import com.squareup.javapoet.AnnotationSpec;
import com.squareup.javapoet.JavaFile;
import com.squareup.javapoet.MethodSpec;
import com.squareup.javapoet.TypeSpec;
import dev.specbinder.annotations.Gherkin2JUnit;
import dev.specbinder.annotations.Gherkin2JUnitOptions.Verbosity;
import dev.specbinder.processor.config.GeneratorOptions;
import dev.specbinder.processor.support.LoggingSupport;
import dev.specbinder.processor.support.SpecBinderVersion;
import dev.specbinder.processor.support.VerbosityContext;
import dev.specbinder.processor.utils.*;
import org.apache.commons.lang3.exception.ExceptionUtils;

import javax.annotation.processing.*;
import javax.lang.model.SourceVersion;
import javax.lang.model.element.Element;
import javax.lang.model.element.PackageElement;
import javax.lang.model.element.TypeElement;
import javax.lang.model.type.TypeKind;
import javax.lang.model.type.TypeMirror;
import javax.lang.model.util.Types;
import javax.tools.FileObject;
import javax.tools.JavaFileObject;
import javax.tools.StandardLocation;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.lang.annotation.Annotation;
import java.util.*;

/**
 * Annotation processor that generates JUnit test subclasses for classes annotated with {@link Gherkin2JUnit} annotation.
 */
@SupportedAnnotationTypes("dev.specbinder.annotations.Gherkin2JUnit")
@SupportedSourceVersion(SourceVersion.RELEASE_21)
@SupportedOptions({"specbinder.verbosity"})
@AutoService(Processor.class)
public class AnnotationProcessor extends AbstractProcessor implements LoggingSupport {

    private static final String SPECBINDER_OPTION_PREFIX = "specbinder.";

    /**
     * Tracks fully qualified class names that have already been generated across processing rounds.
     * The Filer API does not allow creating the same source file twice, so we skip files
     * that were already generated in a previous round.
     */
    private final Set<String> alreadyGeneratedFiles = new HashSet<>();

    private boolean startupBannerEmitted = false;

    /**
     * Default constructor.
     */
    public AnnotationProcessor() {
        super();
    }

    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {

        if (roundEnv.processingOver() || roundEnv.errorRaised()) {
            return false;
        }

        long roundStartMillis = System.currentTimeMillis();
        emitStartupBanner();

        int totalClassesProcessed = 0;
        int totalSpecFilesProcessed = 0;

        // Initialize the factory method resolver for enum type conversion
        ParameterConversionUtils.setFactoryMethodResolver(
                new EnumFactoryMethodResolver(processingEnv));

        // Track all generated class names (fully qualified) across all annotated classes
        // Key: fully qualified class name (package.ClassName)
        // Value: source information (annotated class + feature file path)
        Map<String, String> allGeneratedClassNames = new HashMap<>();

        for (TypeElement annotation : annotations) {

            String annotationName = annotation.getQualifiedName().toString();
            if (!annotationName.equals(Gherkin2JUnit.class.getName())) {
                continue;
            }

            Set<? extends Element> annotatedElements = roundEnv.getElementsAnnotatedWith(annotation);
            for (Element annotatedElement : annotatedElements) {

                totalClassesProcessed++;

                TypeElement annotatedClass = (TypeElement) annotatedElement;

                Gherkin2JUnit targetAnnotation = annotatedClass.getAnnotation(Gherkin2JUnit.class);

                // Resolve options from the class hierarchy, supporting partial inheritance
                GeneratorOptions generatorOptions = Gherkin2JUnitOptionsResolver.resolveOptions(
                        annotatedClass, getProcessingEnv()
                );

                // Publish the per-class effective verbosity so helper classes
                // (BackgroundProcessor, ScenarioProcessor, GlobPatternMatcher, …) gate their
                // logVerbose / logDebug calls on the same level we use here.
                VerbosityContext.set(effectiveVerbosity(generatorOptions));

                try {

                // Validate supportedFileExtensions
                try {
                    FeatureFileExtensions.validate(generatorOptions.getSupportedFileExtensions());
                } catch (IllegalArgumentException e) {
                    logError(e.getMessage());
                    throw new RuntimeException(e.getMessage());
                }

                TestSubclassCreator subclassGenerator = new TestSubclassCreator(getProcessingEnv(), generatorOptions);

                String annotationValue = targetAnnotation.value();

                // Check if the annotation value is empty - if so, derive a pattern from the package
                if (annotationValue == null || annotationValue.isBlank()) {
                    String[] extensions = generatorOptions.getSupportedFileExtensions();
                    String globWildcard = FeatureFileExtensions.globWildcard(extensions);
                    String packageName = getPackageName(annotatedClass);
                    if (packageName.isEmpty()) {
                        annotationValue = globWildcard;
                    } else {
                        annotationValue = packageName.replace('.', '/') + "/" + globWildcard;
                    }
                    logVerbose("Empty annotation value detected, using pattern: " + annotationValue);
                }

                // Resolve a leading "./" against the annotated class's package directory.
                // The original annotationValue is preserved for user-facing messages.
                String resolvedValue = resolveRelativePath(annotationValue, annotatedClass);

                // Check if the annotation value is a glob pattern
                if (GlobPatternMatcher.isGlobPattern(resolvedValue)) {
                    logVerbose("Detected glob pattern: " + resolvedValue);

                    // Find all matching feature files
                    GlobPatternMatcher patternMatcher = createGlobPatternMatcher();
                    List<String> matchingFiles;

                    try {
                        matchingFiles = patternMatcher.findMatchingFiles(resolvedValue);
                    } catch (IOException e) {
                        logException(e, annotatedClass);
                        continue;
                    }

                    if (matchingFiles.isEmpty()) {
                        String errorMessage = "No feature files found matching pattern '" + annotationValue + "'";
                        logError(errorMessage);
                        throw new RuntimeException(errorMessage);
                    }

                    emitProcessingHeader(annotatedClass, generatorOptions, matchingFiles);

                    // Check for duplicate generated class names (both within pattern and across all annotations)
                    String suffixToApply = generatorOptions.getClassSuffixIfAbstract();
                    String packageName = getPackageName(annotatedClass);

                    for (String featureFilePath : matchingFiles) {
                        String generatedClassName = subclassGenerator.extractFeatureFileName(featureFilePath) + suffixToApply;
                        String fullyQualifiedClassName = packageName.isEmpty()
                            ? generatedClassName
                            : packageName + "." + generatedClassName;

                        if (allGeneratedClassNames.containsKey(fullyQualifiedClassName)) {
                            String errorMessage = "Duplicate generated class name '" + generatedClassName +
                                    "' from feature file pattern '" + annotationValue + "'.";
                            logError(errorMessage);
                            throw new RuntimeException(errorMessage);
                        }

                        allGeneratedClassNames.put(fullyQualifiedClassName,
                            "from @Gherkin2JUnit on " + annotatedClass.getQualifiedName() + " for " + featureFilePath);
                    }

                    totalSpecFilesProcessed += matchingFiles.size();

                    // Generate a test class for each matching file
                    for (String featureFilePath : matchingFiles) {
                        emitProgressStart(generatorOptions, featureFilePath);

                        TestSubclassCreator.GeneratedFileResult result = null;
                        try {
                            result = subclassGenerator.createTestSubclass(annotatedClass, featureFilePath, true);
                        } catch (IOException e) {
                            logException(e, annotatedClass);
                            continue;
                        }

                        if (result == null) {
                            // Feature carries a matching skip tag — no class is generated. Release the
                            // reserved class name so it is not counted or flagged as a duplicate.
                            String skippedClassName = subclassGenerator.extractFeatureFileName(featureFilePath) + suffixToApply;
                            String skippedFqcn = packageName.isEmpty()
                                    ? skippedClassName
                                    : packageName + "." + skippedClassName;
                            allGeneratedClassNames.remove(skippedFqcn);
                            emitProgressSkipped(generatorOptions, featureFilePath);
                            continue;
                        }

                        emitProgressGeneratedClass(generatorOptions, getFullyQualifiedClassName(result.javaFile), result.javaFile.typeSpec);

                        // Write the generated file
                        writeGeneratedFile(result, annotatedClass, generatorOptions);

                        emitProgressFinish(generatorOptions, featureFilePath);
                    }
                } else {
                    // Single feature file (original behavior)
                    emitProcessingHeader(annotatedClass, generatorOptions, List.of(annotationValue));

                    totalSpecFilesProcessed++;
                    emitProgressStart(generatorOptions, annotationValue);

                    TestSubclassCreator.GeneratedFileResult result = null;
                    try {
                        result = subclassGenerator.createTestSubclass(annotatedClass, resolvedValue, true);
                    } catch (FileNotFoundException e) {
                        String errorMessage = "No feature file found for path '" + annotationValue + "'";
                        logError(errorMessage);
                        throw new RuntimeException(errorMessage, e);
                    } catch (IOException e) {
                        logException(e, annotatedClass);
                        continue;
                    }

                    if (result == null) {
                        // Feature carries a matching skip tag — no class is generated for it.
                        emitProgressSkipped(generatorOptions, annotationValue);
                        emitProgressFinish(generatorOptions, annotationValue);
                        continue;
                    }

                    // Check for duplicate generated class name
                    String fullyQualifiedClassName = getFullyQualifiedClassName(result.javaFile);

                    if (allGeneratedClassNames.containsKey(fullyQualifiedClassName)) {
                        String errorMessage = "Duplicate generated class name '" + result.javaFile.typeSpec.name +
                                "' would be generated for feature file '" + annotationValue + "'. " +
                                "Previously generated " + allGeneratedClassNames.get(fullyQualifiedClassName);
                        logError(errorMessage);
                        throw new RuntimeException(errorMessage);
                    }

                    allGeneratedClassNames.put(fullyQualifiedClassName,
                        "from @Gherkin2JUnit on " + annotatedClass.getQualifiedName() + " for " + annotationValue);

                    emitProgressGeneratedClass(generatorOptions, fullyQualifiedClassName, result.javaFile.typeSpec);

                    // Write the generated file
                    writeGeneratedFile(result, annotatedClass, generatorOptions);

                    emitProgressFinish(generatorOptions, annotationValue);
                }

                } finally {
                    VerbosityContext.clear();
                }
            }
        }

        long elapsedMillis = System.currentTimeMillis() - roundStartMillis;
        emitEndOfRoundSummary(totalClassesProcessed, totalSpecFilesProcessed, allGeneratedClassNames.size(), elapsedMillis);

        return true;
    }

    private void writeGeneratedFile(TestSubclassCreator.GeneratedFileResult result, TypeElement annotatedClass, GeneratorOptions generatorOptions) {
        String fullyQualifiedName = getFullyQualifiedClassName(result.javaFile);

        // Skip if this file was already generated in a previous processing round
        if (alreadyGeneratedFiles.contains(fullyQualifiedName)) {
            logVerbose("Skipping already generated class: " + fullyQualifiedName);
            return;
        }

        boolean placeInSameDir = generatorOptions.isPlaceGeneratedClassNextToAnnotatedClass();

        if (placeInSameDir) {
            try {
                writeGeneratedSourceFileNextToAnnotatedClass(result, annotatedClass, generatorOptions);
            } catch (IOException e) {
                logException(e, annotatedClass);
            }
        } else {
            Filer filer = getProcessingEnv().getFiler();

            PrintWriter out = null;
            try {
                JavaFileObject subclassFile = filer.createSourceFile(fullyQualifiedName);

                out = new PrintWriter(subclassFile.openWriter());
                result.writeTo(out);
                out.flush();
            } catch (FilerException e) {
                // File already exists in the compilation — this happens when a build system
                // (e.g., Gradle) includes previously generated sources as a source root.
                // Fall back to overwriting the file directly via the file system.
                overwriteExistingGeneratedFile(result, fullyQualifiedName, annotatedClass);
            } catch (Throwable t) {
                logException(t, annotatedClass);
            } finally {
                if (out != null) {
                    out.close();
                }
            }
        }

        alreadyGeneratedFiles.add(fullyQualifiedName);
    }

    /**
     * Overwrites an existing generated source file directly via the file system.
     * Used as a fallback when the Filer API refuses to create a file because the type
     * already exists in the current compilation (e.g., from previously generated sources
     * included as a source root by the build system).
     */
    private void overwriteExistingGeneratedFile(TestSubclassCreator.GeneratedFileResult result, String fullyQualifiedName, TypeElement annotatedClass) {
        try {
            Filer filer = getProcessingEnv().getFiler();
            String packageName = result.javaFile.packageName;
            String fileName = result.javaFile.typeSpec.name + ".java";

            // Use the Filer to locate the SOURCE_OUTPUT directory for this package
            FileObject existing = filer.getResource(StandardLocation.SOURCE_OUTPUT, packageName, fileName);
            File targetFile = new File(existing.toUri());
            targetFile.getParentFile().mkdirs();

            try (PrintWriter writer = new PrintWriter(targetFile)) {
                result.writeTo(writer);
            }

            logVerbose("Overwrote existing generated class: " + fullyQualifiedName);
        } catch (IOException overwriteException) {
            logException(overwriteException, annotatedClass);
        }
    }

    /**
     * Gets the fully qualified class name from a JavaFile.
     */
    private String getFullyQualifiedClassName(JavaFile javaFile) {
        return javaFile.packageName.isEmpty()
                ? javaFile.typeSpec.name
                : javaFile.packageName + "." + javaFile.typeSpec.name;
    }

    private void writeGeneratedSourceFileNextToAnnotatedClass(TestSubclassCreator.GeneratedFileResult result, TypeElement annotatedClass, GeneratorOptions generatorOptions) throws IOException {
        // Get the source file location of the annotated class
        FileObject resource = getProcessingEnv().getFiler().getResource(
                StandardLocation.SOURCE_PATH,
                "",
                annotatedClass.getQualifiedName().toString().replace('.', '/') + ".java"
        );

        String sourceFilePath = resource.toUri().getPath();
        File sourceFile = new File(sourceFilePath);
        File sourceDir = sourceFile.getParentFile();

        // Determine the suffix
        String suffix = generatorOptions.getClassSuffixIfAbstract();

        String generatedClassName = annotatedClass.getSimpleName().toString() + suffix + ".java";
        File targetFile = new File(sourceDir, generatedClassName);

        if (targetFile.exists()) {
            boolean deleted = targetFile.delete();
            if (!deleted) {
                throw new IOException("Failed to delete existing generated file: " + targetFile.getAbsolutePath());
            }
        }

        // Write the file
        try (PrintWriter out = new PrintWriter(targetFile)) {
            result.writeTo(out);
        }
    }

    private void emitStartupBanner() {
        if (startupBannerEmitted) {
            return;
        }
        startupBannerEmitted = true;

        Map<String, String> activeArguments = collectActiveProcessorArguments();

        logInfo("====================================================================");
        logInfo("SpecBinder annotation processor — version " + SpecBinderVersion.get());
        if (!activeArguments.isEmpty()) {
            logInfo("Active processor arguments:");
            int paddingWidth = activeArguments.keySet().stream().mapToInt(String::length).max().orElse(0);
            for (Map.Entry<String, String> entry : activeArguments.entrySet()) {
                logInfo("  " + padRight(entry.getKey(), paddingWidth) + " = " + entry.getValue());
            }
        }
        logInfo("====================================================================");
    }

    private Map<String, String> collectActiveProcessorArguments() {
        Map<String, String> all = getProcessingEnv().getOptions();
        if (all == null || all.isEmpty()) {
            return Map.of();
        }
        Map<String, String> filtered = new LinkedHashMap<>();
        for (Map.Entry<String, String> entry : all.entrySet()) {
            if (entry.getKey() != null && entry.getKey().startsWith(SPECBINDER_OPTION_PREFIX)) {
                filtered.put(entry.getKey(), entry.getValue() == null ? "" : entry.getValue());
            }
        }
        return filtered;
    }

    private static String padRight(String value, int width) {
        return value.length() >= width ? value : value + " ".repeat(width - value.length());
    }

    private void emitProcessingHeader(TypeElement annotatedClass, GeneratorOptions options, List<String> matchedSpecFiles) {
        if (effectiveVerbosity(options).ordinal() < Verbosity.VERBOSE.ordinal()) {
            return;
        }

        Map<String, String> overridden = new LinkedHashMap<>();
        Map<String, String> defaulted = new LinkedHashMap<>();
        classifyOptions(options, new GeneratorOptions(), overridden, defaulted);

        int paddingWidth = 0;
        for (String key : overridden.keySet()) paddingWidth = Math.max(paddingWidth, key.length());
        for (String key : defaulted.keySet()) paddingWidth = Math.max(paddingWidth, key.length());

        logVerbose("--------------------------------------------------------------------");
        logVerbose("Processing '" + annotatedClass.getQualifiedName() + "'");
        if (!overridden.isEmpty()) {
            logVerbose("Overridden options:");
            for (Map.Entry<String, String> entry : overridden.entrySet()) {
                logVerbose("  " + padRight(entry.getKey(), paddingWidth) + " = " + entry.getValue());
            }
        }
        if (!defaulted.isEmpty()) {
            logVerbose("Default options:");
            for (Map.Entry<String, String> entry : defaulted.entrySet()) {
                logVerbose("  " + padRight(entry.getKey(), paddingWidth) + " = " + entry.getValue());
            }
        }
        logVerbose("Spec files matched:");
        for (String specFilePath : matchedSpecFiles) {
            logVerbose("  - " + specFilePath);
        }
        logVerbose("--------------------------------------------------------------------");
    }

    private void emitProgressStart(GeneratorOptions options, String specFilePath) {
        if (effectiveVerbosity(options).ordinal() < Verbosity.VERBOSE.ordinal()) {
            return;
        }
        logVerbose("Started  '" + specFilePath + "'");
    }

    private void emitProgressGeneratedClass(GeneratorOptions options, String fullyQualifiedClassName, TypeSpec typeSpec) {
        if (effectiveVerbosity(options).ordinal() < Verbosity.VERBOSE.ordinal()) {
            return;
        }
        logVerbose("  Generated class: " + fullyQualifiedClassName);
        logVerbose("  Test methods:    " + countTestMethods(typeSpec));
        logVerbose("  Step methods:    " + countStepMethods(typeSpec));
    }

    private static int countTestMethods(TypeSpec typeSpec) {
        int count = 0;
        for (MethodSpec method : typeSpec.methodSpecs) {
            for (AnnotationSpec ann : method.annotations) {
                String name = ann.type.toString();
                if (name.endsWith(".Test") || name.endsWith(".ParameterizedTest")) {
                    count++;
                    break;
                }
            }
        }
        for (TypeSpec nested : typeSpec.typeSpecs) {
            count += countTestMethods(nested);
        }
        return count;
    }

    private static int countStepMethods(TypeSpec typeSpec) {
        int count = 0;
        for (MethodSpec method : typeSpec.methodSpecs) {
            if (method.isConstructor()) {
                continue;
            }
            if (hasNonStepAnnotation(method)) {
                continue;
            }
            count++;
        }
        for (TypeSpec nested : typeSpec.typeSpecs) {
            count += countStepMethods(nested);
        }
        return count;
    }

    private static boolean hasNonStepAnnotation(MethodSpec method) {
        for (AnnotationSpec ann : method.annotations) {
            String name = ann.type.toString();
            if (name.endsWith(".Test")
                    || name.endsWith(".ParameterizedTest")
                    || name.endsWith(".BeforeEach")
                    || name.endsWith(".AfterEach")
                    || name.endsWith(".BeforeAll")
                    || name.endsWith(".AfterAll")) {
                return true;
            }
        }
        return false;
    }

    private void emitEndOfRoundSummary(int annotatedClassesFound, int specFilesProcessed, int classesGenerated, long elapsedMillis) {
        String delimiter = "#".repeat(68);
        logInfo(delimiter);
        logInfo("Annotated classes found: " + annotatedClassesFound);
        logInfo("Spec files processed:    " + specFilesProcessed);
        logInfo("Classes generated:       " + classesGenerated);
        logInfo("Elapsed time:            " + elapsedMillis + " ms");
        logInfo(delimiter);
    }

    private void emitProgressFinish(GeneratorOptions options, String specFilePath) {
        if (effectiveVerbosity(options).ordinal() < Verbosity.VERBOSE.ordinal()) {
            return;
        }
        logVerbose("Finished '" + specFilePath + "'");
    }

    private void emitProgressSkipped(GeneratorOptions options, String specFilePath) {
        if (effectiveVerbosity(options).ordinal() < Verbosity.VERBOSE.ordinal()) {
            return;
        }
        logVerbose("Skipped '" + specFilePath + "' — Feature tagged for skip generation; no class generated");
    }

    /**
     * Resolves the effective verbosity for a particular annotated class. Precedence:
     * <ol>
     *   <li>The class's {@code @Gherkin2JUnitOptions(verbosity = …)} value, if it is non-default
     *       (anything other than {@link Verbosity#NORMAL}).</li>
     *   <li>The {@code -Aspecbinder.verbosity=…} processor argument, if present and parseable.</li>
     *   <li>{@link Verbosity#NORMAL} otherwise.</li>
     * </ol>
     * Unknown processor-argument values fall through to {@code NORMAL} — the VerbosityControl
     * scenarios will surface these as a separate error.
     */
    private Verbosity effectiveVerbosity(GeneratorOptions options) {
        if (options != null && options.getVerbosity() != null && options.getVerbosity() != Verbosity.NORMAL) {
            return options.getVerbosity();
        }
        Map<String, String> activeOptions = getProcessingEnv().getOptions();
        if (activeOptions != null) {
            String value = activeOptions.get(SPECBINDER_OPTION_PREFIX + "verbosity");
            if (value != null) {
                try {
                    return Verbosity.parse(value);
                } catch (IllegalArgumentException ignored) {
                    // Unknown values fall through to NORMAL.
                }
            }
        }
        return Verbosity.NORMAL;
    }

    /**
     * Walks the resolved {@link GeneratorOptions} and classifies each field as either overridden
     * (current value differs from the corresponding default) or defaulted. The two maps preserve
     * declaration order so the rendered banner is deterministic.
     */
    private static void classifyOptions(
            GeneratorOptions resolved,
            GeneratorOptions defaults,
            Map<String, String> overridden,
            Map<String, String> defaulted) {

        putOption("shouldBeAbstract",
                fmtBool(resolved.isShouldBeAbstract()), fmtBool(defaults.isShouldBeAbstract()), overridden, defaulted);
        putOption("classSuffixIfConcrete",
                fmtString(resolved.getClassSuffixIfConcrete()), fmtString(defaults.getClassSuffixIfConcrete()), overridden, defaulted);
        putOption("classSuffixIfAbstract",
                fmtString(resolved.getClassSuffixIfAbstract()), fmtString(defaults.getClassSuffixIfAbstract()), overridden, defaulted);
        putOption("addSourceLineNumbers",
                fmtBool(resolved.isAddSourceLineNumbers()), fmtBool(defaults.isAddSourceLineNumbers()), overridden, defaulted);
        putOption("emptyScenarioBehavior",
                fmtEnumName(resolved.getEmptyScenarioBehavior()), fmtEnumName(defaults.getEmptyScenarioBehavior()), overridden, defaulted);
        putOption("emptyRuleBehavior",
                fmtEnumName(resolved.getEmptyRuleBehavior()), fmtEnumName(defaults.getEmptyRuleBehavior()), overridden, defaulted);
        putOption("unimplementedStepBehavior",
                fmtEnumName(resolved.getUnimplementedStepBehavior()), fmtEnumName(defaults.getUnimplementedStepBehavior()), overridden, defaulted);
        putOption("tagForEmptyScenarios",
                fmtString(resolved.getTagForEmptyScenarios()), fmtString(defaults.getTagForEmptyScenarios()), overridden, defaulted);
        putOption("tagForEmptyRules",
                fmtString(resolved.getTagForEmptyRules()), fmtString(defaults.getTagForEmptyRules()), overridden, defaulted);
        putOption("addCucumberStepAnnotations",
                fmtBool(resolved.isAddCucumberStepAnnotations()), fmtBool(defaults.isAddCucumberStepAnnotations()), overridden, defaulted);
        putOption("placeGeneratedClassNextToAnnotatedClass",
                fmtBool(resolved.isPlaceGeneratedClassNextToAnnotatedClass()), fmtBool(defaults.isPlaceGeneratedClassNextToAnnotatedClass()), overridden, defaulted);
        putOption("dataTableParameterType",
                fmtEnumName(resolved.getDataTableParameterType()), fmtEnumName(defaults.getDataTableParameterType()), overridden, defaulted);
        putOption("enableCompositeSteps",
                fmtBool(resolved.isEnableCompositeSteps()), fmtBool(defaults.isEnableCompositeSteps()), overridden, defaulted);
        putOption("useQualifiedEnumConstants",
                fmtBool(resolved.isUseQualifiedEnumConstants()), fmtBool(defaults.isUseQualifiedEnumConstants()), overridden, defaulted);
        putOption("useStepKeywordInStepMethodName",
                fmtBool(resolved.isUseStepKeywordInStepMethodName()), fmtBool(defaults.isUseStepKeywordInStepMethodName()), overridden, defaulted);
        putOption("useCucumberAnnotationsForStepMatching",
                fmtBool(resolved.isUseCucumberAnnotationsForStepMatching()), fmtBool(defaults.isUseCucumberAnnotationsForStepMatching()), overridden, defaulted);
        putOption("supportedFileExtensions",
                fmtStringArray(resolved.getSupportedFileExtensions()), fmtStringArray(defaults.getSupportedFileExtensions()), overridden, defaulted);
        putOption("skipGenerationForTags",
                fmtStringArray(resolved.getSkipGenerationForTags()), fmtStringArray(defaults.getSkipGenerationForTags()), overridden, defaulted);
        putOption("emitScenarioHash",
                fmtBool(resolved.isEmitScenarioHash()), fmtBool(defaults.isEmitScenarioHash()), overridden, defaulted);
        putOption("descriptionAsAnnotation",
                fmtBool(resolved.isDescriptionAsAnnotation()), fmtBool(defaults.isDescriptionAsAnnotation()), overridden, defaulted);
        putOption("maxStringLiteralBytes",
                Integer.toString(resolved.getMaxStringLiteralBytes()), Integer.toString(defaults.getMaxStringLiteralBytes()), overridden, defaulted);
        putOption("skipUnchangedSpecs",
                fmtBool(resolved.isSkipUnchangedSpecs()), fmtBool(defaults.isSkipUnchangedSpecs()), overridden, defaulted);
    }

    private static void putOption(String name, String resolvedValue, String defaultValue,
                                   Map<String, String> overridden, Map<String, String> defaulted) {
        if (resolvedValue.equals(defaultValue)) {
            defaulted.put(name, resolvedValue);
        } else {
            overridden.put(name, resolvedValue);
        }
    }

    private static String fmtBool(boolean value) {
        return value ? "true" : "false";
    }

    private static String fmtString(String value) {
        return "\"" + value + "\"";
    }

    private static String fmtEnumName(String value) {
        return value;
    }

    private static String fmtStringArray(String[] value) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < value.length; i++) {
            if (i > 0) sb.append(", ");
            sb.append(value[i]);
        }
        sb.append("]");
        return sb.toString();
    }

    private void logException(Throwable t, TypeElement annotatedClass) {

        logError("An error occurred while processing annotated element - '" + annotatedClass.getQualifiedName() + "'");
        String rootCauseMessage = ExceptionUtils.getRootCauseMessage(t);
        logError("Root cause message: " + rootCauseMessage);
        String stackTrace = ExceptionUtils.getStackTrace(t);
        logError("Stack trace: \n", stackTrace);
    }

    @Override
    public ProcessingEnvironment getProcessingEnv() {
        return processingEnv;
    }

    @Override
    public SourceVersion getSupportedSourceVersion() {
        return SourceVersion.RELEASE_21;
    }

    /**
     * Factory method for creating GlobPatternMatcher.
     * Public to allow mocking in tests.
     *
     * @return a new GlobPatternMatcher instance
     */
    public GlobPatternMatcher createGlobPatternMatcher() {
        return new GlobPatternMatcher(getProcessingEnv());
    }

    /**
     * Extracts the package name from a TypeElement.
     *
     * @param typeElement the type element to extract the package from
     * @return the package name, or empty string if no package
     */
    private String getPackageName(TypeElement typeElement) {
        Element enclosingElement = typeElement.getEnclosingElement();
        if (enclosingElement instanceof PackageElement) {
            return ((PackageElement) enclosingElement).getQualifiedName().toString();
        }
        return "";
    }

    /**
     * Resolves a path that begins with {@code "./"} against the package directory of the annotated class.
     * The leading {@code "."} denotes the annotated class's package; the remainder is appended after it.
     * Applies equally to glob patterns and individual file paths. Paths that do not start with {@code "./"}
     * are returned unchanged.
     */
    private String resolveRelativePath(String value, TypeElement annotatedClass) {
        if (value == null || !value.startsWith("./")) {
            return value;
        }
        String remainder = value.substring(2);
        String packageName = getPackageName(annotatedClass);
        if (packageName.isEmpty()) {
            return remainder;
        }
        return packageName.replace('.', '/') + "/" + remainder;
    }

    // Add this helper method inside the AnnotationProcessor class:
    private <A extends Annotation> A findAnnotationOnHierarchy(TypeElement start, Class<A> annotationClass) {

        Types typeUtils = getProcessingEnv().getTypeUtils();
        TypeElement current = start;

        while (current != null && !"java.lang.Object".equals(current.getQualifiedName().toString())) {
            A ann = current.getAnnotation(annotationClass);
            if (ann != null) {
                return ann;
            }

            TypeMirror superMirror = current.getSuperclass();
            if (superMirror == null || superMirror.getKind() == TypeKind.NONE) {
                break;
            }

            Element superElement = typeUtils.asElement(superMirror);
            if (!(superElement instanceof TypeElement)) {
                break;
            }
            current = (TypeElement) superElement;
        }

        return null;
    }
}