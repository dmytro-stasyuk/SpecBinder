package dev.specbinder.processor.utils;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.*;
import javax.lang.model.type.DeclaredType;
import javax.lang.model.type.TypeMirror;
import javax.lang.model.util.Elements;
import java.util.*;
import java.util.regex.Pattern;

/**
 * Utility class useful when working with base class's methods.
 */
public class ElementMethodUtils {

    private ElementMethodUtils() {
        /**
         * utility class
         */
    }

    /**
     * Represents a method signature consisting of a method name and its parameter types.
     * This class is used to uniquely identify methods and distinguish between overloaded methods
     * that share the same name but have different parameter types.
     */
    public static class MethodSignature {
        private final String methodName;
        private final List<TypeMirror> parameterTypes;

        /**
         * Constructs a new method signature.
         *
         * @param methodName the name of the method
         * @param parameterTypes the list of parameter types for this method signature
         */
        public MethodSignature(String methodName, List<TypeMirror> parameterTypes) {
            this.methodName = methodName;
            this.parameterTypes = parameterTypes;
        }

        /**
         * Returns the name of the method.
         *
         * @return the method name
         */
        public String getMethodName() {
            return methodName;
        }

        /**
         * Returns the list of parameter types for this method signature.
         *
         * @return the list of parameter types
         */
        public List<TypeMirror> getParameterTypes() {
            return parameterTypes;
        }

        /**
         * Returns the number of parameters in this method signature.
         *
         * @return the parameter count
         */
        public int getParameterCount() {
            return parameterTypes.size();
        }

        /**
         * Returns the parameter type at the specified index.
         *
         * @param index the zero-based index of the parameter
         * @return the parameter type at the specified index
         * @throws IndexOutOfBoundsException if the index is out of range
         */
        public TypeMirror getParameterType(int index) {
            return parameterTypes.get(index);
        }
    }

    /**
     * Gets all inherited method names from the specified base type, excluding private methods.
     * @param processingEnv the processing environment
     * @param baseType the base type element
     * @return a set of inherited method names
     */
    public static Set<String> getAllInheritedMethodNames(ProcessingEnvironment processingEnv, TypeElement baseType) {

        Elements elementUtils = processingEnv.getElementUtils();

        List<? extends Element> allMembers = elementUtils.getAllMembers(baseType);

        Set<String> baseClassMethodNames = new HashSet<>();

        allMembers.stream().filter(element ->
                element.getKind() == ElementKind.METHOD
                        && (element.getModifiers().isEmpty() || !element.getModifiers().contains(Modifier.PRIVATE))
        ).forEach(field -> {
            baseClassMethodNames.add(field.getSimpleName().toString());
        });

        return baseClassMethodNames;
    }

    /**
     * Gets all inherited executable elements (methods) from the specified base type, excluding private methods.
     * Returned elements preserve full APT detail (parameter annotations, modifiers, etc.) so callers can
     * inspect e.g. {@code @TempDir} annotations on individual parameters.
     *
     * @param processingEnv the processing environment
     * @param baseType the base type element
     * @return a map of method names to lists of executable elements (a method can have multiple overloads)
     */
    public static Map<String, List<ExecutableElement>> getAllInheritedExecutables(
            ProcessingEnvironment processingEnv, TypeElement baseType) {

        Elements elementUtils = processingEnv.getElementUtils();

        List<? extends Element> allMembers = elementUtils.getAllMembers(baseType);

        Map<String, List<ExecutableElement>> result = new HashMap<>();

        allMembers.stream()
                .filter(element ->
                        element.getKind() == ElementKind.METHOD
                                && (element.getModifiers().isEmpty() || !element.getModifiers().contains(Modifier.PRIVATE))
                )
                .forEach(element -> {
                    ExecutableElement method = (ExecutableElement) element;
                    String methodName = method.getSimpleName().toString();
                    result.computeIfAbsent(methodName, k -> new ArrayList<>()).add(method);
                });

        return result;
    }

    /**
     * Gets all inherited methods with their parameter types from the specified base type, excluding private methods.
     * @param processingEnv the processing environment
     * @param baseType the base type element
     * @return a map of method names to lists of method signatures (a method can have multiple overloads)
     */
    public static Map<String, List<MethodSignature>> getAllInheritedMethodSignatures(
            ProcessingEnvironment processingEnv, TypeElement baseType) {

        Elements elementUtils = processingEnv.getElementUtils();

        List<? extends Element> allMembers = elementUtils.getAllMembers(baseType);

        Map<String, List<MethodSignature>> methodSignatures = new HashMap<>();

        allMembers.stream()
                .filter(element ->
                        element.getKind() == ElementKind.METHOD
                                && (element.getModifiers().isEmpty() || !element.getModifiers().contains(Modifier.PRIVATE))
                )
                .forEach(element -> {
                    ExecutableElement method = (ExecutableElement) element;
                    String methodName = method.getSimpleName().toString();

                    List<TypeMirror> parameterTypes = new ArrayList<>();
                    for (VariableElement param : method.getParameters()) {
                        parameterTypes.add(param.asType());
                    }

                    MethodSignature signature = new MethodSignature(methodName, parameterTypes);

                    methodSignatures.computeIfAbsent(methodName, k -> new ArrayList<>()).add(signature);
                });

        return methodSignatures;
    }

