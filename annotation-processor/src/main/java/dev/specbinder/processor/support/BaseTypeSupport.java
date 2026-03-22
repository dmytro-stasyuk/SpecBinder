package dev.specbinder.processor.support;

import javax.lang.model.element.TypeElement;

/**
 * Contains supporting methods for working with the BaseType class.
 */
public interface BaseTypeSupport {

    /**
     * The base type element for which the generator options apply.
     * @return generator options.
     */
    TypeElement getBaseType();
}
