package dev.specbinder.processor.utils;

import com.squareup.javapoet.AnnotationSpec;
import io.cucumber.messages.types.Tag;
import org.junit.jupiter.api.Tags;

import java.util.Arrays;
import java.util.List;
import java.util.regex.Pattern;

/**
 * Utility class for converting Gherkin tags to JUnit annotations.
 */
public class TagUtils {

    private TagUtils() {
        /**
         * utility class
         */
    }

    /**
     * Converts an array of tag names to JUnit Tags annotations.
     *
     * @param tagNames the names of the tags to convert
     * @return an {@link AnnotationSpec} representing the JUnit Tags annotation
     */
    public static AnnotationSpec toJUnitTagsAnnotation(String... tagNames) {

        List<String> tagNamesList = Arrays.asList(tagNames);

        AnnotationSpec.Builder annotationSpecBuilderFromTagNames = annotationSpecBuilderFromTagNames(tagNamesList);
        AnnotationSpec annotationSpec = annotationSpecBuilderFromTagNames.build();
        return annotationSpec;
    }

    /**
     * Converts a list of Gherkin tags to a JUnit Tags annotation.
     * @param tags the list of Gherkin tags to convert
     * @return an {@link AnnotationSpec} representing the JUnit Tags annotation
     */
    public static AnnotationSpec toJUnitTagsAnnotation(List<Tag> tags) {

        AnnotationSpec.Builder annotationSpecBuilder;

        List<String> tagNames = tags.stream()
                .map(tag -> tag.getName().trim())
                .map(tagName -> tagName.startsWith("@") ? tagName.substring(1) : tagName)
                .toList();

        annotationSpecBuilder = annotationSpecBuilderFromTagNames(tagNames);

        AnnotationSpec annotationSpec = annotationSpecBuilder.build();
        return annotationSpec;
    }

    /**
     * Checks whether an element should be skipped based on its tags and the configured skip patterns.
     *
     * @param tags the Gherkin tags on the element
     * @param skipPatterns regex patterns to match against tag names (without leading @)
     * @return true if any tag matches any pattern, meaning the element should be skipped
     */
    public static boolean shouldSkipElement(List<Tag> tags, String[] skipPatterns) {
        if (tags == null || tags.isEmpty() || skipPatterns == null || skipPatterns.length == 0) {
            return false;
        }

        for (Tag tag : tags) {
            String tagName = tag.getName().trim();
            if (tagName.startsWith("@")) {
                tagName = tagName.substring(1);
            }

            for (String pattern : skipPatterns) {
                if (Pattern.compile(pattern).matcher(tagName).matches()) {
                    return true;
                }
            }
        }
        return false;
    }

    private static AnnotationSpec.Builder annotationSpecBuilderFromTagNames(List<String> tagNames) {

        AnnotationSpec.Builder annotationSpecBuilder;

        if (tagNames.size() > 1) {
            /**
             * use {@link Tags}
             */
            annotationSpecBuilder = AnnotationSpec.builder(Tags.class);

            for (String tagName : tagNames) {

                AnnotationSpec tagAnnotationSpec = AnnotationSpec.builder(org.junit.jupiter.api.Tag.class)
                        .addMember("value", "\"" + tagName + "\"")
                        .build();
                annotationSpecBuilder.addMember("value", "$L", tagAnnotationSpec);
            }

        } else {
            /**
             * use {@link org.junit.jupiter.api.Tag}
             */
            String tagName = tagNames.get(0);

            annotationSpecBuilder = AnnotationSpec.builder(org.junit.jupiter.api.Tag.class)
                    .addMember("value", "\"" + tagName + "\"");
        }

        return annotationSpecBuilder;
    }

}
