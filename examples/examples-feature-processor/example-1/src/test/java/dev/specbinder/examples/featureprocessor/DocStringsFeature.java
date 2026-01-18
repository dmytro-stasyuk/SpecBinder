package dev.specbinder.examples.featureprocessor;

import dev.specbinder.annotations.Feature2JUnit;

/**
 * Demonstrates how Gherkin doc strings are converted to String parameters in step methods.
 * Doc strings enable passing multi-line text content to steps, useful for testing with large text blocks.
 */
@Feature2JUnit("features/DocStrings.feature")
public abstract class DocStringsFeature {

    public void givenIAmAContentEditor() {
        // TODO: Implement step
    }

    public void whenICreateAPostWithContent(String docString) {
        // TODO: Implement step with doc string parameter
        // The docString parameter contains multi-line text
    }

    public void thenThePostShouldBeSavedSuccessfully() {
        // TODO: Implement step
    }

    public void whenISendAnEmailWithBody(String docString) {
        // TODO: Implement step with doc string parameter
    }

    public void thenTheEmailShouldBeSent() {
        // TODO: Implement step
    }
}
