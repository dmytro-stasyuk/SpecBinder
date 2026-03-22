package dev.specbinder.processor.utils;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Utility class for working with Cucumber Expressions.
 * Supports converting Cucumber expressions to regex patterns, detecting whether
 * an annotation value is a Cucumber expression, and extracting parameter values.
 * <p>
 * Only built-in (default) parameter types are supported. Custom parameter types are not supported.
 */
public class CucumberExpressionUtils {

    private CucumberExpressionUtils() {
        // utility class
    }

    private static final Pattern CUCUMBER_PARAM_PATTERN = Pattern.compile("\\{(\\w*)\\}");

    private static final Map<String, String> PARAM_TYPE_REGEX = Map.ofEntries(
            Map.entry("int", "(-?\\d+)"),
            Map.entry("float", "(-?\\d*\\.\\d+)"),
            Map.entry("double", "(-?\\d*\\.\\d+)"),
            Map.entry("long", "(-?\\d+)"),
            Map.entry("byte", "(-?\\d+)"),
            Map.entry("short", "(-?\\d+)"),
            Map.entry("bigdecimal", "(-?\\d*\\.\\d+)"),
            Map.entry("biginteger", "(-?\\d+)"),
            Map.entry("word", "(\\S+)"),
            Map.entry("string", "(\"[^\"]*\"|'[^']*')"),
            Map.entry("", "(.+)")
    );

    /**
     * Checks if the given annotation value is a Cucumber expression.
     * A value is considered a Cucumber expression if it contains at least one
     * {@code {type}} placeholder where {@code type} is a recognized built-in parameter type
     * (or empty for anonymous {@code {}}).
     *
     * @param value the annotation value to check
     * @return true if the value is a Cucumber expression, false otherwise
     */
    public static boolean isCucumberExpression(String value) {
        Matcher matcher = CUCUMBER_PARAM_PATTERN.matcher(value);
        while (matcher.find()) {
            String typeName = matcher.group(1);
            if (PARAM_TYPE_REGEX.containsKey(typeName)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Converts a Cucumber expression to a regex pattern string.
     * Each {@code {type}} placeholder is replaced with the appropriate regex capture group.
     * Literal text between placeholders is escaped to prevent regex metacharacter issues.
     *
     * @param cucumberExpression the Cucumber expression
     * @return the equivalent regex pattern string (anchored with ^ and $)
     */
    public static String toRegex(String cucumberExpression) {
        Matcher matcher = CUCUMBER_PARAM_PATTERN.matcher(cucumberExpression);
        StringBuilder regex = new StringBuilder("^");
        int lastEnd = 0;

        while (matcher.find()) {
            String literal = cucumberExpression.substring(lastEnd, matcher.start());
            regex.append(Pattern.quote(literal));

            String typeName = matcher.group(1);
            String typeRegex = PARAM_TYPE_REGEX.getOrDefault(typeName, "(.+)");
            regex.append(typeRegex);

            lastEnd = matcher.end();
        }

        String remaining = cucumberExpression.substring(lastEnd);
        regex.append(Pattern.quote(remaining));
        regex.append("$");

        return regex.toString();
    }

    /**
     * Extracts the Cucumber parameter type names from the expression, in order.
     *
     * @param cucumberExpression the Cucumber expression
     * @return list of type names (e.g., ["string", "int", "float"]), empty string for anonymous {@code {}}
     */
    public static List<String> extractParameterTypeNames(String cucumberExpression) {
        List<String> types = new ArrayList<>();
        Matcher matcher = CUCUMBER_PARAM_PATTERN.matcher(cucumberExpression);
        while (matcher.find()) {
            types.add(matcher.group(1));
        }
        return types;
    }

    private static final Map<String, Class<?>> PARAM_TYPE_JAVA_CLASS = Map.ofEntries(
            Map.entry("int", int.class),
            Map.entry("float", float.class),
            Map.entry("double", double.class),
            Map.entry("long", long.class),
            Map.entry("byte", byte.class),
            Map.entry("short", short.class),
            Map.entry("bigdecimal", BigDecimal.class),
            Map.entry("biginteger", BigInteger.class),
            Map.entry("word", String.class),
            Map.entry("string", String.class),
            Map.entry("", String.class)
    );

    /**
     * Returns the Java class corresponding to the given Cucumber parameter type name.
     *
     * @param cucumberType the Cucumber parameter type name (e.g., "int", "string", "float")
     * @return the corresponding Java class
     */
    public static Class<?> toJavaClass(String cucumberType) {
        return PARAM_TYPE_JAVA_CLASS.getOrDefault(cucumberType, String.class);
    }

    /**
     * Extracts parameter values from the step text by matching against the Cucumber expression.
     * For {@code {string}} parameters, surrounding quotes are stripped from the extracted value.
     *
     * @param cucumberExpression the Cucumber expression
     * @param stepText the step text from the feature file
     * @return list of extracted parameter values, or empty list if no match
     */
    public static List<String> extractParameterValues(String cucumberExpression, String stepText) {
        String regex = toRegex(cucumberExpression);
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(stepText);

        if (!matcher.matches()) {
            return List.of();
        }

        List<String> types = extractParameterTypeNames(cucumberExpression);
        List<String> values = new ArrayList<>();

        for (int i = 0; i < types.size(); i++) {
            String rawValue = matcher.group(i + 1);
            String type = types.get(i);

            if ("string".equals(type) && rawValue != null && rawValue.length() >= 2) {
                rawValue = rawValue.substring(1, rawValue.length() - 1);
            }

            values.add(rawValue);
        }

        return values;
    }
}
