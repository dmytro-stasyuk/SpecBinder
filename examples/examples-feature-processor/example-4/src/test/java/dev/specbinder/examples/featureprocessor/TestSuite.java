package dev.specbinder.examples.featureprocessor;

import org.junit.platform.suite.api.SelectClasses;
import org.junit.platform.suite.api.Suite;
import org.junit.platform.suite.api.SuiteDisplayName;

@Suite
@SuiteDisplayName("All Tests")
@SelectClasses({
        SimpleExampleTest.class,
})
public class TestSuite {

}
