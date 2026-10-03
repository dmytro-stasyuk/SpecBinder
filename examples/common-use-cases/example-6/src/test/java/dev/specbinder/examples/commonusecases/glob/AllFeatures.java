package dev.specbinder.examples.commonusecases.glob;

import dev.specbinder.annotations.Gherkin2JUnit;

/**
 * A single marker class whose glob pattern discovers every spec file in the
 * sub-packages below it ("./" resolves against this class's package). The
 * generator emits one abstract test class per discovered spec, in the spec's
 * own package, each extending this marker. A bare @Gherkin2JUnit would only
 * look in this package itself — the recursive "**" is what reaches cart/ and user/.
 *
 * Step methods are implemented as usual — here in one concrete test class per
 * spec, placed next to it. This example focuses on glob-based discovery.
 */
@Gherkin2JUnit("./**/*.specb")
public abstract class AllFeatures {
}
