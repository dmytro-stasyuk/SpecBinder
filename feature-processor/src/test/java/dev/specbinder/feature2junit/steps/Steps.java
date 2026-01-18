package dev.specbinder.feature2junit.steps;

import dev.specbinder.annotations.Feature2JUnit;
import dev.specbinder.feature2junit.Feature2JUnitGenerator;
import dev.specbinder.annotations.Feature2JUnitOptions;
import dev.specbinder.feature2junit.mocks.Mocks;
import dev.specbinder.feature2junit.utils.GlobPatternMatcher;
import io.cucumber.java.Before;
import io.cucumber.java.Scenario;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import org.junit.jupiter.api.Assertions;
import org.mockito.Mockito;

import javax.annotation.processing.Filer;
import javax.annotation.processing.ProcessingEnvironment;
import javax.annotation.processing.RoundEnvironment;
import javax.lang.model.element.Element;
import javax.lang.model.element.ElementKind;
import javax.lang.model.element.ExecutableElement;
import javax.lang.model.element.Name;
import javax.lang.model.element.PackageElement;
import javax.lang.model.element.TypeElement;
import javax.lang.model.type.DeclaredType;
import javax.lang.model.type.NoType;
import javax.lang.model.type.TypeKind;
import javax.lang.model.type.TypeMirror;
import javax.tools.FileObject;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.StringWriter;
import java.net.URI;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.squareup.javapoet.ClassName;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

public class Steps {

    protected Feature2JUnitGenerator generator;

    protected Exception generatorException;

    protected RoundEnvironment roundEnv;

    protected ProcessingEnvironment processingEnvironment;

    protected Set<TypeElement> annotationSetToProcess;

    protected Filer filer;

    protected StringWriter generatedClassWriter;

    // Track multiple base classes for inheritance hierarchy
    protected List<BaseClassInfo> baseClassHierarchy = new ArrayList<>();

    // Store the current feature file path (relative to src/test/resources)
    protected String currentFeatureFilePath;

    // Store the feature file path from @Feature2JUnit annotation
    protected String annotatedFeatureFilePath;

    // Map to store multiple feature files with their paths and contents
    protected Map<String, String> featureFiles = new HashMap<>();

    // Map to store multiple generated classes (className -> content)
    protected Map<String, String> generatedClasses = new HashMap<>();

    // Set to false to skip compilation verification and speed up tests by ~5x
    public static boolean verifyCompilation = false;

    public Steps() {

        processingEnvironment = Mocks.processingEnvironment(baseClassHierarchy);

        filer = Mocks.filer(processingEnvironment);

        generatedClassWriter = Mocks.generatedClassWriter(filer, generatedClasses);

        generator = Mocks.generator(processingEnvironment);

        roundEnv = Mocks.roundEnvironment();

        TypeElement feature2junitAnnotationType = Mocks.feature2junitAnnotationTypeMirror();
        annotationSetToProcess = Set.of(feature2junitAnnotationType);

        // Create a default annotated base class for tests that don't use "Given the following base class"
        Feature2JUnit defaultAnnotation = Mocks.feature2junit();
        Feature2JUnitOptions defaultOptions = Mocks.defaultFeature2junitOptions();
        TypeElement defaultAnnotatedClass = Mocks.annotatedBaseClass(defaultAnnotation, defaultOptions);

        // Set up roundEnv to return this default annotated class
        @SuppressWarnings("rawtypes")
        Set mockedAnnotatedElements = Set.of(defaultAnnotatedClass);
        when(roundEnv.getElementsAnnotatedWith(feature2junitAnnotationType))
                .thenReturn(mockedAnnotatedElements);
    }

    //@Before
    public void beforeEach(Scenario scenario) {
        // Reset the generatorException before each scenario
        generatorException = null;
        baseClassHierarchy.clear();
        featureFiles.clear();
        generatedClasses.clear();
        annotatedFeatureFilePath = null;

        // Capture feature file information
        if (scenario != null) {
            URI featureUri = scenario.getUri();
            String fullPath = featureUri.toString();

            // Extract path after "classpath:" prefix for Cucumber URIs
            if (fullPath.startsWith("classpath:")) {
                currentFeatureFilePath = fullPath.substring("classpath:".length());
            } else {
                // Extract path after "src/test/resources/" for file URIs
                String marker = "src/test/resources/";
                int index = fullPath.indexOf(marker);
                if (index != -1) {
                    currentFeatureFilePath = fullPath.substring(index + marker.length());
                } else {
                    // Fallback to the full path
                    currentFeatureFilePath = fullPath;
                }
            }
        }

    }

