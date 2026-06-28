package dev.specbinder.processor;

import com.sun.source.tree.CompilationUnitTree;
import com.sun.source.util.TreePath;
import com.sun.source.util.Trees;
import dev.specbinder.annotations.output.SourceTimestamp;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.Element;
import javax.lang.model.element.TypeElement;
import javax.lang.model.type.TypeKind;
import javax.lang.model.type.TypeMirror;
import javax.lang.model.util.Types;
import javax.tools.FileObject;
import javax.tools.JavaFileObject;
import javax.tools.StandardLocation;
import java.util.OptionalLong;

/**
 * Computes and reads back the last-modified fingerprint used by the {@code skipUnchangedSpecs}
 * optimization.
 * <p>
 * The fingerprint is the newest last-modified time (epoch millis) across a test class's generation
 * inputs: the spec ({@code .feature}/{@code .specb}) file, the {@code @Gherkin2JUnit} marker class,
 * and every source class in the marker's hierarchy. On a later run the previously generated class's
 * recorded {@link SourceTimestamp} value is compared against a freshly computed fingerprint to
 * decide whether regeneration can be skipped.
 * <p>
 * All lookups fail soft: any input whose last-modified time cannot be determined (e.g. a
 * classpath-only ancestor with no available source) is ignored, and an unresolvable or unstamped
 * previously generated class yields {@link OptionalLong#empty()}, which callers treat as "must
 * regenerate".
 */
class SpecTimestampSupport {

    private final ProcessingEnvironment processingEnv;
    private final Trees trees;

    SpecTimestampSupport(ProcessingEnvironment processingEnv) {
        this.processingEnv = processingEnv;
        Trees resolved;
        try {
            resolved = Trees.instance(processingEnv);
        } catch (Exception e) {
            resolved = null;
        }
        this.trees = resolved;
    }

    /**
     * Returns the newest last-modified time (epoch millis) across the spec file, the marker class,
     * and every source class in the marker's hierarchy. Inputs whose timestamp cannot be resolved
     * are ignored. Returns {@code 0} when no input timestamp could be determined.
     *
     * @param marker             the {@code @Gherkin2JUnit} marker class
     * @param featureResourcePath the classpath-relative path of the spec file
     * @return the newest input timestamp in epoch millis, or {@code 0} if none could be resolved
     */
    long computeNewestInputTimestamp(TypeElement marker, String featureResourcePath) {
        long newest = specFileTimestamp(featureResourcePath);
        TypeElement current = marker;
        Types typeUtils = processingEnv.getTypeUtils();
        while (current != null && !"java.lang.Object".equals(current.getQualifiedName().toString())) {
            newest = Math.max(newest, sourceTimestamp(current));

            TypeMirror superMirror = current.getSuperclass();
            if (superMirror == null || superMirror.getKind() == TypeKind.NONE) {
                break;
            }
            Element superElement = typeUtils.asElement(superMirror);
            if (!(superElement instanceof TypeElement)) {
                break;
            }
            current = (TypeElement) superElement;
        }
        return newest;
    }

    /**
     * Reads the {@link SourceTimestamp} value recorded on a previously generated class, if that
     * class is resolvable and carries the annotation.
     *
     * @param fullyQualifiedName the fully qualified name of the previously generated class
     * @return the recorded timestamp, or empty if the class is missing or carries no timestamp
     */
    OptionalLong readRecordedTimestamp(String fullyQualifiedName) {
        if (fullyQualifiedName == null || fullyQualifiedName.isBlank()) {
            return OptionalLong.empty();
        }
        TypeElement existing = processingEnv.getElementUtils().getTypeElement(fullyQualifiedName);
        if (existing == null) {
            return OptionalLong.empty();
        }
        SourceTimestamp recorded = existing.getAnnotation(SourceTimestamp.class);
        if (recorded == null) {
            return OptionalLong.empty();
        }
        return OptionalLong.of(recorded.value());
    }

    private long specFileTimestamp(String featureResourcePath) {
        if (featureResourcePath == null || featureResourcePath.isBlank()) {
            return 0L;
        }
        try {
            FileObject resource = processingEnv.getFiler()
                    .getResource(StandardLocation.CLASS_PATH, "", featureResourcePath);
            return Math.max(0L, resource.getLastModified());
        } catch (Exception e) {
            return 0L;
        }
    }

    private long sourceTimestamp(TypeElement type) {
        if (trees == null) {
            return 0L;
        }
        try {
            TreePath path = trees.getPath(type);
            if (path == null) {
                return 0L;
            }
            CompilationUnitTree compilationUnit = path.getCompilationUnit();
            if (compilationUnit == null) {
                return 0L;
            }
            JavaFileObject source = compilationUnit.getSourceFile();
            if (source == null) {
                return 0L;
            }
            return Math.max(0L, source.getLastModified());
        } catch (Exception e) {
            return 0L;
        }
    }
}
