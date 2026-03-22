package dev.specbinder.processor.tests;

import org.junit.platform.suite.api.*;

@Suite
@SuiteDisplayName("All Tests")
@SelectPackages("dev.specbinder.processor.tests")
@ExcludePackages("dev.specbinder.processor.tests.troubleshooting")
@IncludeClassNamePatterns(".*Test(s)?$")
public class AllTests {

}