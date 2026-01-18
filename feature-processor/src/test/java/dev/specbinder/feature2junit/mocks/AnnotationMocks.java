package dev.specbinder.feature2junit.mocks;

import dev.specbinder.annotations.Feature2JUnit;
import dev.specbinder.annotations.Feature2JUnitOptions;
import dev.specbinder.feature2junit.config.GeneratorOptions;
import org.mockito.Mockito;

import javax.lang.model.element.Name;
import javax.lang.model.element.TypeElement;

final class AnnotationMocks {

    private AnnotationMocks() {
        throw new UnsupportedOperationException("This is a utility class and cannot be instantiated");
    }

    public static TypeElement feature2junitAnnotationTypeMirror() {

        TypeElement annotationType = Mockito.mock(TypeElement.class);
        Name annotationName = Mockito.mock(Name.class);
        Mockito.when(annotationName.toString()).thenReturn(Feature2JUnit.class.getName());
        Mockito.when(annotationType.getQualifiedName()).thenReturn(annotationName);
        return annotationType;
    }

    public static Feature2JUnit feature2junit() {

        Feature2JUnit f2j = Mockito.mock(Feature2JUnit.class);
        Mockito.when(f2j.value()).thenReturn("MockedAnnotatedTestClass.feature");
        return f2j;
    }

    public static Feature2JUnitOptions defaultFeature2junitOptions() {

        Feature2JUnitOptions options = Mockito.mock(Feature2JUnitOptions.class);

        GeneratorOptions defaultOptions = new GeneratorOptions();

        // Set default values from GeneratorOptions (can be overridden by Steps.java)
        Mockito.when(options.shouldBeAbstract()).thenReturn(defaultOptions.isShouldBeAbstract());
        Mockito.when(options.classSuffixIfConcrete()).thenReturn(defaultOptions.getClassSuffixIfConcrete());
        Mockito.when(options.classSuffixIfAbstract()).thenReturn(defaultOptions.getClassSuffixIfAbstract());
        Mockito.when(options.addSourceLineAnnotations()).thenReturn(defaultOptions.isAddSourceLineAnnotations());
        Mockito.when(options.addSourceLineBeforeStepCalls()).thenReturn(defaultOptions.isAddSourceLineBeforeStepCalls());
        Mockito.when(options.failScenariosWithNoSteps()).thenReturn(defaultOptions.isFailScenariosWithNoSteps());
        Mockito.when(options.failRulesWithNoScenarios()).thenReturn(defaultOptions.isFailRulesWithNoScenarios());
        Mockito.when(options.tagForScenariosWithNoSteps()).thenReturn(defaultOptions.getTagForScenariosWithNoSteps());
        Mockito.when(options.tagForRulesWithNoScenarios()).thenReturn(defaultOptions.getTagForRulesWithNoScenarios());
        Mockito.when(options.addCucumberStepAnnotations()).thenReturn(defaultOptions.isAddCucumberStepAnnotations());

        return options;
    }
}
