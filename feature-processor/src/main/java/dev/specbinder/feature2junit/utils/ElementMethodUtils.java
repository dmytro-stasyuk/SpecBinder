package dev.specbinder.feature2junit.utils;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.Element;
import javax.lang.model.element.ElementKind;
import javax.lang.model.element.ExecutableElement;
import javax.lang.model.element.Modifier;
import javax.lang.model.element.TypeElement;
import javax.lang.model.element.VariableElement;
import javax.lang.model.type.TypeMirror;
import javax.lang.model.util.Elements;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

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

}
