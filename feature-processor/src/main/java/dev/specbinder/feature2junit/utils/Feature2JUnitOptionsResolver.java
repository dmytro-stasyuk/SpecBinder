package dev.specbinder.feature2junit.utils;

import dev.specbinder.annotations.Feature2JUnitOptions;
import dev.specbinder.feature2junit.config.GeneratorOptions;

import javax.annotation.processing.ProcessingEnvironment;
import javax.lang.model.element.AnnotationMirror;
import javax.lang.model.element.AnnotationValue;
import javax.lang.model.element.ExecutableElement;
import javax.lang.model.element.TypeElement;
import javax.lang.model.element.VariableElement;
import javax.lang.model.util.Elements;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import static dev.specbinder.annotations.Feature2JUnitOptions.DATA_TABLE_PARAMETER_TYPE.LIST_OF_MAPS;

/**
 * Utility class for resolving and merging Feature2JUnitOptions annotations from a class hierarchy.
 *
 * This class supports partial inheritance of options, where a child class can override specific
 * options while inheriting others from its parent classes.
 */
public class Feature2JUnitOptionsResolver {

    private Feature2JUnitOptionsResolver() {
        // utility class
    }

    /**
     * Resolves GeneratorOptions from the Feature2JUnitOptions annotation hierarchy.
     *
     * This method collects all Feature2JUnitOptions annotations from the class hierarchy
     * and merges them, with child values taking precedence over parent values.
     *
     * The merging strategy uses AnnotationMirror to detect which values were explicitly set
     * in the source code versus left at their annotation defaults. Only explicitly set values
     * override the accumulated result. This applies uniformly to all property types (boolean,
     * String, enum), enabling true partial inheritance across the entire class hierarchy.
     *
     * @param annotatedClass the class to resolve options for
     * @param processingEnv the processing environment
     * @return the resolved GeneratorOptions, or a default instance if no annotations are found
     */
    public static GeneratorOptions resolveOptions(TypeElement annotatedClass, ProcessingEnvironment processingEnv) {
        List<AnnotationMirror> annotationMirrors = TypeMirrorUtils.collectAnnotationMirrorsFromHierarchy(
                annotatedClass, Feature2JUnitOptions.class, processingEnv
        );

        if (annotationMirrors.isEmpty()) {
            return new GeneratorOptions();
        }

        // Start with defaults
        boolean shouldBeAbstract = false;
        String classSuffixIfConcrete = "Test";
        String classSuffixIfAbstract = "Scenarios";
        boolean addSourceLineAnnotations = false;
        boolean addSourceLineBeforeStepCalls = false;
        boolean failScenariosWithNoSteps = true;
        boolean failRulesWithNoScenarios = true;
        String tagForScenariosWithNoSteps = "new";
        String tagForRulesWithNoScenarios = "new";
        boolean addCucumberStepAnnotations = false;
        boolean placeGeneratedClassNextToAnnotatedClass = false;
        String dataTableParameterType = LIST_OF_MAPS.name();
        boolean enableCompositeSteps = false;
        boolean useQualifiedEnumConstants = false;
        boolean useStepKeywordInStepMethodName = false;

        Elements elements = processingEnv.getElementUtils();

        // Merge annotations from parent to child (so child values override parent values)
        for (AnnotationMirror mirror : annotationMirrors) {
            // getElementValues() returns ONLY explicitly set values (not annotation defaults)
            Set<String> explicitlySetNames = mirror.getElementValues().keySet().stream()
                    .map(e -> e.getSimpleName().toString())
                    .collect(Collectors.toSet());

            // Get all values including defaults for reading actual values
            Map<? extends ExecutableElement, ? extends AnnotationValue> allValues =
                    elements.getElementValuesWithDefaults(mirror);

            for (Map.Entry<? extends ExecutableElement, ? extends AnnotationValue> entry : allValues.entrySet()) {
                String name = entry.getKey().getSimpleName().toString();

                // Only override if this value was explicitly set in the annotation
                if (!explicitlySetNames.contains(name)) {
                    continue;
                }

                Object value = entry.getValue().getValue();
                switch (name) {
                    case "shouldBeAbstract":
                        shouldBeAbstract = (Boolean) value;
                        break;
                    case "classSuffixIfConcrete":
                        classSuffixIfConcrete = (String) value;
                        break;
                    case "classSuffixIfAbstract":
                        classSuffixIfAbstract = (String) value;
                        break;
                    case "addSourceLineAnnotations":
                        addSourceLineAnnotations = (Boolean) value;
                        break;
                    case "addSourceLineBeforeStepCalls":
                        addSourceLineBeforeStepCalls = (Boolean) value;
                        break;
                    case "failScenariosWithNoSteps":
                        failScenariosWithNoSteps = (Boolean) value;
                        break;
                    case "failRulesWithNoScenarios":
                        failRulesWithNoScenarios = (Boolean) value;
                        break;
                    case "tagForScenariosWithNoSteps":
                        tagForScenariosWithNoSteps = (String) value;
                        break;
                    case "tagForRulesWithNoScenarios":
                        tagForRulesWithNoScenarios = (String) value;
                        break;
                    case "addCucumberStepAnnotations":
                        addCucumberStepAnnotations = (Boolean) value;
                        break;
                    case "placeGeneratedClassNextToAnnotatedClass":
                        // option removed, always false
                        break;
                    case "dataTableParameterType":
                        if (value instanceof VariableElement) {
                            dataTableParameterType = ((VariableElement) value).getSimpleName().toString();
                        }
                        break;
                    case "enableCompositeSteps":
                        enableCompositeSteps = (Boolean) value;
                        break;
                    case "useQualifiedEnumConstants":
                        useQualifiedEnumConstants = (Boolean) value;
                        break;
                    case "useStepKeywordInStepMethodName":
                        useStepKeywordInStepMethodName = (Boolean) value;
                        break;
                    default:
                        break;
                }
            }
        }

        return new GeneratorOptions(
                shouldBeAbstract,
                classSuffixIfConcrete,
                classSuffixIfAbstract,
                addSourceLineAnnotations,
                addSourceLineBeforeStepCalls,
                failScenariosWithNoSteps,
                failRulesWithNoScenarios,
                tagForScenariosWithNoSteps,
                tagForRulesWithNoScenarios,
                addCucumberStepAnnotations,
                placeGeneratedClassNextToAnnotatedClass,
                dataTableParameterType,
                enableCompositeSteps,
                useQualifiedEnumConstants,
                useStepKeywordInStepMethodName
        );
    }
}
