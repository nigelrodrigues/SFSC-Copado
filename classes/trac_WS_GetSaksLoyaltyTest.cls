/**
 *  @description Tests for trac_WS_GetSaksLoyalty
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        2/21/2020
 */
@IsTest
public with sharing class trac_WS_GetSaksLoyaltyTest {

    private static final String ENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.Loyalty_Saks_Endpoint__c;
    private static final String RESOURCE = 'trac_GetSaksLoyalty';

    @IsTest static void test_SendingWebService() {
        trac_WS_GetSaksLoyalty webServiceClass = new trac_WS_GetSaksLoyalty();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(true, webServiceClass.send());
        System.assertNotEquals(null, webServiceClass.getSaksLoyaltyResponse);
        Test.stopTest();
    }

    @IsTest static void test_SendingWebServiceFailed() {
        trac_WS_GetSaksLoyalty webServiceClass = new trac_WS_GetSaksLoyalty();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        myMock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(false, webServiceClass.send());
        System.assertEquals(null, webServiceClass.getSaksLoyaltyResponse);
        Test.stopTest();
    }

}