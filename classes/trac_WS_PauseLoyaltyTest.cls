@IsTest
public with sharing class trac_WS_PauseLoyaltyTest {
    private static final String ENDPOINT = 'https://api-gateway.hbc.io/dev/v1/uad/pause.json?uuid=6368bf5842b80d&external_customer_id=1200&sig=b3ecead6aa66ea674399f15ce4c7c2ba';
    //trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.Get_Order_Details_Endpoint__c;
    private static final String SUCCESS_RESOURCE = 'trac_PauseLoyalty';
    private static final String FAILED_RESOURCE = 'trac_PauseLoyaltyFail';

    @IsTest static void test_SendingWebService() {
        trac_WS_PauseLoyalty webServiceClass = new trac_WS_PauseLoyalty();
        webServiceClass.loyaltyId = '1200657659';
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStatus('OK');
        mock.setStatusCode(200);
        mock.setStaticResource(SUCCESS_RESOURCE);
        Test.setMock(HttpCalloutMock.class, mock);
        System.assertEquals(true, webServiceClass.send());
        System.assertNotEquals(null, webServiceClass.pauseResponse);
        System.assertEquals(true, webServiceClass.pauseResponse.success);
        Test.stopTest();
    }
    @IsTest static void test_SendingWebServiceFailed() {
        trac_WS_PauseLoyalty webServiceClass = new trac_WS_PauseLoyalty();
        Test.startTest();
        webServiceClass.loyaltyId = '1200657659';
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock ();
        mock.setStatus('OK');
        mock.setStatusCode(200);
        mock.setStaticResource(FAILED_RESOURCE);
        Test.setMock(HttpCalloutMock.class, mock);

        System.assertEquals(false, webServiceClass.send());

        System.assertEquals(false, webServiceClass.pauseResponse.success);
        System.assertEquals(201, webServiceClass.pauseResponse.data.code);
        Test.stopTest();
    }
}