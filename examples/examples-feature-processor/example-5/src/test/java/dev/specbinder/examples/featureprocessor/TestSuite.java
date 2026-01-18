package dev.specbinder.examples.featureprocessor;

import org.junit.platform.suite.api.SelectClasses;
import org.junit.platform.suite.api.Suite;
import org.junit.platform.suite.api.SuiteDisplayName;
import specs.account.ResetPasswordTest;
import specs.account.UpdateEmailTest;
import specs.admin.DashboardTest;
import specs.admin.UserManagementTest;
import specs.product.CheckoutTest;
import specs.product.SearchTest;
import specs.user.LoginTest;
import specs.user.ProfileTest;
import specs.user.RegistrationTest;

@Suite
@SuiteDisplayName("All Tests")
@SelectClasses({
        ResetPasswordTest.class,
        UpdateEmailTest.class,
        DashboardTest.class,
        UserManagementTest.class,
        CheckoutTest.class,
        SearchTest.class,
        LoginTest.class,
        ProfileTest.class,
        RegistrationTest.class,
})
public class TestSuite {

}
