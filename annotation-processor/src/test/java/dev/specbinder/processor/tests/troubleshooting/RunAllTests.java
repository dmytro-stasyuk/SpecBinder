package dev.specbinder.processor.tests.troubleshooting;

import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.parallel.Execution;
import org.junit.jupiter.api.parallel.ExecutionMode;
import org.junit.platform.suite.api.ExcludeTags;
import org.junit.platform.suite.api.IncludeEngines;
import org.junit.platform.suite.api.SelectClasspathResource;
import org.junit.platform.suite.api.Suite;

@Disabled("use individual test classes instead")
@Suite
@IncludeEngines("cucumber")
@Execution(ExecutionMode.CONCURRENT)
@SelectClasspathResource("features")
@ExcludeTags("wip")
public class RunAllTests {


    //@BeforeAll
    //public static void beforeAll() {
    //    // Enable compilation verification for all tests
    //    // increases test execution time significantly
    //    Steps.enableCompilationVerification();
    //}

}
