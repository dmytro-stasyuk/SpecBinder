package dev.specbinder.feature2junit.steps;

import dev.specbinder.annotations.Feature2JUnit;
import dev.specbinder.annotations.Feature2JUnitOptions;
import dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE;
import dev.specbinder.feature2junit.config.GeneratorOptions;
import org.mockito.Mockito;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Utility class for parsing and extracting information from base class code snippets.
 * Used by Cucumber step definitions to extract annotation values, package names, class names,
 * and configuration options from Java code provided in feature file scenarios.
 */
class BaseClassCodeParser {

    private BaseClassCodeParser() {
        // Utility class, prevent instantiation
    }

    public static Feature2JUnit extractFeature2junitAnnotation(String classString) {

        // Check if @Feature2JUnit annotation exists at all
        Pattern annotationExistsPattern = Pattern.compile("@Feature2JUnit");
        if (!annotationExistsPattern.matcher(classString).find()) {
            return null; // No annotation found
        }

        // Extract explicit @Feature2JUnit annotation value from the class string
        String annotationValue = extractFeature2JUnitValue(classString);

        // Check if this is explicitly requesting convention-based discovery (empty parentheses or no value)
        // by looking for @Feature2JUnit() or @Feature2JUnit with no parentheses followed by whitespace/newline
        if (annotationValue == null) {
            // Check if the annotation has empty parentheses: @Feature2JUnit()
            Pattern emptyParenthesesPattern = Pattern.compile("@Feature2JUnit\\s*\\(\\s*\\)");
            // Check if the annotation has no parentheses at all: @Feature2JUnit followed by whitespace or newline
            Pattern noParenthesesPattern = Pattern.compile("@Feature2JUnit(?!\\s*\\()");

            if (emptyParenthesesPattern.matcher(classString).find() ||
                noParenthesesPattern.matcher(classString).find()) {
                // Return empty string to trigger convention-based discovery
                annotationValue = "";
            } else {
                // Old behavior: construct default path from package and class name
                String packageName = extractPackageName(classString);
                String className = extractClassName(classString);

                if (className == null) {
                    return null; // Can't construct path without class name
                }

                // Construct default path: package/path/ClassName.feature
                if (packageName != null && !packageName.isEmpty()) {
                    annotationValue = packageName.replace('.', '/') + "/" + className + ".feature";
                } else {
                    annotationValue = className + ".feature";
                }
            }
        }

        Feature2JUnit f2j = Mockito.mock(Feature2JUnit.class);
        Mockito.when(f2j.value()).thenReturn(annotationValue);
        return f2j;
    }

