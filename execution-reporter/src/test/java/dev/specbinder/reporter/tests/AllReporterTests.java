package dev.specbinder.reporter.tests;

import org.junit.platform.suite.api.IncludeClassNamePatterns;
import org.junit.platform.suite.api.SelectPackages;
import org.junit.platform.suite.api.Suite;
import org.junit.platform.suite.api.SuiteDisplayName;

@Suite
@SuiteDisplayName("All Reporter Tests")
@SelectPackages("dev.specbinder.reporter.tests")
@IncludeClassNamePatterns(".*Test(s)?$")
public class AllReporterTests {

}