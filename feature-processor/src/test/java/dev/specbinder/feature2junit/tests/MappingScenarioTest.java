package dev.specbinder.feature2junit.tests;

import org.junit.jupiter.api.Disabled;
import org.junit.platform.suite.api.IncludeEngines;
import org.junit.platform.suite.api.SelectPackages;
import org.junit.platform.suite.api.Suite;

@Disabled
@Suite
@IncludeEngines("cucumber")
@SelectPackages("features.scenario")
public class MappingScenarioTest {

}
