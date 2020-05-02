/**
 *  @description Tests for trac_WS_OrderPayment
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        2/26/2020
 */
@IsTest
private class trac_WS_OrderPaymentTest {

    private static final String ENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.OMS_Order_Payment_Endpoint__c;
    private static final String RESOURCE = 'trac_OrderPayment';

    @IsTest static void test_SendingWebService() {
        trac_WS_OrderPayment webServiceClass = new trac_WS_OrderPayment();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(true, webServiceClass.send());
        System.assertNotEquals(null, webServiceClass.orderPaymentResponse);
        Test.stopTest();
    }
    @IsTest static void test_SendingWebServiceFailed() {
        trac_WS_OrderPayment webServiceClass = new trac_WS_OrderPayment();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        myMock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(false, webServiceClass.send());
        Test.stopTest();
    }

}