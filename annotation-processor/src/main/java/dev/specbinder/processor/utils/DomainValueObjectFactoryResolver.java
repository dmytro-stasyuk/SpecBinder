package dev.specbinder.processor.utils;

import javax.lang.model.element.*;
import javax.lang.model.type.DeclaredType;
import javax.lang.model.type.TypeKind;
import javax.lang.model.type.TypeMirror;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

/**
 * Resolves the static factory method to use when wrapping a Gherkin data table cell value
 * for a parameter class field whose declared type is a non-enum domain value object
 * (e.g., {@code Money}, {@code Email}, {@code Quantity}).
 */
public final class DomainValueObjectFactoryResolver {

    private static final Set<String> BUILT_IN_CONVERTIBLE_TYPES = Set.of(
            "java.lang.String",
            "java.lang.Boolean",
            "java.lang.Character",
            "java.lang.Byte",
            "java.lang.Short",
            "java.lang.Integer",
            "java.lang.Long",
            "java.lang.Float",
            "java.lang.Double",
            "java.math.BigDecimal",
            "java.math.BigInteger"
    );

    private DomainValueObjectFactoryResolver() {
        // utility class
    }

    /**
     * Resolution result: a single factory method to call, or {@code null} if no suitable
     * factory method exists or the resolution is ambiguous.
     *
     * @param factory   the resolved factory method
     * @param paramType the factory method's single parameter type, used to render the cell value
     */
    public record Resolution(ExecutableElement factory, TypeMirror paramType) {
    }

    /**
     * Attempts to resolve a static factory method on {@code targetType} suitable for wrapping
     * a cell value.
     *
     * @param targetType             the declared field type of the parameter class
     * @param inferredColumnTypeName the inferred Gherkin column type name
     *                               (one of "Boolean", "Integer", "Long", "Double", "Character",
     *                               "String"), or {@code null} when not available
     * @return the resolved factory method, or {@code null} when the target type is not a
     * non-enum declared domain type, no suitable factory exists, or the disambiguation
     * rules cannot pick exactly one factory method
     */
    public static Resolution resolve(TypeMirror targetType, String inferredColumnTypeName) {
        if (targetType == null || targetType.getKind() != TypeKind.DECLARED) {
            return null;
        }
        DeclaredType declaredType = (DeclaredType) targetType;
        Element element = declaredType.asElement();
        if (element.getKind() == ElementKind.ENUM) {
            return null;
        }
        if (!(element instanceof TypeElement typeElement)) {
            return null;
        }
        String qualifiedName = typeElement.getQualifiedName().toString();
        if (BUILT_IN_CONVERTIBLE_TYPES.contains(qualifiedName)) {
            return null;
        }

        List<ExecutableElement> suitableFactories = findSuitableFactoryMethods(typeElement);
        if (suitableFactories.isEmpty()) {
            return null;
        }
        if (suitableFactories.size() == 1) {
            ExecutableElement single = suitableFactories.get(0);
            return new Resolution(single, single.getParameters().get(0).asType());
        }

        List<ExecutableElement> matchingByInferredType = new ArrayList<>();
        for (ExecutableElement factory : suitableFactories) {
            TypeMirror paramType = factory.getParameters().get(0).asType();
            if (matchesInferredType(paramType, inferredColumnTypeName)) {
                matchingByInferredType.add(factory);
            }
        }
        if (matchingByInferredType.size() == 1) {
            ExecutableElement picked = matchingByInferredType.get(0);
            return new Resolution(picked, picked.getParameters().get(0).asType());
        }

        List<ExecutableElement> stringFactories = new ArrayList<>();
        for (ExecutableElement factory : suitableFactories) {
            TypeMirror paramType = factory.getParameters().get(0).asType();
            if ("java.lang.String".equals(paramType.toString())) {
                stringFactories.add(factory);
            }
        }
        if (stringFactories.size() == 1) {
            ExecutableElement picked = stringFactories.get(0);
            return new Resolution(picked, picked.getParameters().get(0).asType());
        }

        return null;
    }

    private static List<ExecutableElement> findSuitableFactoryMethods(TypeElement typeElement) {
        List<ExecutableElement> result = new ArrayList<>();
        for (Element enclosed : typeElement.getEnclosedElements()) {
            if (enclosed.getKind() != ElementKind.METHOD) {
                continue;
            }
            ExecutableElement method = (ExecutableElement) enclosed;
            if (method.getModifiers().contains(Modifier.PRIVATE)) {
                continue;
            }
            if (!method.getModifiers().contains(Modifier.STATIC)) {
                continue;
            }
            if (method.getParameters().size() != 1) {
                continue;
            }
            TypeMirror returnType = method.getReturnType();
            if (returnType.getKind() != TypeKind.DECLARED) {
                continue;
            }
            DeclaredType declaredReturnType = (DeclaredType) returnType;
            if (!declaredReturnType.asElement().equals(typeElement)) {
                continue;
            }
            result.add(method);
        }
        return result;
    }

    private static boolean matchesInferredType(TypeMirror paramType, String inferredColumnTypeName) {
        if (inferredColumnTypeName == null) {
            return false;
        }
        TypeKind kind = paramType.getKind();
        String typeName = paramType.toString();
        return switch (inferredColumnTypeName) {
            case "Boolean" -> kind == TypeKind.BOOLEAN || "java.lang.Boolean".equals(typeName);
            case "Integer" -> kind == TypeKind.INT || "java.lang.Integer".equals(typeName);
            case "Long" -> kind == TypeKind.LONG || "java.lang.Long".equals(typeName);
            case "Double" -> kind == TypeKind.DOUBLE || "java.lang.Double".equals(typeName);
            case "Character" -> kind == TypeKind.CHAR || "java.lang.Character".equals(typeName);
            case "String" -> "java.lang.String".equals(typeName);
            default -> false;
        };
    }
}
