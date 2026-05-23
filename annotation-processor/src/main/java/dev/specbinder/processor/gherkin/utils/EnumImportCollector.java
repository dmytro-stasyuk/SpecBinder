package dev.specbinder.processor.gherkin.utils;

import java.util.LinkedHashSet;
import java.util.Set;

/**
 * Collects enum constants that need static imports during step processing.
 * Each entry contains the fully qualified enum type name and the constant name.
 */
public class EnumImportCollector {

    /**
     * Default constructor.
     */
    public EnumImportCollector() {
        /**
         * default constructor
         */
    }

    /**
     * Represents an enum constant that needs a static import.
     * @param enumQualifiedName the fully qualified name of the enum type
     * @param constantName the name of the enum constant
     */
    public record EnumConstant(String enumQualifiedName, String constantName) {
    }

    private final Set<EnumConstant> enumConstants = new LinkedHashSet<>();
    private final Set<String> enumTypes = new LinkedHashSet<>();
    private final Set<String> additionalImports = new LinkedHashSet<>();

    /**
     * Registers an enum constant that needs a static import.
     *
     * @param enumQualifiedName the fully qualified name of the enum type (e.g., "features.MyFeature.DayOfWeek")
     * @param constantName      the name of the enum constant (e.g., "MONDAY")
     */
    public void registerEnumConstant(String enumQualifiedName, String constantName) {
        enumConstants.add(new EnumConstant(enumQualifiedName, constantName));
    }

    /**
     * Returns all collected enum constants.
     * @return set of enum constants
     */
    public Set<EnumConstant> getEnumConstants() {
        return enumConstants;
    }

    /**
     * Returns true if any enum constants have been collected.
     * @return true if enum constants exist, false otherwise
     */
    public boolean hasEnumConstants() {
        return !enumConstants.isEmpty();
    }

    /**
     * Registers an enum type that needs a regular (non-static) import.
     * Used when useQualifiedEnumConstants is enabled.
     *
     * @param enumQualifiedName the fully qualified name of the enum type (e.g., "features.MyFeature.Status")
     */
    public void registerEnumType(String enumQualifiedName) {
        enumTypes.add(enumQualifiedName);
    }

    /**
     * Returns all collected enum types.
     * @return set of fully qualified enum type names
     */
    public Set<String> getEnumTypes() {
        return enumTypes;
    }

    /**
     * Returns true if any enum types have been collected.
     * @return true if enum types exist, false otherwise
     */
    public boolean hasEnumTypes() {
        return !enumTypes.isEmpty();
    }

    /**
     * Registers an arbitrary type that needs a regular (non-static) import in the generated
     * class. Used for types referenced by simple name from generated code (e.g., factory call
     * receivers for domain value object fields).
     *
     * @param qualifiedName the fully qualified name of the type (e.g., {@code "external.domain.Money"})
     */
    public void registerAdditionalImport(String qualifiedName) {
        additionalImports.add(qualifiedName);
    }

    /**
     * Returns all collected additional imports.
     * @return set of fully qualified type names
     */
    public Set<String> getAdditionalImports() {
        return additionalImports;
    }

    /**
     * Returns true if any additional imports have been collected.
     * @return true if additional imports exist, false otherwise
     */
    public boolean hasAdditionalImports() {
        return !additionalImports.isEmpty();
    }
}
