package dev.specbinder.processor.utils;

import com.squareup.javapoet.AnnotationSpec;
import com.squareup.javapoet.ParameterSpec;
import com.squareup.javapoet.TypeName;

import javax.lang.model.element.AnnotationMirror;
import javax.lang.model.element.Element;
import javax.lang.model.element.ExecutableElement;
import javax.lang.model.element.VariableElement;
import javax.lang.model.type.DeclaredType;
import javax.lang.model.type.TypeMirror;
import java.util.ArrayList;
import java.util.List;

/**
 * Detects JUnit-injected parameter types on inherited step methods so they can be propagated
 * to the generated test method and forwarded on the step call.
 * <p>
 * Two categories are recognized:
 * <ul>
 *   <li><b>Built-in JUnit-resolved types</b> (implicit, no marker required):
 *     <ul>
 *       <li>{@code org.junit.jupiter.api.TestInfo}</li>
 *       <li>{@code org.junit.jupiter.api.TestReporter}</li>
 *       <li>{@code java.nio.file.Path} annotated with {@code @org.junit.jupiter.api.io.TempDir}</li>
 *       <li>{@code java.io.File} annotated with {@code @org.junit.jupiter.api.io.TempDir}</li>
 *     </ul>
 *   </li>
 *   <li><b>Custom types marked with {@code @dev.specbinder.annotations.JUnitInject}</b>
 *     (either on the parameter or on the type's class declaration).</li>
 * </ul>
 * <p>
 * All annotations on the source parameter except {@code @JUnitInject} are preserved verbatim
 * on the returned {@link ParameterSpec} so user-registered ParameterResolvers can observe them.
 */
public final class JUnitParameterDetector {

    private static final String TEST_INFO = "org.junit.jupiter.api.TestInfo";
    private static final String TEST_REPORTER = "org.junit.jupiter.api.TestReporter";
    private static final String TEMP_DIR_ANNOTATION = "org.junit.jupiter.api.io.TempDir";
    private static final String PATH = "java.nio.file.Path";
    private static final String FILE = "java.io.File";
    private static final String JUNIT_INJECT = "dev.specbinder.annotations.JUnitInject";

    private JUnitParameterDetector() {
        // utility class
    }

    /**
     * Returns the list of trailing parameters of {@code baseMethod} (starting at {@code gherkinParamCount})
     * recognized as JUnit-injected parameters, or {@code null} if any trailing parameter is unrecognized.
     * <p>
     * A {@code null} return means the base method is <em>not a valid match</em> for the step — the caller
     * should treat the base method as if it does not match (and fall back to generating a fresh
     * abstract/stub step method). An empty list means a valid match with no extras to propagate. A
     * non-empty list means a valid match with the listed parameters to inject into the generated
     * {@code @Test} / {@code @BeforeEach} method.
     *
     * @param baseMethod the matched base class step method
     * @param gherkinParamCount the number of leading Gherkin-derived parameters to skip
     * @return ordered list of injected ParameterSpec (possibly empty), or {@code null} if invalid match
     */
    public static List<ParameterSpec> detectTrailingInjectedParams(
            ExecutableElement baseMethod, int gherkinParamCount) {

        List<? extends VariableElement> params = baseMethod.getParameters();
        if (params.size() <= gherkinParamCount) {
            return List.of();
        }

        List<ParameterSpec> extras = new ArrayList<>();
        for (int i = gherkinParamCount; i < params.size(); i++) {
            ParameterSpec extra = toInjectedParamSpec(params.get(i));
            if (extra == null) {
                return null;
            }
            extras.add(extra);
        }
        return extras;
    }

    private static ParameterSpec toInjectedParamSpec(VariableElement param) {
        TypeMirror type = param.asType();
        String typeStr = type.toString();
        String paramName = param.getSimpleName().toString();

        boolean recognized = false;
        if (TEST_INFO.equals(typeStr) || TEST_REPORTER.equals(typeStr)) {
            recognized = true;
        } else if ((PATH.equals(typeStr) || FILE.equals(typeStr))
                && hasParamAnnotation(param, TEMP_DIR_ANNOTATION)) {
            recognized = true;
        } else if (hasParamAnnotation(param, JUNIT_INJECT) || hasTypeAnnotation(type, JUNIT_INJECT)) {
            recognized = true;
        }

        if (!recognized) {
            return null;
        }

        ParameterSpec.Builder builder = ParameterSpec.builder(TypeName.get(type), paramName);
        for (AnnotationMirror am : param.getAnnotationMirrors()) {
            if (!JUNIT_INJECT.equals(am.getAnnotationType().toString())) {
                builder.addAnnotation(AnnotationSpec.get(am));
            }
        }
        return builder.build();
    }

    private static boolean hasParamAnnotation(VariableElement param, String annotationFqn) {
        for (AnnotationMirror am : param.getAnnotationMirrors()) {
            if (annotationFqn.equals(am.getAnnotationType().toString())) {
                return true;
            }
        }
        return false;
    }

    private static boolean hasTypeAnnotation(TypeMirror type, String annotationFqn) {
        if (!(type instanceof DeclaredType declaredType)) {
            return false;
        }
        Element element = declaredType.asElement();
        for (AnnotationMirror am : element.getAnnotationMirrors()) {
            if (annotationFqn.equals(am.getAnnotationType().toString())) {
                return true;
            }
        }
        return false;
    }
}
