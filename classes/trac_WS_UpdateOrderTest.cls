/**
 *  @description Tests for trac_WS_UpdateOrder
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        7/3/2019
 */
@IsTest
public with sharing class trac_WS_UpdateOrderTest {
    private static final String ENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.Update_Order_Endpoint__c;
    private static final String RESOURCE = 'trac_UpdateOrder';

    @IsTest static void test_SendingWebService() {
        trac_WS_UpdateOrder webServiceClass = new trac_WS_UpdateOrder();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(true, webServiceClass.send());
        System.assertNotEquals(null, webServiceClass.updateOrderResponse);
        Test.stopTest();
    }
    @IsTest static void test_SendingWebServiceFailed() {
        trac_WS_UpdateOrder webServiceClass = new trac_WS_UpdateOrder();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        myMock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(false, webServiceClass.send());
        System.assertEquals(null, webServiceClass.updateOrderResponse);
        Test.stopTest();
    }

}