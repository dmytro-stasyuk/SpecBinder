package dev.specbinder.feature2junit.gherkin.utils;

import java.util.LinkedHashSet;
import java.util.Set;

/**
 * Collects enum constants that need static imports during step processing.
 * Each entry contains the fully qualified enum type name and the constant name.
 */
public class EnumImportCollector {

    /**
     * Represents an enum constant that needs a static import.
     */
    public record EnumConstant(String enumQualifiedName, String constantName) {
    }

    private final Set<EnumConstant> enumConstants = new LinkedHashSet<>();

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
     */
    public Set<EnumConstant> getEnumConstants() {
        return enumConstants;
    }

    /**
     * Returns true if any enum constants have been collected.
     */
    public boolean hasEnumConstants() {
        return !enumConstants.isEmpty();
    }
}
