/**
 * Created by nrodrigues on 4/28/2020.
 */

@IsTest
private class trac_CancelOrderCltrTest {

    static final TLTestFactory factory = new TLTestFactory();

    @IsTest
    static void testCancelOrder() {

        Case testCase = (Case) factory.createSObject(new Case(Subject = 'Test Case', Status = 'New', Order_Number__c='12345') ,true );

        Test.setMock(HttpCalloutMock.class, new MockOrderResponses('/cancel'));
        TLAuraResponse response  = trac_CancelOrderCtlr.cancelOrder(testCase,testCase.Business_Unit__c, testCase.Order_Number__c, '123','','Customer Preference','HBC_MC_CC_002', '1');
        System.assertEquals(true, response.isSuccess);

        testCase = [SELECT Id,Order_is_Cancelled__c, Cancellation_Reason__c FROM Case WHERE Subject='Test Case' LIMIT 1];
        System.assertEquals(true, testCase.Order_is_Cancelled__c);
        System.assertEquals('Customer Preference', testCase.Cancellation_Reason__c);


    }

    @IsTest
    static void testCancelOrderError() {

        Case testCase = (Case) factory.createSObject(new Case(Subject = 'Test Case', Status = 'New', Order_Number__c='12345', Cancellation_Reason__c='Customer Preference') ,true );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOrderResponsesError('/cancel'));
        TLAuraResponse response  = trac_CancelOrderCtlr.cancelOrder(testCase,testCase.Business_Unit__c, testCase.Order_Number__c, '123','','Test','HBC_MC_CC_002', '1');
        Test.stopTest();

        System.assertEquals(false, response.isSuccess);
        Integration_Error__c error = [SELECT Id, Service__c FROM Integration_Error__c LIMIT 1];
        System.assertEquals('Cancel Order', error.Service__c);
    }
}