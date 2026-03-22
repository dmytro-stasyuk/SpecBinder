package dev.specbinder.processor.utils;

import com.sun.source.tree.CompilationUnitTree;
import com.sun.source.util.TreePath;
import com.sun.source.util.Trees;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.Element;
import javax.lang.model.element.ElementKind;
import javax.lang.model.element.TypeElement;
import javax.lang.model.type.DeclaredType;
import javax.lang.model.type.TypeMirror;
import javax.tools.*;
import java.io.IOException;
import java.net.URL;
import java.net.URLClassLoader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;

/**
 * Resolves enum constant names by invoking static factory methods during annotation processing.
 * Since classes being compiled in the current javac invocation are not loadable via Class.forName(),
 * this resolver compiles the enum source separately to a temp directory and loads it from there.
 */
public class EnumFactoryMethodResolver {

    private final ProcessingEnvironment processingEnv;
    private final Map<String, Class<?>> compiledClassCache = new HashMap<>();
    private final List<Path> tempDirs = new ArrayList<>();
    private Trees trees;

    /**
     * Creates a new resolver using the given annotation processing environment.
     *
     * @param processingEnv the annotation processing environment
     */
    public EnumFactoryMethodResolver(ProcessingEnvironment processingEnv) {
        this.processingEnv = processingEnv;
        try {
            this.trees = Trees.instance(processingEnv);
        } catch (Exception e) {
            this.trees = null;
        }
    }

    /**
     * Invokes the factory method to resolve a string value to an enum constant name.
     *
     * @param value the string value to resolve (e.g., "monday")
     * @param enumType the enum type mirror
     * @param factoryMethodName the name of the factory method (e.g., "of")
     * @return the enum constant name (e.g., "MONDAY"), or null if resolution fails
     */
    public String resolve(String value, TypeMirror enumType, String factoryMethodName) {
        String binaryName = getBinaryName(enumType);

        // Try Class.forName first (works when enum is pre-compiled, e.g., from a dependency JAR)
        try {
            Class<?> enumClass = Class.forName(binaryName);
            return invokeMethod(enumClass, factoryMethodName, value);
        } catch (ClassNotFoundException e) {
            // Fall through to compile-and-invoke
        }

        // Compile the source and invoke
        Class<?> enumClass = getOrCompileEnum(enumType, binaryName);
        if (enumClass != null) {
            return invokeMethod(enumClass, factoryMethodName, value);
        }

        return null;
    }

    /**
     * Cleans up temporary directories created during resolution.
     */
    public void cleanup() {
        for (Path tempDir : tempDirs) {
            cleanupDir(tempDir);
        }
        tempDirs.clear();
        compiledClassCache.clear();
    }

