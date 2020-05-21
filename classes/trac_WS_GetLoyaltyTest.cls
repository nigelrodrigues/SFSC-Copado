@IsTest
public class trac_WS_GetLoyaltyTest {
    private static final String ENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.Get_Order_Details_Endpoint__c;
    private static final String RESOURCE = 'trac_GetLoyalty';

    @IsTest static void test_SendingWebService() {
        trac_WS_GetLoyalty webServiceClass = new trac_WS_GetLoyalty();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(true, webServiceClass.send());
        System.assertNotEquals(null, webServiceClass.loyaltyResponse);
        Test.stopTest();
    }
    @IsTest static void test_SendingWebServiceFailed() {
        trac_WS_GetLoyalty webServiceClass = new trac_WS_GetLoyalty();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        myMock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(false, webServiceClass.send());
        System.assertEquals(null, webServiceClass.loyaltyResponse);
        Test.stopTest();
    }
}