    //@Given("the following base class:")
    public void the_following_base_class(String docString) {

        // Extract the package name and class name from the base class
        String packageName = BaseClassCodeParser.extractPackageName(docString);
        String className = BaseClassCodeParser.extractClassName(docString);

        // Create BaseClassInfo and add to hierarchy
        BaseClassInfo classInfo = new BaseClassInfo(packageName, className, docString);
        baseClassHierarchy.add(classInfo);

        // For the first base class with @Feature2JUnit, reuse the existing annotatedBaseClass mock
        // to maintain compatibility with existing tests
        TypeElement typeElement = mock(TypeElement.class);
        classInfo.typeElement = typeElement;

        // Extract and mock methods from the base class
        List<String> methodNames = BaseClassCodeParser.extractMethodNames(docString);
        List<? extends Element> enclosedElements = createMethodMocks(methodNames);
        when(typeElement.getEnclosedElements()).thenReturn((List) enclosedElements);
        // Set up basic TypeElement properties
        when(typeElement.getKind()).thenReturn(ElementKind.CLASS);
        // Set up type parameters and type mirror
        when(typeElement.getTypeParameters()).thenReturn(Collections.emptyList());
        // Create NEW Name mock for simple name
        Name simpleName = mock(Name.class);
        when(simpleName.toString()).thenReturn(className);
        when(typeElement.getSimpleName()).thenReturn(simpleName);
        // Create NEW Name mock for qualified name
        String qualifiedNameStr = packageName != null && !packageName.isEmpty()
                ? packageName + "." + className
                : className;
        Name qualifiedName = mock(Name.class);
        when(qualifiedName.toString()).thenReturn(qualifiedNameStr);
        when(typeElement.getQualifiedName()).thenReturn(qualifiedName);
        // Update package element
        if (packageName != null && !packageName.isEmpty()) {
            PackageElement packageElement =
                    mock(PackageElement.class);
            Name pkgName = mock(Name.class);
            when(pkgName.toString()).thenReturn(packageName);
            when(packageElement.getQualifiedName()).thenReturn(pkgName);
            when(typeElement.getEnclosingElement()).thenReturn(packageElement);
        } else {
            when(typeElement.getEnclosingElement()).thenReturn(null);
        }
        // Update JavaPoet visitor for ClassName - CRITICAL for correct class name generation
        DeclaredType typeMirror = mock(DeclaredType.class);
        when(typeMirror.accept(Mockito.any(), Mockito.any())).thenAnswer(invocation -> {
            String pkgName = packageName != null ? packageName : "";
            return ClassName.get(pkgName, className);
        });
        when(typeElement.asType()).thenReturn(typeMirror);
        when(typeMirror.getKind()).thenReturn(TypeKind.DECLARED);
        when(typeMirror.asElement()).thenReturn(typeElement);
        when(typeMirror.getTypeArguments()).thenReturn(Collections.emptyList());

        NoType noType = mock(NoType.class);
        when(noType.getKind()).thenReturn(TypeKind.NONE);
        when(typeMirror.getEnclosingType()).thenReturn(noType);

        // Parse the @Feature2JUnit annotation value from the base class
        Feature2JUnit feature2junit = BaseClassCodeParser.extractFeature2junitAnnotation(docString);
        if (feature2junit != null) {
            classInfo.feature2JUnitAnnotation = feature2junit;
            // Store the feature file path from the annotation for use in feature file setup
            annotatedFeatureFilePath = feature2junit.value();
        }
        when(typeElement.getAnnotation(Feature2JUnit.class)).thenReturn(feature2junit);
        Feature2JUnitOptions feature2JUnitOptions = BaseClassCodeParser.extractFeature2junitOptionsAnnotation(docString);
        if (feature2JUnitOptions != null) {
            classInfo.feature2JUnitOptions = feature2JUnitOptions;
        }
        when(typeElement.getAnnotation(Feature2JUnitOptions.class)).thenReturn(feature2JUnitOptions);

        // Set up superclass link to previous class in hierarchy
        if (baseClassHierarchy.size() > 1) {
            BaseClassInfo superClassInfo = baseClassHierarchy.get(baseClassHierarchy.size() - 2);
            TypeMirror superclassTypeMirror = superClassInfo.typeElement.asType();
            when(typeElement.getSuperclass()).thenReturn(superclassTypeMirror);
        } else {
            // No superclass in our hierarchy - return NoType indicating no superclass
            NoType noSuperclass = mock(NoType.class);
            when(noSuperclass.getKind()).thenReturn(TypeKind.NONE);
            when(typeElement.getSuperclass()).thenReturn(noSuperclass);
        }

        // If this class has @Feature2JUnit, it's the annotated class
        if (feature2junit != null) {
            // Get the annotation type element from annotationSetToProcess
            TypeElement feature2junitAnnotationType = annotationSetToProcess.iterator().next();

            // Update the roundEnv to return this element
            @SuppressWarnings("rawtypes")
            Set mockedAnnotatedElements = Set.of(typeElement);
            when(roundEnv.getElementsAnnotatedWith(feature2junitAnnotationType))
                    .thenReturn(mockedAnnotatedElements);
        }
    }