    public static Feature2JUnitOptions extractFeature2junitOptionsAnnotation(String classString) {

        // Check if @Feature2JUnitOptions annotation exists in the class string
        Pattern annotationPattern = Pattern.compile(
                "@Feature2JUnitOptions\\s*\\(",
                Pattern.DOTALL
        );
        Matcher annotationMatcher = annotationPattern.matcher(classString);

        if (!annotationMatcher.find()) {
            return null; // No annotation found
        }

        // Create mock with default values
        Feature2JUnitOptions options = Mockito.mock(Feature2JUnitOptions.class);
        GeneratorOptions defaultOptions = new GeneratorOptions();

        // Set default values from GeneratorOptions
        Mockito.when(options.shouldBeAbstract()).thenReturn(defaultOptions.isShouldBeAbstract());
        Mockito.when(options.classSuffixIfConcrete()).thenReturn(defaultOptions.getClassSuffixIfConcrete());
        Mockito.when(options.classSuffixIfAbstract()).thenReturn(defaultOptions.getClassSuffixIfAbstract());
        Mockito.when(options.addSourceLineAnnotations()).thenReturn(defaultOptions.isAddSourceLineAnnotations());
        Mockito.when(options.addSourceLineBeforeStepCalls()).thenReturn(defaultOptions.isAddSourceLineBeforeStepCalls());
        Mockito.when(options.failScenariosWithNoSteps()).thenReturn(defaultOptions.isFailScenariosWithNoSteps());
        Mockito.when(options.failRulesWithNoScenarios()).thenReturn(defaultOptions.isFailRulesWithNoScenarios());
        Mockito.when(options.tagForScenariosWithNoSteps()).thenReturn(defaultOptions.getTagForScenariosWithNoSteps());
        Mockito.when(options.tagForRulesWithNoScenarios()).thenReturn(defaultOptions.getTagForRulesWithNoScenarios());
        Mockito.when(options.addCucumberStepAnnotations()).thenReturn(defaultOptions.isAddCucumberStepAnnotations());
        Mockito.when(options.enableCompositeSteps()).thenReturn(defaultOptions.isEnableCompositeSteps());
        Mockito.when(options.dataTableParameterType()).thenReturn(
                DATA_TABLE_PARAMETER_TYPE.valueOf(defaultOptions.getDataTableParameterType()));

        // Override with values from annotation if present
        Boolean shouldBeAbstract = extractBooleanOption(classString, "shouldBeAbstract");
        if (shouldBeAbstract != null) {
            Mockito.when(options.shouldBeAbstract()).thenReturn(shouldBeAbstract);
        }

        String classSuffixIfConcrete = extractStringOption(classString, "classSuffixIfConcrete");
        if (classSuffixIfConcrete != null) {
            Mockito.when(options.classSuffixIfConcrete()).thenReturn(classSuffixIfConcrete);
        }

        String classSuffixIfAbstract = extractStringOption(classString, "classSuffixIfAbstract");
        if (classSuffixIfAbstract != null) {
            Mockito.when(options.classSuffixIfAbstract()).thenReturn(classSuffixIfAbstract);
        }

        Boolean addSourceLineAnnotations = extractBooleanOption(classString, "addSourceLineAnnotations");
        if (addSourceLineAnnotations != null) {
            Mockito.when(options.addSourceLineAnnotations()).thenReturn(addSourceLineAnnotations);
        }

        Boolean addSourceLineBeforeStepCalls = extractBooleanOption(classString, "addSourceLineBeforeStepCalls");
        if (addSourceLineBeforeStepCalls != null) {
            Mockito.when(options.addSourceLineBeforeStepCalls()).thenReturn(addSourceLineBeforeStepCalls);
        }

        Boolean failScenariosWithNoSteps = extractBooleanOption(classString, "failScenariosWithNoSteps");
        if (failScenariosWithNoSteps != null) {
            Mockito.when(options.failScenariosWithNoSteps()).thenReturn(failScenariosWithNoSteps);
        }

        Boolean failRulesWithNoScenarios = extractBooleanOption(classString, "failRulesWithNoScenarios");
        if (failRulesWithNoScenarios != null) {
            Mockito.when(options.failRulesWithNoScenarios()).thenReturn(failRulesWithNoScenarios);
        }

        String tagForScenariosWithNoSteps = extractStringOption(classString, "tagForScenariosWithNoSteps");
        if (tagForScenariosWithNoSteps != null) {
            Mockito.when(options.tagForScenariosWithNoSteps()).thenReturn(tagForScenariosWithNoSteps);
        }

        String tagForRulesWithNoScenarios = extractStringOption(classString, "tagForRulesWithNoScenarios");
        if (tagForRulesWithNoScenarios != null) {
            Mockito.when(options.tagForRulesWithNoScenarios()).thenReturn(tagForRulesWithNoScenarios);
        }

        Boolean addCucumberStepAnnotations = extractBooleanOption(classString, "addCucumberStepAnnotations");
        if (addCucumberStepAnnotations != null) {
            Mockito.when(options.addCucumberStepAnnotations()).thenReturn(addCucumberStepAnnotations);
        }

        Boolean enableCompositeSteps = extractBooleanOption(classString, "enableCompositeSteps");
        if (enableCompositeSteps != null) {
            Mockito.when(options.enableCompositeSteps()).thenReturn(enableCompositeSteps);
        }

        DATA_TABLE_PARAMETER_TYPE dataTableParameterType = extractEnumOption(classString, "dataTableParameterType", DATA_TABLE_PARAMETER_TYPE.class);
        if (dataTableParameterType != null) {
            Mockito.when(options.dataTableParameterType()).thenReturn(dataTableParameterType);
        }

        return options;
    }

    private static String extractFeature2JUnitValue(String classString) {
        // Look for @Feature2JUnit("value") or @Feature2JUnit(value = "value")
        Pattern pattern = Pattern.compile(
                "@Feature2JUnit\\s*\\(\\s*(?:value\\s*=\\s*)?\"([^\"]+)\"\\s*\\)"
        );
        Matcher matcher = pattern.matcher(classString);

        if (matcher.find()) {
            return matcher.group(1);
        }

        return null;
    }

    /**
     * Extracts the feature file path from @Feature2JUnit annotation in the base class code.
     *
     * @param baseClassCode the Java code containing the annotation
     * @return the extracted path, empty string if annotation exists without value, or null if not found
     */
    public static String extractFeature2JUnitPath(String baseClassCode) {
        // Extract the path from @Feature2JUnit("path/to/file.feature")
        // or detect @Feature2JUnit without parentheses (default value)
        String patternWithValue = "@Feature2JUnit\\(\"([^\"]+)\"\\)";
        Pattern regexWithValue = Pattern.compile(patternWithValue);
        Matcher matcherWithValue = regexWithValue.matcher(baseClassCode);

        if (matcherWithValue.find()) {
            return matcherWithValue.group(1);
        }

        // Check if @Feature2JUnit exists without parentheses or with empty value
        String patternNoValue = "@Feature2JUnit(?:\\(\\)|(?![\\(]))";
        Pattern regexNoValue = Pattern.compile(patternNoValue);
        if (regexNoValue.matcher(baseClassCode).find()) {
            return ""; // Return empty string to trigger path construction
        }

        return null;
    }

