/**
 * Created by nrodrigues on 6/5/2020.
 */

@IsTest
private class trac_EventControllerTest {
    @isTest
    static void testGetEventHistory() {
        Test.setMock(HttpCalloutMock.class, new MockResponseLoyaltyEvent('/customer/events'));
        TLAuraResponse response = trac_EventController.getTransactionHistory('', '123456999998007');
        System.assertEquals(true, response.isSuccess);
        System.assertEquals(false, response.returnValuesMap.get('transactions') == null);
    }
    @isTest
    static void testGetEventHistoryError() {
        Test.setMock(HttpCalloutMock.class, new MockResponseLoyaltyEvent('uad/customer/events'));
        TLAuraResponse response = trac_EventController.getTransactionHistory('', '123456999998007');
        System.assertEquals(false, response.isSuccess);
        System.assertEquals(true, response.returnValuesMap.get('transactions') == null);

        Integration_Error__c error = [SELECT ID, Service__c FROM Integration_Error__c LIMIT 1];
        System.assertEquals('Loyalty Customer Event History', error.Service__c);
    }
}