package dev.specbinder.feature2junit;

import com.google.auto.service.AutoService;
import com.squareup.javapoet.JavaFile;
import dev.specbinder.annotations.Feature2JUnit;
import dev.specbinder.feature2junit.config.GeneratorOptions;
import dev.specbinder.feature2junit.support.LoggingSupport;
import dev.specbinder.feature2junit.utils.*;
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
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.PrintWriter;
import java.lang.annotation.Annotation;
import java.util.*;

/**
 * Annotation processor that generates JUnit test subclasses for classes annotated with {@link Feature2JUnit} annotation.
 */
@SupportedAnnotationTypes("dev.specbinder.annotations.Feature2JUnit")
@SupportedSourceVersion(SourceVersion.RELEASE_21)
@AutoService(Processor.class)
public class Feature2JUnitGenerator extends AbstractProcessor implements LoggingSupport {

    /**
     * Tracks fully qualified class names that have already been generated across processing rounds.
     * The Filer API does not allow creating the same source file twice, so we skip files
     * that were already generated in a previous round.
     */
    private final Set<String> alreadyGeneratedFiles = new HashSet<>();

    /**
     * Default constructor.
     */
    public Feature2JUnitGenerator() {
        super();
    }

    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {

        if (roundEnv.processingOver() || roundEnv.errorRaised()) {
            return false;
        }

        int totalClassesProcessed = 0;

        logInfo("Running " + this.getClass().getSimpleName());

        // Initialize the factory method resolver for enum type conversion
        ParameterConversionUtils.setFactoryMethodResolver(
                new EnumFactoryMethodResolver(processingEnv));

        // Track all generated class names (fully qualified) across all annotated classes
        // Key: fully qualified class name (package.ClassName)
        // Value: source information (annotated class + feature file path)
        Map<String, String> allGeneratedClassNames = new HashMap<>();

        for (TypeElement annotation : annotations) {

            String annotationName = annotation.getQualifiedName().toString();
            if (!annotationName.equals(Feature2JUnit.class.getName())) {
                continue;
            }

            Set<? extends Element> annotatedElements = roundEnv.getElementsAnnotatedWith(annotation);
            for (Element annotatedElement : annotatedElements) {

                totalClassesProcessed++;

                TypeElement annotatedClass = (TypeElement) annotatedElement;

                logInfo("Processing '" + annotatedClass.getQualifiedName() + "'");

                Feature2JUnit targetAnnotation = annotatedClass.getAnnotation(Feature2JUnit.class);

                // Resolve options from the class hierarchy, supporting partial inheritance
                GeneratorOptions generatorOptions = Feature2JUnitOptionsResolver.resolveOptions(
                        annotatedClass, getProcessingEnv()
                );

                logOther("Resolved options: " + generatorOptions);

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
                    logInfo("Empty annotation value detected, using pattern: " + annotationValue);
                }

                // Check if the annotation value is a glob pattern
                if (GlobPatternMatcher.isGlobPattern(annotationValue)) {
                    logInfo("Detected glob pattern: " + annotationValue);

                    // Find all matching feature files
                    GlobPatternMatcher patternMatcher = createGlobPatternMatcher();
                    List<String> matchingFiles;

                    try {
                        matchingFiles = patternMatcher.findMatchingFiles(annotationValue);
                    } catch (IOException e) {
                        logException(e, annotatedClass);
                        continue;
                    }

                    if (matchingFiles.isEmpty()) {
                        String errorMessage = "No feature files found matching pattern '" + annotationValue + "'";
                        logError(errorMessage);
                        throw new RuntimeException(errorMessage);
                    }

                    logInfo("Found " + matchingFiles.size() + " files matching pattern: " + annotationValue);

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
                            "from @Feature2JUnit on " + annotatedClass.getQualifiedName() + " for " + featureFilePath);
                    }

                    // Generate a test class for each matching file
                    for (String featureFilePath : matchingFiles) {
                        logInfo("Processing feature file: " + featureFilePath);

                        TestSubclassCreator.GeneratedFileResult result = null;
                        try {
                            result = subclassGenerator.createTestSubclass(annotatedClass, featureFilePath, true);
                        } catch (IOException e) {
                            logException(e, annotatedClass);
                            continue;
                        }

                        // Write the generated file
                        writeGeneratedFile(result, annotatedClass, generatorOptions);
                    }
                } else {
                    // Single feature file (original behavior)
                    TestSubclassCreator.GeneratedFileResult result = null;
                    try {
                        result = subclassGenerator.createTestSubclass(annotatedClass, annotationValue, true);
                    } catch (FileNotFoundException e) {
                        String errorMessage = "No feature file found for path '" + annotationValue + "'";
                        logError(errorMessage);
                        throw new RuntimeException(errorMessage, e);
                    } catch (IOException e) {
                        logException(e, annotatedClass);
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
                        "from @Feature2JUnit on " + annotatedClass.getQualifiedName() + " for " + annotationValue);

                    // Write the generated file
                    writeGeneratedFile(result, annotatedClass, generatorOptions);
                }
            }
        }

        logInfo("Finished, total classes processed: " + totalClassesProcessed);

        return true;
    }

    private void writeGeneratedFile(TestSubclassCreator.GeneratedFileResult result, TypeElement annotatedClass, GeneratorOptions generatorOptions) {
        String fullyQualifiedName = getFullyQualifiedClassName(result.javaFile);

        // Skip if this file was already generated in a previous processing round
        if (alreadyGeneratedFiles.contains(fullyQualifiedName)) {
            logInfo("Skipping already generated class: " + fullyQualifiedName);
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
        logInfo("Generated test class: " + fullyQualifiedName);
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
            java.io.File targetFile = new java.io.File(existing.toUri());

            try (PrintWriter writer = new PrintWriter(targetFile)) {
                result.writeTo(writer);
            }

            logInfo("Overwrote existing generated class: " + fullyQualifiedName);
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
        java.io.File sourceFile = new java.io.File(sourceFilePath);
        java.io.File sourceDir = sourceFile.getParentFile();

        // Determine the suffix
        String suffix = generatorOptions.getClassSuffixIfAbstract();

        String generatedClassName = annotatedClass.getSimpleName().toString() + suffix + ".java";
        java.io.File targetFile = new java.io.File(sourceDir, generatedClassName);

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

        logInfo("Generated test class: " + getFullyQualifiedClassName(result.javaFile)
                + " at " + targetFile.getAbsolutePath());
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

    // Add this helper method inside the Feature2JUnitGenerator class:
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