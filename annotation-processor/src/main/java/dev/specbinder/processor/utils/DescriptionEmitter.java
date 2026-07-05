package dev.specbinder.processor.utils;

import com.squareup.javapoet.AnnotationSpec;
import com.squareup.javapoet.MethodSpec;
import com.squareup.javapoet.TypeSpec;
import dev.specbinder.annotations.output.Description;
import dev.specbinder.processor.config.GeneratorOptions;
import org.apache.commons.lang3.StringUtils;

/**
 * Renders a Gherkin description (the free-text lines under a Feature, Rule, Scenario, or Background
 * heading) onto a generated class or method. The output form depends on the
 * {@code descriptionAsAnnotation} flag on {@link GeneratorOptions}: when {@code false} (default) the
 * description is emitted as a JavaDoc block; when {@code true} it is emitted as a
 * {@link Description @Description("""...""")} annotation.
 * <p>
 * Call this <em>after</em> {@code @DisplayName} has been added so the resulting annotation appears
 * immediately below it; JavaDoc position is unaffected by call ordering because JavaPoet always
 * renders JavaDoc above all annotations.
 */
public final class DescriptionEmitter {

    private DescriptionEmitter() {
        // utility class
    }

    /**
     * Emit the description onto a type (Feature class or {@code @Nested} Rule class).
     *
     * @param builder        the type builder to attach the JavaDoc or {@code @Description} annotation to
     * @param rawDescription the raw Gherkin description text; {@code null} or blank is a no-op
     * @param options        generator options controlling whether to emit JavaDoc or {@code @Description}
     */
    public static void emit(TypeSpec.Builder builder, String rawDescription, GeneratorOptions options) {
        String trimmed = prepare(rawDescription);
        if (trimmed == null) {
            return;
        }
        if (options.isDescriptionAsAnnotation()) {
            builder.addAnnotation(buildAnnotation(trimmed));
        } else {
            builder.addJavadoc(JavaDocUtils.escapeForJavaDoc(trimmed));
        }
    }

    /**
     * Emit the description onto a method (Scenario {@code @Test} method or Background
     * {@code @BeforeEach} method).
     *
     * @param builder        the method builder to attach the JavaDoc or {@code @Description} annotation to
     * @param rawDescription the raw Gherkin description text; {@code null} or blank is a no-op
     * @param options        generator options controlling whether to emit JavaDoc or {@code @Description}
     */
    public static void emit(MethodSpec.Builder builder, String rawDescription, GeneratorOptions options) {
        String trimmed = prepare(rawDescription);
        if (trimmed == null) {
            return;
        }
        if (options.isDescriptionAsAnnotation()) {
            builder.addAnnotation(buildAnnotation(trimmed));
        } else {
            builder.addJavadoc(JavaDocUtils.escapeForJavaDoc(trimmed));
        }
    }

    private static String prepare(String rawDescription) {
        if (StringUtils.isBlank(rawDescription)) {
            return null;
        }
        return JavaDocUtils.trimLeadingAndTrailingWhitespace(rawDescription);
    }

    private static AnnotationSpec buildAnnotation(String trimmedDescription) {
        String escaped = escapeForTextBlock(trimmedDescription);
        String textBlockLiteral = "\"\"\"\n" + escaped + "\n\"\"\"";
        return AnnotationSpec.builder(Description.class)
                .addMember("value", "$L", textBlockLiteral)
                .build();
    }

    /**
     * Escape characters that would otherwise break a Java text block literal:
     * <ul>
     *     <li>Backslash {@code \} → {@code \\}</li>
     *     <li>Triple quote {@code """} → {@code \"""} (escaping the first quote is enough to break
     *     the closing-delimiter sequence)</li>
     * </ul>
     * Dollar signs require no escaping inside a text block and are preserved verbatim.
     */
    private static String escapeForTextBlock(String input) {
        return input
                .replace("\\", "\\\\")
                .replace("\"\"\"", "\\\"\"\"");
    }
}
