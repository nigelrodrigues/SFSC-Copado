/**
 *  @description Tests for trac_WS_OrderReturns
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        3/17/2020
 */
@IsTest
public class trac_WS_OrderReturnsTest {

    private static final String ENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.Cancel_Order_Endpoint__c;
    private static final String RESOURCE = 'trac_OrderReturns';

    @IsTest static void test_SendingWebService() {
        trac_WS_OrderReturns webServiceClass = new trac_WS_OrderReturns();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(true, webServiceClass.send());
        System.assertNotEquals(null, webServiceClass.orderReturnsResponse);
        Test.stopTest();
    }
    @IsTest static void test_SendingWebServiceFailed() {
        trac_WS_OrderReturns webServiceClass = new trac_WS_OrderReturns();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        myMock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(false, webServiceClass.send());
        System.assertEquals(null, webServiceClass.orderReturnsResponse);
        Test.stopTest();
    }

}