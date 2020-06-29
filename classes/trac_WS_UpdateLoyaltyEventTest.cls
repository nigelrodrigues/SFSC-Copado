@IsTest
public with sharing class trac_WS_UpdateLoyaltyEventTest {
    private static final String ENDPOINT = 'https://api-stage.500friends.com/2019-01-01/data/customer/update_customer_info';
    //trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.Get_Order_Details_Endpoint__c;

    private static final String RESOURCE = 'trac_UpdateLoyaltyEvent';

    @IsTest static void test_SendingWebService() {
        trac_WS_UpdateLoyaltyEvent webServiceClass = new trac_WS_UpdateLoyaltyEvent();
        webServiceClass.loyaltyId = '600294999992297';
        webServiceClass.firstName = 'John';
        webServiceClass.lastName = 'Doe';
        webServiceClass.email = 'johndoe@hbc.com';
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStatus('OK');
        mock.setStatusCode(200);
        mock.setStaticResource(RESOURCE);
        Test.setMock(HttpCalloutMock.class, mock);
        System.assertEquals(true, webServiceClass.send());
        System.assertNotEquals(null, webServiceClass.updateLoyaltyEventResponse);
        Test.stopTest();
    }

    @IsTest static void test_SendingWebServiceFailed() {
        trac_WS_UpdateLoyaltyEvent webServiceClass = new trac_WS_UpdateLoyaltyEvent();
        webServiceClass.loyaltyId = '600294999992297';
        webServiceClass.firstName = 'John';
        webServiceClass.lastName = 'Doe';
        webServiceClass.email = 'johndoe@hbc.com';
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setHeader('Content-Type', 'application/json');
        mock.setStatusCode(404);
        mock.setStaticResource(RESOURCE);
        Test.setMock(HttpCalloutMock.class, mock);
        System.assertEquals(false, webServiceClass.send());
        System.assertEquals(null, webServiceClass.updateLoyaltyEventResponse);
        Test.stopTest();
    }
}