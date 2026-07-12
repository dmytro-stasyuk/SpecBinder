package dev.specbinder.examples.commonusecases.glob;

import dev.specbinder.annotations.Gherkin2JUnit;

/**
 * A single marker class whose glob pattern discovers every feature file
 * under specs/ recursively. The generator emits one abstract test class
 * per discovered feature, each extending this marker.
 *
 * Step methods are implemented as usual — directly on the marker, in a
 * concrete subclass, or organized into interfaces (see the Step Interfaces
 * example). This example focuses purely on glob-based discovery.
 */
@Gherkin2JUnit("specs/**/*.specb")
public abstract class AllFeatures {
}
