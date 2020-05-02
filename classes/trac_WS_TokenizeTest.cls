/**
 *  @description Tests for trac_WS_Tokenize
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        2/5/2020
 */
@IsTest
public with sharing class trac_WS_TokenizeTest {

    private static final String ENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Tokenex_Endpoint__c;
    private static final String RESOURCE = 'trac_Tokenize';

    @IsTest static void test_SendingWebService() {
        trac_WS_Tokenize webServiceClass = new trac_WS_Tokenize();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(true, webServiceClass.send());
        System.assertNotEquals(null, webServiceClass.tokenizeResponse);
        Test.stopTest();
    }
    @IsTest static void test_SendingWebServiceFailed() {
        trac_WS_Tokenize webServiceClass = new trac_WS_Tokenize();
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