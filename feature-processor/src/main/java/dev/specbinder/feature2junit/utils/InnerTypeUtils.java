package dev.specbinder.feature2junit.utils;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.Element;
import javax.lang.model.element.ElementKind;
import javax.lang.model.element.ExecutableElement;
import javax.lang.model.element.Modifier;
import javax.lang.model.element.TypeElement;
import javax.lang.model.element.VariableElement;
import javax.lang.model.util.Elements;
import java.util.ArrayList;
import java.util.List;

/**
 * Utility class for finding and analyzing inner types (classes and records) in a class hierarchy.
 */
public class InnerTypeUtils {

    private InnerTypeUtils() {
        /**
         * utility class
         */
    }

    /**
     * Finds an inner type by name in the class hierarchy.
     * Searches the base type and all superclasses using Elements.getAllMembers().
     *
     * @param baseType the starting type to search
     * @param innerTypeName the simple name (e.g., "UsersParam")
     * @param processingEnv the processing environment
     * @return the TypeElement representing the inner type, or null if not found
     */
    public static TypeElement findInnerTypeInHierarchy(
            TypeElement baseType, String innerTypeName, ProcessingEnvironment processingEnv) {

        Elements elementUtils = processingEnv.getElementUtils();
        List<? extends Element> allMembers = elementUtils.getAllMembers(baseType);

        for (Element element : allMembers) {
            // Check if this is a class or record
            if (element.getKind() == ElementKind.CLASS ||
                element.getKind().name().equals("RECORD")) {

                // Check if it's an inner type (enclosed by a TypeElement)
                if (element.getEnclosingElement() instanceof TypeElement) {
                    // Check if name matches
                    if (element.getSimpleName().toString().equals(innerTypeName)) {
                        return (TypeElement) element;
                    }
                }
            }
        }

        return null;
    }

    /**
     * Checks if a type is a Java record.
     * Uses string comparison for compatibility with different Java versions.
     *
     * @param typeElement the type to check
     * @return true if the type is a record, false if it's a regular class
     */
    public static boolean isRecord(TypeElement typeElement) {
        return typeElement.getKind().name().equals("RECORD");
    }

    /**
     * Finds the all-args constructor for a class or record.
     * For records: finds constructor matching record component count
     * For classes: finds constructor matching private final field count
     *
     * @param typeElement the class or record type
     * @return the ExecutableElement for the constructor, or null if not found
     */
    public static ExecutableElement findAllArgsConstructor(TypeElement typeElement) {
        boolean isRecord = isRecord(typeElement);

        // Count expected parameters
        int expectedParamCount;
        if (isRecord) {
            expectedParamCount = countRecordComponents(typeElement);
        } else {
            expectedParamCount = countPrivateFinalFields(typeElement);
        }

        // Find constructor with matching parameter count
        List<? extends Element> enclosedElements = typeElement.getEnclosedElements();
        for (Element element : enclosedElements) {
            if (element.getKind() == ElementKind.CONSTRUCTOR) {
                ExecutableElement constructor = (ExecutableElement) element;

                // Skip private constructors
                if (constructor.getModifiers().contains(Modifier.PRIVATE)) {
                    continue;
                }

                if (constructor.getParameters().size() == expectedParamCount) {
                    return constructor;
                }
            }
        }

        return null;
    }

    /**
     * Extracts constructor parameter names in order.
     * For records: uses record component names
     * For classes: uses constructor parameter names
     *
     * @param constructor the constructor element
     * @param typeElement the type (needed for record component lookup)
     * @return ordered list of parameter names
     */
    public static List<String> getConstructorParameterNames(
            ExecutableElement constructor, TypeElement typeElement) {

        List<String> parameterNames = new ArrayList<>();

        if (isRecord(typeElement)) {
            // For records, use record component names (in order)
            List<? extends Element> enclosedElements = typeElement.getEnclosedElements();
            for (Element element : enclosedElements) {
                if (element.getKind().name().equals("RECORD_COMPONENT")) {
                    parameterNames.add(element.getSimpleName().toString());
                }
            }
        } else {
            // For classes, use constructor parameter names
            List<? extends VariableElement> parameters = constructor.getParameters();
            for (VariableElement param : parameters) {
                parameterNames.add(param.getSimpleName().toString());
            }
        }

        return parameterNames;
    }

    /**
     * Counts the number of record components in a record type.
     *
     * @param typeElement the record type
     * @return the number of record components
     */
    private static int countRecordComponents(TypeElement typeElement) {
        int count = 0;
        List<? extends Element> enclosedElements = typeElement.getEnclosedElements();
        for (Element element : enclosedElements) {
            if (element.getKind().name().equals("RECORD_COMPONENT")) {
                count++;
            }
        }
        return count;
    }

    /**
     * Counts the number of private final fields in a class.
     *
     * @param typeElement the class type
     * @return the number of private final fields
     */
    private static int countPrivateFinalFields(TypeElement typeElement) {
        int count = 0;
        List<? extends Element> enclosedElements = typeElement.getEnclosedElements();
        for (Element element : enclosedElements) {
            if (element.getKind() == ElementKind.FIELD) {
                if (element.getModifiers().contains(Modifier.PRIVATE) &&
                    element.getModifiers().contains(Modifier.FINAL)) {
                    count++;
                }
            }
        }
        return count;
    }
}