    /**
     * Extracts the package name from the base class code.
     *
     * @param baseClassCode the Java code containing the package declaration
     * @return the extracted package name, or null if not found
     */
    public static String extractPackageName(String baseClassCode) {
        // Extract the package name from "package com.example.foo;"
        String pattern = "package\\s+([\\w.]+)\\s*;";
        Pattern regex = Pattern.compile(pattern);
        Matcher matcher = regex.matcher(baseClassCode);

        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }

    /**
     * Extracts the class name from the base class code.
     *
     * @param baseClassCode the Java code containing the class declaration
     * @return the extracted class name, or null if not found
     */
    public static String extractClassName(String baseClassCode) {
        // Extract the class name from patterns like:
        // "public class FeatureTestBase" or "public abstract class FeatureTestBase"
        String pattern = "(?:public|private|protected)?\\s*(?:abstract)?\\s*class\\s+(\\w+)";
        Pattern regex = Pattern.compile(pattern);
        Matcher matcher = regex.matcher(baseClassCode);

        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }

    /**
     * Extracts a boolean option value from @Feature2JUnitOptions annotation.
     *
     * @param code the Java code containing the annotation
     * @param optionName the name of the boolean option to extract
     * @return the extracted boolean value, or null if not found
     */
    public static Boolean extractBooleanOption(String code, String optionName) {
        // Extract boolean option like: shouldBeAbstract = true
        // Pattern handles multi-line formatting with DOTALL flag
        String pattern = optionName + "\\s*=\\s*(true|false)";
        Pattern regex = Pattern.compile(pattern, Pattern.DOTALL);
        Matcher matcher = regex.matcher(code);

        if (matcher.find()) {
            return Boolean.parseBoolean(matcher.group(1));
        }
        return null;
    }

    /**
     * Extracts a string option value from @Feature2JUnitOptions annotation.
     *
     * @param code the Java code containing the annotation
     * @param optionName the name of the string option to extract
     * @return the extracted string value, or null if not found
     */
    public static String extractStringOption(String code, String optionName) {
        // Extract string option like: classSuffixIfAbstract = "TestCases"
        // Pattern handles multi-line formatting with DOTALL flag
        String pattern = optionName + "\\s*=\\s*\"([^\"]+)\"";
        Pattern regex = Pattern.compile(pattern, Pattern.DOTALL);
        Matcher matcher = regex.matcher(code);

        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }

    /**
     * Extracts an enum option value from @Feature2JUnitOptions annotation.
     *
     * @param code the Java code containing the annotation
     * @param optionName the name of the enum option to extract
     * @param enumClass the enum class to parse the value into
     * @param <T> the enum type
     * @return the extracted enum value, or null if not found
     */
    public static <T extends Enum<T>> T extractEnumOption(String code, String optionName, Class<T> enumClass) {
        // Extract enum option like: dataTableParameterType = DataTableParameterStyle.LIST_OF_MAPS
        // Pattern handles both fully qualified and simple enum constant names
        String pattern = optionName + "\\s*=\\s*(?:[\\w.]+\\.)?([A-Z_]+)";
        Pattern regex = Pattern.compile(pattern, Pattern.DOTALL);
        Matcher matcher = regex.matcher(code);

        if (matcher.find()) {
            String enumValue = matcher.group(1);
            try {
                return Enum.valueOf(enumClass, enumValue);
            } catch (IllegalArgumentException e) {
                return null;
            }
        }
        return null;
    }

    /**
     * Extracts method names from the base class code.
     * Looks for method declarations like: protected Type methodName(...)
     *
     * @param baseClassCode the Java code containing method declarations
     * @return a list of method names found in the code
     */
    public static java.util.List<String> extractMethodNames(String baseClassCode) {
        java.util.List<String> methodNames = new java.util.ArrayList<>();

        // Pattern to match method declarations:
        // - Optional modifiers (public, protected, private, static, abstract, etc.)
        // - Return type (can be generic like DataTable.TableConverter or simple like DataTable or void)
        // - Method name
        // - Opening parenthesis for parameters
        String pattern = "(?:public|protected|private)?\\s*(?:static)?\\s*(?:abstract)?\\s*([\\w.<>]+(?:\\[\\])?(?:\\.\\w+)?)\\s+(\\w+)\\s*\\(";
        Pattern regex = Pattern.compile(pattern);
        Matcher matcher = regex.matcher(baseClassCode);

        while (matcher.find()) {
            String methodName = matcher.group(2);
            // Filter out constructors (method name same as class name)
            String className = extractClassName(baseClassCode);
            if (className == null || !methodName.equals(className)) {
                methodNames.add(methodName);
            }
        }

        return methodNames;
    }
}
