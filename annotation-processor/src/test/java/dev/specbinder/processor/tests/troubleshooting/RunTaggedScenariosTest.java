package dev.specbinder.processor.tests.troubleshooting;

import org.junit.jupiter.api.Disabled;
import org.junit.platform.suite.api.IncludeEngines;
import org.junit.platform.suite.api.SelectClasspathResource;
import org.junit.platform.suite.api.Suite;

@Disabled
@Suite
@IncludeEngines("cucumber")
@SelectClasspathResource("features")
//@SelectClasspathResource("features/steps/CucumberStepAnnotations.feature")
//@IncludeTags(value = {"troubleshoot", "wip"})
public class RunTaggedScenariosTest {

}
