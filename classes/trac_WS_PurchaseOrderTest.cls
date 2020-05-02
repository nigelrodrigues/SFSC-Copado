/**
 *  @description Tests for trac_WS_PurchaseOrder
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        3/16/2020
 */
@IsTest
public class trac_WS_PurchaseOrderTest {

    private static final String ENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.OMS_Purchase_Order_Endpoint__c;
    private static final String RESOURCE = 'trac_PurchaseOrder';

    @IsTest static void test_SendingWebService() {
        trac_WS_PurchaseOrder webServiceClass = new trac_WS_PurchaseOrder();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(true, webServiceClass.send());
        System.assertNotEquals(null, webServiceClass.purchaseOrderResponse);
        Test.stopTest();
    }

    @IsTest static void test_SendingWebServiceFailed() {
        trac_WS_PurchaseOrder webServiceClass = new trac_WS_PurchaseOrder();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        myMock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(false, webServiceClass.send());
        System.assertEquals(null, webServiceClass.purchaseOrderResponse);
        Test.stopTest();
    }

}