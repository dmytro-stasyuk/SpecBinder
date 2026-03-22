package dev.specbinder.annotations.output;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Annotation to specify the path to the source file used to generate the test class.
 */
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface SourceFilePath {

    /**
     * Source file path.
     *
     * @return the path to the source file based on which the test was generated.
     */
    String value();
}
