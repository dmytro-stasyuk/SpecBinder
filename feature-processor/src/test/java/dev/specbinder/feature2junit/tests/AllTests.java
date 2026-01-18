package dev.specbinder.feature2junit.tests;

import org.junit.platform.suite.api.*;

@Suite
@SuiteDisplayName("All Tests")
@SelectPackages("dev.specbinder.feature2junit.tests")
@ExcludePackages("dev.specbinder.feature2junit.tests.troubleshooting")
@IncludeClassNamePatterns(".*Test(s)?$")
public class AllTests {

}