    //@Given("the following feature file:")
    public void the_following_feature_file(String docString) throws IOException {
        // Use the path from @Feature2JUnit annotation if available, otherwise use default
        String path = annotatedFeatureFilePath != null
                ? annotatedFeatureFilePath
                : "MockedAnnotatedTestClass.feature";
        featureFiles.put(path, docString);
        setupFeatureFileMocks();
    }

    //@Given("a feature file under path {string} with the following content:")
    public void a_feature_file_under_path_with_the_following_content(String path, String docString) throws IOException {
        featureFiles.put(path, docString);
        setupFeatureFileMocks();
    }

    private void setupFeatureFileMocks() throws IOException {

        Filer filer = processingEnvironment.getFiler();

        // Mock getResource to return different content based on the requested path
        when(filer.getResource(Mockito.any(), Mockito.any(), Mockito.any()))
                .thenAnswer(invocation -> {
                    String requestedPath = invocation.getArgument(2, String.class);

                    // Find matching feature file content
                    String content = featureFiles.get(requestedPath);

                    // If still not found and the requestedPath is explicitly specified (not null), throw FileNotFoundException
                    if (content == null && requestedPath != null && !requestedPath.isEmpty()) {
                        throw new FileNotFoundException("Feature file not found: " + requestedPath);
                    }

                    FileObject specFile = mock(FileObject.class);
                    String finalContent = content;
                    when(specFile.getCharContent(Mockito.anyBoolean())).thenReturn(finalContent);

                    return specFile;
                });
    }

    //@When("the generator is run")
    public void the_generator_is_run() {
        // Write code here that turns the phrase above into concrete actions
        //        throw new io.cucumber.java.PendingException();

        try {
            // Mock the pattern matcher to return test files
            if (!featureFiles.isEmpty()) {
                GlobPatternMatcher mockMatcher = mock(GlobPatternMatcher.class);

                // Mock findMatchingFiles to use our test utility for pattern matching
                when(mockMatcher.findMatchingFiles(Mockito.anyString())).thenAnswer(invocation -> {
                    String pattern = invocation.getArgument(0);
                    return TestPatternMatcher.matchFilesAgainstPattern(
                            new ArrayList<>(featureFiles.keySet()),
                            pattern
                    );
                });

                when(generator.createGlobPatternMatcher()).thenReturn(mockMatcher);
            }

            generator.process(annotationSetToProcess, roundEnv);
        } catch (Exception e) {
            // Store the exception for later verification in Then steps
            generatorException = e;
        }
    }

