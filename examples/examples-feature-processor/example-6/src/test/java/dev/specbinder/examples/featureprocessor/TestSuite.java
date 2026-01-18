package dev.specbinder.examples.featureprocessor;

import org.junit.platform.suite.api.SelectClasses;
import org.junit.platform.suite.api.Suite;


@Suite
@SelectClasses({
        SimpleCalculatorTest.class,
        ShoppingCartTest.class,
        ScenarioWithBackgroundTest.class,
})
public class TestSuite {

}
