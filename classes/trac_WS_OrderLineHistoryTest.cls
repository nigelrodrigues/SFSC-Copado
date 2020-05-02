/**
 *  @description Tests for trac_WS_OrderLineHistory
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        1/27/2020
 */
@IsTest
public with sharing class trac_WS_OrderLineHistoryTest {
    private static final String ENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.Order_Line_History_Endpoint__c;
    private static final String RESOURCE = 'trac_OrderLineHistory';

    @IsTest static void test_SendingWebService() {

        trac_WS_OrderLineHistory webServiceClass = new trac_WS_OrderLineHistory();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(true, webServiceClass.send());
        System.assertNotEquals(null, webServiceClass.orderLineHistoryResponse);
        Test.stopTest();
    }
    @IsTest static void test_SendingWebServiceFailed() {
        trac_WS_OrderLineHistory webServiceClass = new trac_WS_OrderLineHistory();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        myMock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(false, webServiceClass.send());
        System.assertEquals(null, webServiceClass.orderLineHistoryResponse);
        Test.stopTest();
    }

}