    //@Then("the content of the generated class should be:")
    public void the_content_of_the_generated_class_should_be(String docString) {
        // Write code here that turns the phrase above into concrete actions

        if (generatorException != null) {
            Assertions.fail("Expected the generator to complete without exceptions, but an exception was thrown: "
                    + generatorException.getMessage(), generatorException);
            generatorException.printStackTrace(System.err);
        }

        String generatedClass = generatedClassWriter.toString().trim();
        String expectedClass = docString.trim();

        // Verify that the generated code actually compiles (if enabled)
        if (verifyCompilation) {
            String generatedClassName = CompilationVerifier.extractFullyQualifiedClassName(generatedClass);
            if (generatedClassName != null) {
                // Create a map of source files to compile
                Map<String, String> sourceFiles = new HashMap<>();
                sourceFiles.put(generatedClassName, generatedClass);

                // Create stubs for all classes in the hierarchy
                if (baseClassHierarchy.isEmpty()) {
                    // No explicit base class setup - create stub for default MockedAnnotatedTestClass
                    // Include @Feature2JUnit annotation to match what the generator expects
                    String baseClassSource =
                            "import dev.specbinder.annotations.Feature2JUnit;\n\n" +
                                    "@Feature2JUnit(\"MockedAnnotatedTestClass.feature\")\n" +
                                    "public abstract class MockedAnnotatedTestClass {\n" +
                                    "}\n";
                    sourceFiles.put("MockedAnnotatedTestClass", baseClassSource);
                } else {
                    // Create complete stubs from source code for all classes in hierarchy
                    for (int i = 0; i < baseClassHierarchy.size(); i++) {
                        BaseClassInfo classInfo = baseClassHierarchy.get(i);

                        // Each class extends the previous one in insert order
                        String extendsClause = i > 0
                                ? " extends " + baseClassHierarchy.get(i - 1).className
                                : "";

                        String baseClassSource = BaseClassStubGenerator.createCompleteStub(
                                classInfo.sourceCode,
                                extendsClause);

                        String baseClassQualifiedName = classInfo.packageName != null && !classInfo.packageName.isEmpty()
                                ? classInfo.packageName + "." + classInfo.className
                                : classInfo.className;
                        sourceFiles.put(baseClassQualifiedName, baseClassSource);
                    }
                }

                // Compile all source files together
                CompilationVerifier.verifyCompilation(sourceFiles, currentFeatureFilePath);
            }

            // also compare the generated code textually
            Assertions.assertEquals(expectedClass, generatedClass);

        } else {
            // Simply compare the generated code textually
            Assertions.assertEquals(expectedClass, generatedClass);
        }
    }

    //@Then("the generator should report an error:")
    public void the_generator_should_report_an_error(String expectedErrorMessage) {
        // Verify that an exception was thrown during generator execution
        Assertions.assertNotNull(
                generatorException,
                "Expected the generator to throw an exception, but no exception was thrown"
        );

        String actualMessage = generatorException.getMessage();
        String expectedMessage = expectedErrorMessage.trim();

        Assertions.assertEquals(expectedMessage, actualMessage);
    }

    //@Then("{int} test classes should be generated")
    public void test_classes_should_be_generated(Integer expectedCount) {
        if (generatorException != null) {
            Assertions.fail("Expected the generator to complete without exceptions, but an exception was thrown: "
                    + generatorException.getMessage(), generatorException);
        }

        int actualCount = generatedClasses.size();
        Assertions.assertEquals(expectedCount, actualCount,
                "Expected " + expectedCount + " test classes but got " + actualCount + ". Generated classes: " + generatedClasses.keySet());
    }

    //@Then("a class named {string} should be generated with content:")
    public void a_class_named_should_be_generated_with_content(String className, String expectedContent) {
        if (generatorException != null) {
            Assertions.fail("Expected the generator to complete without exceptions, but an exception was thrown: "
                    + generatorException.getMessage(), generatorException);
        }

        Assertions.assertTrue(generatedClasses.containsKey(className),
                "Expected class '" + className + "' to be generated, but it was not found. Generated classes: " + generatedClasses.keySet());

        String actualContent = generatedClasses.get(className).trim();
        String expectedContentTrimmed = expectedContent.trim();

        Assertions.assertEquals(expectedContentTrimmed, actualContent);
    }

    /**
     * Creates ExecutableElement mocks for the given method names.
     *
     * @param methodNames the list of method names to create mocks for
     * @return a list of ExecutableElement mocks
     */
    private List<ExecutableElement> createMethodMocks(List<String> methodNames) {
        List<ExecutableElement> methodElements = new ArrayList<>();
        for (String methodName : methodNames) {
            ExecutableElement methodElement = mock(ExecutableElement.class);
            when(methodElement.getKind()).thenReturn(ElementKind.METHOD);
            when(methodElement.getModifiers()).thenReturn(new HashSet<>()); // Non-private
            Name methodNameMock = mock(Name.class);
            when(methodNameMock.toString()).thenReturn(methodName);
            when(methodElement.getSimpleName()).thenReturn(methodNameMock);
            methodElements.add(methodElement);
        }
        return methodElements;
    }

    /**
     * Creates a minimal stub for the base class that the generated code extends.
     * This allows the generated code to compile successfully.
     *
     * @param packageName the package name (can be null for default package)
     * @param className   the simple class name
     * @return the source code for the base class stub
     */
    private String createBaseClassStub(String packageName, String className) {
        StringBuilder stub = new StringBuilder();

        // Add package declaration if present
        if (packageName != null && !packageName.isEmpty()) {
            stub.append("package ").append(packageName).append(";\n\n");
        }

        // Create a minimal abstract class stub
        stub.append("public abstract class ").append(className).append(" {\n");
        stub.append("}\n");

        return stub.toString();
    }

}
