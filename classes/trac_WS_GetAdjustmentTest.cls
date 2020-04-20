/**
 *  @description Tests for trac_WS_GetAdjustment
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        2/10/2020
 */
@IsTest
public class trac_WS_GetAdjustmentTest {
    private static final String ENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.SPA_Get_Adjustment_Endpoint__c;
    private static final String RESOURCE = 'trac_GetAdjustment';

    @IsTest static void test_SendingWebService() {
        trac_WS_GetAdjustment webServiceClass = new trac_WS_GetAdjustment();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(true, webServiceClass.send());
        System.assertNotEquals(null, webServiceClass.getAdjustmentResponse);
        Test.stopTest();
    }
    @IsTest static void test_SendingWebServiceFailed() {
        trac_WS_GetAdjustment webServiceClass = new trac_WS_GetAdjustment();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        myMock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(false, webServiceClass.send());
        System.assertEquals(null, webServiceClass.getAdjustmentResponse);
        Test.stopTest();
    }

}