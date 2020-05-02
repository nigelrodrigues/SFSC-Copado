/**
 * Created by nrodrigues on 3/3/2020.
 */

@IsTest
public with sharing class trac_WS_ResendEmailTest {
    private static final String ENDPOINT =trac_WS_WebServiceHelper.webServiceSettings.CNS_Send_Email_Endpoint__c;
    private static final String RESOURCE = 'trac_WS_ResendEmailResource';

    @IsTest static void test_SendingWebService() {
        trac_WS_ResendEmail webServiceClass = new trac_WS_ResendEmail();
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('trac_WS_ResendEmailResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

       /* MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');*/
        Test.setMock(HttpCalloutMock.class, mock);
        System.assertEquals(true, webServiceClass.send());
        System.assertNotEquals(null, webServiceClass.resendEmailResponse);
        Test.stopTest();
    }
    @IsTest static void test_SendingWebServiceFailed() {
        trac_WS_ResendEmail webServiceClass = new trac_WS_ResendEmail();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        myMock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(false, webServiceClass.send());
        System.assertEquals(null, webServiceClass.resendEmailResponse);
        Test.stopTest();
    }

}