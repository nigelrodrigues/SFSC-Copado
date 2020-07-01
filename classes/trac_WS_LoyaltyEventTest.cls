@IsTest
public with sharing class trac_WS_LoyaltyEventTest {
    private static final String ENDPOINT = ''+trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_Base_Endpoint__c
            + trac_WS_WebServiceHelper.webServiceSettings.Bay_Event_History__c;
    private static final String RESOURCE = 'trac_LoyaltyEventTest';

    @IsTest static void test_SendingWebService() {
        trac_WS_LoyaltyEvent webServiceClass = new trac_WS_LoyaltyEvent();
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource(RESOURCE);
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        System.assertEquals(true, webServiceClass.send('greg-enroll@test.com','295810877'));
        System.assertNotEquals(null, webServiceClass.eventResponse);
        Test.stopTest();
    }
    @IsTest static void test_SendingWebServiceFailed() {
        trac_WS_LoyaltyEvent webServiceClass = new trac_WS_LoyaltyEvent();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        myMock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(false, webServiceClass.send('greg-enroll@test.com','295810877'));
        System.assertEquals(null, webServiceClass.eventResponse);
        Test.stopTest();
    }

}