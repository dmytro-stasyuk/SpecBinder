package dev.specbinder.processor.steps;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Utility class for parsing Java source code to extract package names, class names, etc.
 */
public class JavaSourceParser {

    private JavaSourceParser() {
        // Utility class - prevent instantiation
    }

    /**
     * Extracts the package name from Java source code.
     * 
     * @param classContent the Java source code
     * @return the package name, or null if no package declaration is found
     */
    public static String extractPackageName(String classContent) {
        Pattern packagePattern = Pattern.compile("package\\s+([a-zA-Z_][a-zA-Z0-9_.]*);");
        Matcher matcher = packagePattern.matcher(classContent);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }

    /**
     * Extracts the class name from Java source code.
     * Supports class, interface, enum, and record declarations.
     * 
     * @param classContent the Java source code
     * @return the class name, or null if no type declaration is found
     */
    public static String extractClassName(String classContent) {
        // Look for class, interface, enum, or record declarations
        Pattern classPattern = Pattern.compile("(?:public\\s+)?(?:abstract\\s+)?(?:class|interface|enum|record)\\s+([a-zA-Z_][a-zA-Z0-9_]*)");
        Matcher matcher = classPattern.matcher(classContent);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }
}
