package dev.specbinder.processor.tests;

import org.junit.jupiter.api.Disabled;
import org.junit.platform.suite.api.IncludeEngines;
import org.junit.platform.suite.api.SelectPackages;
import org.junit.platform.suite.api.Suite;

@Disabled
@Suite
@IncludeEngines("cucumber")
@SelectPackages("features.rule")
public class MappingRuleTest {

}
