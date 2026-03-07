package dev.specbinder.feature2junit.utils;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Utility methods for supported feature file extensions.
 */
public final class FeatureFileExtensions {

    private FeatureFileExtensions() {
    }

    /**
     * Builds a glob wildcard pattern matching all given extensions.
     * Example: for extensions ["feature", "specb"] returns "*.{feature,specb}"
     * For a single extension ["specb"] returns "*.specb"
     *
     * @param extensions the extensions without leading dots
     * @return the glob pattern
     */
    public static String globWildcard(String[] extensions) {
        if (extensions.length == 1) {
            return "*." + extensions[0];
        }
        return "*.{" + String.join(",", extensions) + "}";
    }

    /**
     * Strips a known extension from the given filename.
     * Checks against the provided list of supported extensions.
     *
     * @param fileName   the filename to strip
     * @param extensions the supported extensions without leading dots
     * @return the filename without the extension, or the original if no supported extension found
     */
    public static String stripExtension(String fileName, String[] extensions) {
        for (String ext : extensions) {
            String dotExt = "." + ext;
            if (fileName.endsWith(dotExt)) {
                return fileName.substring(0, fileName.length() - dotExt.length());
            }
        }
        // Fallback: strip any extension (for explicit paths with arbitrary extensions)
        int lastDot = fileName.lastIndexOf('.');
        if (lastDot > 0) {
            return fileName.substring(0, lastDot);
        }
        return fileName;
    }

    /**
     * Returns the list of extensions with leading dots.
     *
     * @param extensions the extensions without leading dots
     * @return list of extensions with dots (e.g., [".feature", ".specb"])
     */
    public static List<String> withDots(String[] extensions) {
        return Arrays.stream(extensions)
                .map(ext -> "." + ext)
                .collect(Collectors.toList());
    }

    /**
     * Validates that the supported file extensions array is not empty and contains no blank values.
     *
     * @param extensions the extensions to validate
     * @throws IllegalArgumentException if validation fails
     */
    public static void validate(String[] extensions) {
        if (extensions == null || extensions.length == 0) {
            throw new IllegalArgumentException("supportedFileExtensions must not be empty");
        }
        for (String ext : extensions) {
            if (ext == null || ext.isBlank()) {
                throw new IllegalArgumentException("supportedFileExtensions must not contain blank values");
            }
        }
    }
}