    /**
     * Invokes the given static factory method on the enum class with the provided string value,
     * returning the enum constant name if successful.
     *
     * @param enumClass  the loaded enum class
     * @param methodName the name of the static factory method to invoke
     * @param value      the string argument to pass to the factory method
     * @return the name of the resolved enum constant, or {@code null} if invocation fails
     */
    private String invokeMethod(Class<?> enumClass, String methodName, String value) {
        try {
            java.lang.reflect.Method method = enumClass.getDeclaredMethod(methodName, String.class);
            method.setAccessible(true);
            Object result = method.invoke(null, value);
            return ((Enum<?>) result).name();
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Returns a previously compiled enum class from the cache, or compiles and caches it on first access.
     *
     * @param enumType   the type mirror of the enum
     * @param binaryName the binary name of the enum class
     * @return the loaded enum class, or {@code null} if compilation or loading fails
     */
    private Class<?> getOrCompileEnum(TypeMirror enumType, String binaryName) {
        if (compiledClassCache.containsKey(binaryName)) {
            return compiledClassCache.get(binaryName);
        }

        try {
            Class<?> enumClass = compileAndLoad(enumType, binaryName);
            compiledClassCache.put(binaryName, enumClass);
            return enumClass;
        } catch (Exception e) {
            compiledClassCache.put(binaryName, null);
            return null;
        }
    }

    /**
     * Compiles the enum source to a temporary directory and loads the resulting class.
     * This is needed because classes being compiled in the current javac invocation
     * are not loadable via {@code Class.forName()}.
     *
     * @param enumType   the type mirror of the enum
     * @param binaryName the binary name of the enum class to load after compilation
     * @return the loaded enum class, or {@code null} if the Trees API is unavailable or compilation fails
     * @throws Exception if an I/O or compilation error occurs
     */
    private Class<?> compileAndLoad(TypeMirror enumType, String binaryName) throws Exception {
        if (trees == null) {
            return null;
        }

        DeclaredType declaredType = (DeclaredType) enumType;
        TypeElement enumElement = (TypeElement) declaredType.asElement();
        TypeElement topLevel = getTopLevelType(enumElement);

        // Get source file via Trees API
        TreePath path = trees.getPath(topLevel);
        if (path == null) {
            return null;
        }

        CompilationUnitTree cu = path.getCompilationUnit();
        JavaFileObject sourceFileObject = cu.getSourceFile();
        CharSequence sourceContent = sourceFileObject.getCharContent(false);

        // Create temp directory and write source file
        Path tempDir = Files.createTempDirectory("specbinder-enum-");
        tempDirs.add(tempDir);

        String qualifiedName = topLevel.getQualifiedName().toString();
        int lastDot = qualifiedName.lastIndexOf('.');
        String packagePath = lastDot > 0 ? qualifiedName.substring(0, lastDot).replace('.', '/') : "";
        String simpleName = lastDot > 0 ? qualifiedName.substring(lastDot + 1) : qualifiedName;

        Path packageDir = packagePath.isEmpty() ? tempDir : tempDir.resolve(packagePath);
        Files.createDirectories(packageDir);
        Path sourceFile = packageDir.resolve(simpleName + ".java");
        Files.writeString(sourceFile, sourceContent);

        // Compile with no annotation processing
        JavaCompiler compiler = ToolProvider.getSystemJavaCompiler();
        if (compiler == null) {
            return null;
        }

        DiagnosticCollector<JavaFileObject> diagnostics = new DiagnosticCollector<>();
        StandardJavaFileManager fileManager = compiler.getStandardFileManager(diagnostics, null, null);

        try {
            Iterable<? extends JavaFileObject> compilationUnits =
                    fileManager.getJavaFileObjects(sourceFile.toFile());

            List<String> options = List.of(
                    "-d", tempDir.toString(),
                    "-proc:none",
                    "-cp", System.getProperty("java.class.path")
            );

            JavaCompiler.CompilationTask task = compiler.getTask(
                    null, fileManager, diagnostics, options, null, compilationUnits
            );

            boolean success = task.call();
            if (!success) {
                return null;
            }
        } finally {
            fileManager.close();
        }

        // Load the compiled class
        URLClassLoader classLoader = new URLClassLoader(
                new URL[]{tempDir.toUri().toURL()},
                getClass().getClassLoader()
        );

        return classLoader.loadClass(binaryName);
    }

    /**
     * Traverses the enclosing element hierarchy to find the top-level type containing the given element.
     *
     * @param element the type element to find the top-level enclosing type for
     * @return the top-level type element
     */
    private TypeElement getTopLevelType(TypeElement element) {
        Element enclosing = element.getEnclosingElement();
        while (enclosing != null && (enclosing.getKind() == ElementKind.CLASS
                || enclosing.getKind() == ElementKind.ENUM
                || enclosing.getKind() == ElementKind.INTERFACE)) {
            element = (TypeElement) enclosing;
            enclosing = element.getEnclosingElement();
        }
        return element;
    }

    /**
     * Returns the binary name for the given type mirror.
     *
     * @param targetType the type mirror to resolve
     * @return the binary name (e.g., {@code "com.example.Outer$Inner"})
     */
    private String getBinaryName(TypeMirror targetType) {
        DeclaredType declaredType = (DeclaredType) targetType;
        TypeElement typeElement = (TypeElement) declaredType.asElement();
        return getBinaryNameForElement(typeElement);
    }

    /**
     * Recursively builds the binary name for a type element, using {@code $} as the separator
     * for nested types.
     *
     * @param typeElement the type element to resolve
     * @return the binary name (e.g., {@code "com.example.Outer$Inner"})
     */
    private String getBinaryNameForElement(TypeElement typeElement) {
        Element enclosing = typeElement.getEnclosingElement();
        if (enclosing != null && (enclosing.getKind() == ElementKind.CLASS
                || enclosing.getKind() == ElementKind.ENUM)) {
            return getBinaryNameForElement((TypeElement) enclosing) + "$" + typeElement.getSimpleName();
        }
        return typeElement.getQualifiedName().toString();
    }

    /**
     * Recursively deletes the given directory and all its contents.
     *
     * @param dir the directory to delete
     */
    private void cleanupDir(Path dir) {
        try {
            Files.walk(dir)
                    .sorted(Comparator.reverseOrder())
                    .forEach(path -> {
                        try {
                            Files.delete(path);
                        } catch (IOException ignored) {
                        }
                    });
        } catch (IOException ignored) {
        }
    }
}
