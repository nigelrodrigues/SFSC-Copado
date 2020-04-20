/**
* @description: Test Class for trac_SPA_CalculatorController
* @author     : Piyush Bansal, Traction on Demand.
* @date       : 2/11/2020
*/

@IsTest
private class trac_SPA_CalculatorControllerTest {
    private static final String ENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.SPA_Get_Order_Adjustments_Endpoint__c;
    private static final String RESOURCE = 'trac_GetOrderAdjustments';
    private static final String UPDATE_ENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.SPA_Update_Adjustment_Endpoint__c;
    private static final String UPDATE_RESOURCE = 'trac_UpdateAdjustment';
    
    @IsTest static void test_SendingWebService() {
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertNotEquals(null, trac_SPA_CalculatorController.getOrderAdjustments(null));
        Test.stopTest();
    }
    @IsTest static void test_SendingWebServiceFailed() {
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        myMock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, myMock);
        List<trac_Adjustment> lineAdjustments = trac_SPA_CalculatorController.getOrderAdjustments(null);
        System.assertEquals(0, lineAdjustments.size());
        Test.stopTest();
    }
    
    @IsTest static void test_UpdateWebService() {
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(UPDATE_ENDPOINT, UPDATE_RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(true, trac_SPA_CalculatorController.setOrderAdjustments(null,null));
        Test.stopTest();
    }
    @IsTest static void test_UpdateWebServiceFailed() {
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(UPDATE_ENDPOINT, UPDATE_RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        myMock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(false, trac_SPA_CalculatorController.setOrderAdjustments(null,null));
        Test.stopTest();
    }
    
    @IsTest static void testgetSPATypes(){
        Test.startTest();
        System.assertNotEquals(null,trac_SPA_CalculatorController.getSPATypes());
        Test.stopTest();
    }
    
    
    
}