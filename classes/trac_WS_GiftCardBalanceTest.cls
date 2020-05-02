/**
 *  @description Tests for trac_WS_GiftCardBalance
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        2/24/2020
 */
@IsTest
public with sharing class trac_WS_GiftCardBalanceTest {

    private static final String ENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.IPA_Gift_Card_Balance_Endpoint__c;
    private static final String RESOURCE = 'trac_GiftCardBalance';

    @IsTest static void test_SendingWebService() {
        trac_WS_GiftCardBalance webServiceClass = new trac_WS_GiftCardBalance();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(true, webServiceClass.send());
        System.assertNotEquals(null, webServiceClass.giftCardBalanceResponse);
        Test.stopTest();
    }
    @IsTest static void test_SendingWebServiceFailed() {
        trac_WS_GiftCardBalance webServiceClass = new trac_WS_GiftCardBalance();
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