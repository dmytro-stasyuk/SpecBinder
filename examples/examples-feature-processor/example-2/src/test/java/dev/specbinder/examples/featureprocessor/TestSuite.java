package dev.specbinder.examples.featureprocessor;

import org.junit.platform.suite.api.SelectClasses;
import org.junit.platform.suite.api.Suite;
import org.junit.platform.suite.api.SuiteDisplayName;
import specs.DataTablesTest;

@Suite
@SuiteDisplayName("All Tests")
@SelectClasses({
        DataTablesTest.class,
})
public class TestSuite {

}
