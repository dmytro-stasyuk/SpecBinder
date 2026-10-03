package dev.specbinder.annotations.output;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.DisplayNameGenerator;

/**
 * Names the test class that runs a generated abstract class after the spec it runs.
 * <p>
 * A generated abstract class carries {@code @DisplayName("Feature: <title>")}, but JUnit does not pass
 * {@link DisplayName} down to a subclass, so the class that actually runs — the one extending the generated
 * class — would otherwise be shown by its own name. The generated class therefore also carries
 * {@code @DisplayNameGeneration(SpecDisplayNameGenerator.class)}, which JUnit does pass down, and this generator
 * names that subclass {@code "<Feature display name> (<subclass simple name>)"}, e.g.
 * {@code "Feature: Shopping cart (ShoppingCartTest)"}. The subclass name stays in the label so the runs of
 * several classes against one spec can be told apart.
 * <p>
 * Everything else — nested classes and methods, which the generator names explicitly anyway, and any test
 * written by hand — keeps JUnit's standard name. A {@link DisplayName} on the subclass itself still wins.
 */
public class SpecDisplayNameGenerator extends DisplayNameGenerator.Standard {

    @Override
    public String generateDisplayNameForClass(Class<?> testClass) {
        String featureName = featureDisplayNameAbove(testClass);
        if (featureName == null) {
            return super.generateDisplayNameForClass(testClass);
        }
        return featureName + " (" + testClass.getSimpleName() + ")";
    }

    /**
     * The display name of the nearest superclass generated from a spec — the first one carrying
     * {@link SourceFilePath}, which is not inherited — or {@code null} when there is none.
     */
    private static String featureDisplayNameAbove(Class<?> testClass) {
        for (Class<?> type = testClass.getSuperclass(); type != null && type != Object.class;
             type = type.getSuperclass()) {
            if (type.isAnnotationPresent(SourceFilePath.class)) {
                DisplayName displayName = type.getAnnotation(DisplayName.class);
                return displayName != null ? displayName.value() : null;
            }
        }
        return null;
    }
}