    /**
     * Checks if a type is a List with a custom object type argument (not a standard Java type).
     *
     * @param typeMirror the type to check
     * @param processingEnv the processing environment
     * @return true if the type is List&lt;CustomType&gt;, false otherwise
     */
    public static boolean isListOfCustomObjectType(TypeMirror typeMirror, ProcessingEnvironment processingEnv) {
        if (!(typeMirror instanceof DeclaredType declaredType)) {
            return false;
        }

        Element element = declaredType.asElement();
        String qualifiedName = ((TypeElement) element).getQualifiedName().toString();

        // Check if it's java.util.List
        if (!qualifiedName.equals("java.util.List")) {
            return false;
        }

        // Check if it has exactly one type argument
        List<? extends TypeMirror> typeArgs = declaredType.getTypeArguments();
        if (typeArgs.size() != 1) {
            return false;
        }

        // Check if the type argument is a custom object (not a standard Java type)
        TypeMirror typeArg = typeArgs.get(0);
        if (!(typeArg instanceof DeclaredType argDeclaredType)) {
            return false;
        }

        Element argElement = argDeclaredType.asElement();
        if (!(argElement instanceof TypeElement typeElement)) {
            return false;
        }

        String argQualifiedName = typeElement.getQualifiedName().toString();

        // Exclude standard Java types like String, Map, etc.
        return !argQualifiedName.startsWith("java.");
    }

    /**
     * Extracts the TypeElement of the generic type argument from a List&lt;T&gt; type.
     *
     * @param typeMirror the List type (e.g., List&lt;UserParam&gt;)
     * @return the TypeElement of T, or null if not a valid List&lt;T&gt; type
     */
    public static TypeElement extractListTypeArgument(TypeMirror typeMirror) {
        if (!(typeMirror instanceof DeclaredType declaredType)) {
            return null;
        }

        Element element = declaredType.asElement();
        if (!(element instanceof TypeElement typeElement)) {
            return null;
        }

        String qualifiedName = typeElement.getQualifiedName().toString();
        if (!qualifiedName.equals("java.util.List")) {
            return null;
        }

        List<? extends TypeMirror> typeArgs = declaredType.getTypeArguments();
        if (typeArgs.size() != 1) {
            return null;
        }

        TypeMirror typeArg = typeArgs.get(0);
        if (!(typeArg instanceof DeclaredType argDeclaredType)) {
            return null;
        }

        Element argElement = argDeclaredType.asElement();
        if (!(argElement instanceof TypeElement)) {
            return null;
        }

        return (TypeElement) argElement;
    }

    private static final Set<String> CUCUMBER_STEP_ANNOTATION_TYPES = Set.of(
            "io.cucumber.java.en.Given",
            "io.cucumber.java.en.When",
            "io.cucumber.java.en.Then"
    );

    /**
     * Holds information about a Cucumber annotation match entry, including the compiled regex
     * pattern, the method name, and the original Cucumber expression (if applicable).
     *
     * @param pattern the compiled regex pattern for matching step text
     * @param methodName the name of the annotated method
     * @param cucumberExpression the original Cucumber expression (null for regex-based entries)
     */
    public record CucumberAnnotationEntry(
            Pattern pattern,
            String methodName,
            String cucumberExpression
    ) {
        /**
         * Returns {@code true} if this entry was derived from a Cucumber expression
         * (e.g. {@code "I have {int} items"}) rather than a raw regex pattern.
         * @return true if this entry is based on a Cucumber expression, false if it's based on a raw regex
         */
        public boolean isCucumberExpression() {
            return cucumberExpression != null;
        }
    }

    /**
     * Builds a list of Cucumber annotation entries by scanning Cucumber step annotations
     * ({@code @Given}, {@code @When}, {@code @Then}) on methods in the base class hierarchy.
     * <p>
     * Annotation values are handled as follows:
     * <ul>
     *     <li>If the value is a Cucumber expression (contains {@code {type}} placeholders),
     *         it is converted to a regex pattern using {@link CucumberExpressionUtils}</li>
     *     <li>Otherwise, the value is compiled directly as a Java regex pattern</li>
     * </ul>
     *
     * @param processingEnv the processing environment
     * @param baseType the base type element to scan
     * @return a list of annotation entries for step matching
     */
    public static List<CucumberAnnotationEntry> getCucumberAnnotationStepEntries(
            ProcessingEnvironment processingEnv, TypeElement baseType) {

        Elements elementUtils = processingEnv.getElementUtils();
        List<? extends Element> allMembers = elementUtils.getAllMembers(baseType);
        List<CucumberAnnotationEntry> entries = new ArrayList<>();

        allMembers.stream()
                .filter(element ->
                        element.getKind() == ElementKind.METHOD
                                && (element.getModifiers().isEmpty() || !element.getModifiers().contains(Modifier.PRIVATE))
                )
                .forEach(element -> {
                    ExecutableElement method = (ExecutableElement) element;
                    String methodName = method.getSimpleName().toString();

                    for (AnnotationMirror mirror : method.getAnnotationMirrors()) {
                        String annotationType = mirror.getAnnotationType().toString();
                        if (!CUCUMBER_STEP_ANNOTATION_TYPES.contains(annotationType)) {
                            continue;
                        }

                        for (Map.Entry<? extends ExecutableElement, ? extends AnnotationValue> entry :
                                mirror.getElementValues().entrySet()) {
                            if ("value".equals(entry.getKey().getSimpleName().toString())) {
                                String annotationValue = (String) entry.getValue().getValue();

                                if (CucumberExpressionUtils.isCucumberExpression(annotationValue)) {
                                    String regex = CucumberExpressionUtils.toRegex(annotationValue);
                                    Pattern compiledPattern = Pattern.compile(regex);
                                    entries.add(new CucumberAnnotationEntry(compiledPattern, methodName, annotationValue));
                                } else {
                                    Pattern compiledPattern = Pattern.compile(annotationValue);
                                    entries.add(new CucumberAnnotationEntry(compiledPattern, methodName, null));
                                }
                            }
                        }
                    }
                });

        return entries;
    }

}
