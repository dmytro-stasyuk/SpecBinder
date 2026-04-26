package dev.specbinder.reporter.steps;

import javax.tools.*;
import java.io.IOException;
import java.net.URL;
import java.net.URLClassLoader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Writes one or more fixture Java sources to {@code <scenarioDir>/<package-path>/<ClassName>.java},
 * compiles them together (so a generated test class can extend an earlier-listed marker),
 * then loads the LAST class via a URLClassLoader rooted at the scenario directory plus
 * the test classpath. Sources remain on disk so a developer debugging a scenario failure
 * can inspect exactly what was compiled.
 */
final class FixtureCompiler {

    private static final Pattern PACKAGE_RE = Pattern.compile("^\\s*package\\s+([\\w.]+)\\s*;", Pattern.MULTILINE);
    private static final Pattern CLASS_RE = Pattern.compile("public\\s+(?:abstract\\s+|final\\s+)?class\\s+(\\w+)");

    private FixtureCompiler() {
    }

    static class Compiled {
        final String fullyQualifiedName;
        final Class<?> loadedClass;

        Compiled(String fullyQualifiedName, Class<?> loadedClass) {
            this.fullyQualifiedName = fullyQualifiedName;
            this.loadedClass = loadedClass;
        }
    }

    /** Single-source convenience overload. */
    static Compiled compileAndLoad(String source, Path scenarioDir) throws IOException, ClassNotFoundException {
        return compileAndLoad(List.of(source), scenarioDir);
    }

    /**
     * Compile every {@code source} together into {@code scenarioDir}, leaving both
     * {@code .java} and {@code .class} on disk under the matching package subdirectories,
     * and load the class declared in the LAST source.
     */
    static Compiled compileAndLoad(List<String> sources, Path scenarioDir) throws IOException, ClassNotFoundException {
        if (sources.isEmpty()) {
            throw new IllegalArgumentException("at least one source is required");
        }

        List<Path> sourceFiles = new ArrayList<>();
        String lastFqn = null;
        for (String source : sources) {
            String packageName = extract(PACKAGE_RE, source);
            String simpleName = extract(CLASS_RE, source);
            if (simpleName == null) {
                throw new IllegalArgumentException("could not find a public class declaration in fixture source");
            }
            lastFqn = packageName == null ? simpleName : packageName + "." + simpleName;

            Path sourceDir = scenarioDir;
            if (packageName != null) {
                for (String segment : packageName.split("\\.")) {
                    sourceDir = sourceDir.resolve(segment);
                }
            }
            Files.createDirectories(sourceDir);
            Path sourceFile = sourceDir.resolve(simpleName + ".java");
            Files.writeString(sourceFile, source);
            sourceFiles.add(sourceFile);
        }

        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        if (compiler == null) {
            throw new IllegalStateException("Java compiler not available; tests must run on a JDK, not a JRE");
        }

        DiagnosticCollector<JavaFileObject> diagnostics = new DiagnosticCollector<>();
        try (StandardJavaFileManager fileManager = compiler.getStandardFileManager(diagnostics, null, null)) {
            fileManager.setLocation(StandardLocation.CLASS_OUTPUT, List.of(scenarioDir.toFile()));
            Iterable<? extends JavaFileObject> units = fileManager.getJavaFileObjectsFromPaths(sourceFiles);
            JavaCompiler.CompilationTask task = compiler.getTask(
                    null, fileManager, diagnostics,
                    List.of("-cp", System.getProperty("java.class.path")),
                    null, units);
            boolean ok = task.call();
            if (!ok) {
                StringBuilder report = new StringBuilder("fixture compilation failed:\n");
                diagnostics.getDiagnostics().forEach(d -> report.append("  ").append(d).append('\n'));
                throw new IllegalStateException(report.toString());
            }
        }

        URLClassLoader loader = new URLClassLoader(
                new URL[]{scenarioDir.toUri().toURL()},
                Thread.currentThread().getContextClassLoader());
        return new Compiled(lastFqn, Class.forName(lastFqn, true, loader));
    }

    private static String extract(Pattern pattern, String source) {
        Matcher m = pattern.matcher(source);
        return m.find() ? m.group(1) : null;
    }
}
