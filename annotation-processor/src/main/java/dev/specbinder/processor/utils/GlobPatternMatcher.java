package dev.specbinder.processor.utils;

import dev.specbinder.processor.support.LoggingSupport;

import javax.annotation.processing.Filer;
import javax.annotation.processing.ProcessingEnvironment;
import javax.tools.FileObject;
import javax.tools.StandardLocation;
import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Utility class for detecting glob patterns and finding matching files.
 */
public class GlobPatternMatcher implements LoggingSupport {

    private final ProcessingEnvironment processingEnv;

    /**
     * Creates a new GlobPatternMatcher.
     * @param processingEnv the processing environment
     */
    public GlobPatternMatcher(ProcessingEnvironment processingEnv) {
        this.processingEnv = processingEnv;
    }

    /**
     * Returns the processing environment.
     * @return the processing environment
     */
    @Override
    public ProcessingEnvironment getProcessingEnv() {
        return processingEnv;
    }

    /**
     * Checks if a path contains glob pattern characters.
     *
     * @param path the path to check
     * @return true if the path contains glob patterns (* or **), false otherwise
     */
    public static boolean isGlobPattern(String path) {
        return path != null && (path.contains("*") || path.contains("?") || path.contains("[") || path.contains("{"));
    }

    /**
     * Finds all files matching the given glob pattern.
     *
     * @param globPattern the glob pattern to match (e.g., "features/**​/*.feature")
     * @return list of file paths relative to the classpath that match the pattern
     * @throws IOException if an error occurs while searching for files
     */
    public List<String> findMatchingFiles(String globPattern) throws IOException {
        List<String> matchingFiles = new ArrayList<>();

        // Try to get a base path to search from by using a known resource
        Filer filer = processingEnv.getFiler();

        // Find the classpath root by trying to access a resource
        Path searchRoot = findClasspathRoot(filer);

        if (searchRoot == null) {
            logWarning("Could not determine classpath root for pattern matching");
            return matchingFiles;
        }

        logVerbose("Searching for files matching pattern: " + globPattern + " from root: " + searchRoot);

        // Convert glob pattern to PathMatcher
        FileSystem fs = FileSystems.getDefault();
        PathMatcher matcher = fs.getPathMatcher("glob:" + globPattern);

        // Walk the file tree and find matching files
        Files.walkFileTree(searchRoot, new SimpleFileVisitor<Path>() {
            @Override
            public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) {
                // Get path relative to search root
                Path relativePath = searchRoot.relativize(file);
                String relativePathString = relativePath.toString().replace(File.separator, "/");

                // Check if it matches the pattern
                if (matcher.matches(relativePath) || relativePathString.matches(convertGlobToRegex(globPattern))) {
                    matchingFiles.add(relativePathString);
                    logVerbose("Found matching file: " + relativePathString);
                }

                return FileVisitResult.CONTINUE;
            }

            @Override
            public FileVisitResult visitFileFailed(Path file, IOException exc) {
                // Continue even if we can't access a file
                return FileVisitResult.CONTINUE;
            }
        });

        Collections.sort(matchingFiles);

        logVerbose("Found " + matchingFiles.size() + " files matching pattern: " + globPattern);

        return matchingFiles;
    }

    /**
     * Attempts to find the classpath root directory by probing for known resource locations.
     */
    private Path findClasspathRoot(Filer filer) {
        try {
            // Try to get any resource to determine the classpath root
            // We'll try a few common locations
            FileObject dummyResource = null;

            try {
                // Try to get the CLASS_OUTPUT location
                dummyResource = filer.getResource(StandardLocation.CLASS_OUTPUT, "", "dummy");
            } catch (Exception e) {
                // Ignore
            }

            if (dummyResource != null) {
                URI uri = dummyResource.toUri();
                Path path = Paths.get(uri).getParent();
                if (path != null) {
                    logDebug("Found classpath root from CLASS_OUTPUT: " + path);
                    return path;
                }
            }

            // Try CLASS_PATH
            try {
                // Create or get a marker file to find the root
                FileObject marker = filer.getResource(StandardLocation.CLASS_PATH, "", ".");
                URI uri = marker.toUri();
                String uriString = uri.toString();

                // Extract the file system path from the URI
                if (uriString.startsWith("file:")) {
                    Path path = Paths.get(URI.create(uriString.replace("file:", "file://")));
                    if (Files.exists(path) && Files.isDirectory(path)) {
                        logDebug("Found classpath root from CLASS_PATH: " + path);
                        return path;
                    }
                }
            } catch (Exception e) {
                logWarning("Could not determine classpath root from CLASS_PATH: " + e.getMessage());
            }

            // Fallback: try to find target/test-classes or build directory
            String userDir = System.getProperty("user.dir");
            if (userDir != null) {
                Path projectRoot = Paths.get(userDir);

                // Common Maven structure
                Path testClasses = projectRoot.resolve("target").resolve("test-classes");
                if (Files.exists(testClasses) && Files.isDirectory(testClasses)) {
                    logDebug("Found classpath root from Maven structure: " + testClasses);
                    return testClasses;
                }

                // Common Gradle structure
                Path gradleTestClasses = projectRoot.resolve("build").resolve("classes").resolve("test");
                if (Files.exists(gradleTestClasses) && Files.isDirectory(gradleTestClasses)) {
                    logDebug("Found classpath root from Gradle structure: " + gradleTestClasses);
                    return gradleTestClasses;
                }
            }

        } catch (Exception e) {
            logWarning("Error finding classpath root: " + e.getMessage());
        }

        return null;
    }

    /**
     * Converts a glob pattern to a regex pattern for matching.
     * This is a simple implementation that handles basic glob patterns.
     */
    private String convertGlobToRegex(String glob) {
        StringBuilder regex = new StringBuilder();
        boolean inGroup = false;
        boolean inBraces = false;

        for (int i = 0; i < glob.length(); i++) {
            char c = glob.charAt(i);

            switch (c) {
                case '\\':
                    regex.append("\\\\");
                    break;
                case '/':
                    regex.append('/');
                    break;
                case '$':
                case '^':
                case '.':
                case '+':
                case '(':
                case ')':
                case '|':
                    regex.append('\\').append(c);
                    break;
                case '{':
                    regex.append('(');
                    inBraces = true;
                    break;
                case '}':
                    regex.append(')');
                    inBraces = false;
                    break;
                case ',':
                    if (inBraces) {
                        regex.append('|');
                    } else {
                        regex.append(',');
                    }
                    break;
                case '*':
                    if (i + 1 < glob.length() && glob.charAt(i + 1) == '*') {
                        // ** matches zero or more directory segments
                        // Check if followed by / to handle **/ pattern
                        if (i + 2 < glob.length() && glob.charAt(i + 2) == '/') {
                            // **/ should match zero or more directory levels
                            regex.append("(?:(?:[^/]+/)*)");
                            i += 2; // Skip ** and /
                        } else {
                            // ** alone matches any number of characters
                            regex.append(".*");
                            i++; // Skip next *
                        }
                    } else {
                        // * matches anything except /
                        regex.append("[^/]*");
                    }
                    break;
                case '?':
                    regex.append("[^/]");
                    break;
                case '[':
                    regex.append('[');
                    inGroup = true;
                    break;
                case ']':
                    regex.append(']');
                    inGroup = false;
                    break;
                default:
                    regex.append(c);
            }
        }

        return regex.toString();
    }
}
