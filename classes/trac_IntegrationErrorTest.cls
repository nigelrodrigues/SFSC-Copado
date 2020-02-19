/**
 *  @description Tests for trac_IntegrationError
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        9/20/2018
 */
@IsTest
private class trac_IntegrationErrorTest {

    @IsTest static void test_addError() {
        Integration_Error__c integrationError = new Integration_Error__c(Service__c = 'TEST');
        integrationError = trac_IntegrationError.addError(integrationError);

        System.assertNotEquals(null, integrationError.Title__c, 'Title should be updated');
    }

    @IsTest static void test_insertIntegrationErrors() {
        Integration_Error__c integrationError = new Integration_Error__c(Service__c = 'TEST');
        integrationError = trac_IntegrationError.addError(integrationError);

        trac_IntegrationError.insertIntegrationErrors();

        List<Integration_Error__c> integrationErrors = [SELECT Id FROM Integration_Error__c];
        System.assertEquals(1, integrationErrors.size(), 'An integration error should have been inserted');
    }
}