@IsTest
public with sharing class trac_WS_LoyaltyPointValueTest {
    private static final String ENDPOINT = 'https://api-stage.500friends.com/2019-01-01/data/points/value';
    private static final String RESOURCE = 'trac_LoyaltyPointValue';

    @IsTest static void test_SendingWebService() {
        trac_WS_LoyaltyPointValue webServiceClass = new trac_WS_LoyaltyPointValue();
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStatus('OK');
        mock.setStatusCode(200);
        mock.setStaticResource(RESOURCE);
        Test.setMock(HttpCalloutMock.class, mock);
        System.assertEquals(true, webServiceClass.send());
        System.assertNotEquals(null, webServiceClass.pointValueResponse);
        Test.stopTest();
    }
    @IsTest static void test_SendingWebServiceFailed() {
        trac_WS_LoyaltyPointValue webServiceClass = new trac_WS_LoyaltyPointValue();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        myMock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(false, webServiceClass.send());
        System.assertEquals(null, webServiceClass.pointValueResponse);
        Test.stopTest();
    }
}