package dev.specbinder.examples.featureprocessor;

import features.*;
import org.junit.platform.suite.api.SelectClasses;
import org.junit.platform.suite.api.Suite;
import org.junit.platform.suite.api.SuiteDisplayName;

@Suite
@SuiteDisplayName("All Tests")
@SelectClasses({
        FeatureWithRulesTest.class,
        SimpleScenarioTest.class,
        ScenarioOutlineTest.class,
        ScenarioWithBackgroundTest.class,
        DocStringsTest.class,
        DataTablesTest.class,
        TaggedFeatureAndRulesTest.class,
        TaggedScenariosTest.class
})
public class TestSuite {

}
