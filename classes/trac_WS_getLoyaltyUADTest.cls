@IsTest
public with sharing class trac_WS_getLoyaltyUADTest {
    private static final String ENDPOINT = 'https://api-gateway.hbc.io/dev/v1/customer-lookup-uad';
    //trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.Get_Order_Details_Endpoint__c;
    private static final String RESOURCE = 'trac_GetLoyaltyUAD';

    @IsTest static void test_SendingWebService() {
        trac_WS_GetLoyaltyUAD webServiceClass = new trac_WS_GetLoyaltyUAD();
        trac_WS_GetLoyaltyUAD.LoyaltyUADRequest request = new trac_WS_GetLoyaltyUAD.LoyaltyUADRequest();

        request.loyalty_id = '600294999992297';
        request.banner_id = '4';
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStatus('OK');
        mock.setStatusCode(200);
        mock.setStaticResource(RESOURCE);
        Test.setMock(HttpCalloutMock.class, mock);
        System.assertEquals(true, webServiceClass.send());
        System.assertNotEquals(null, webServiceClass.loyaltyUADResponse);
        Test.stopTest();
    }

    @IsTest static void test_SendingWebServiceFailed() {
        trac_WS_GetLoyaltyUAD webServiceClass = new trac_WS_GetLoyaltyUAD();
        trac_WS_GetLoyaltyUAD.LoyaltyUADRequest request = new trac_WS_GetLoyaltyUAD.LoyaltyUADRequest();

        request.loyalty_id = '60029499999229';
        request.banner_id = '4';
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        myMock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(false, webServiceClass.send());
        System.assertEquals(null, webServiceClass.loyaltyUADResponse);
        Test.stopTest();
    }
}