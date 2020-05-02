@IsTest
public with sharing class trac_WS_EmailSearchTest {

    private static final String EMAIL_SEARCH_RESOURCE = 'trac_EmailSearchResource';

    @IsTest static void test_getEmailSearch() {

        trac_WS_EmailSearch webServiceClass = new trac_WS_EmailSearch();
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource(EMAIL_SEARCH_RESOURCE);
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        System.assertEquals(true, webServiceClass.send());
        System.assertNotEquals(null, webServiceClass.emailSearchResponses);
        Test.stopTest();
    }



    @IsTest static void test_SendingWebServiceFailed() {
        trac_WS_EmailSearch webServiceClass = new trac_WS_EmailSearch();
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource(EMAIL_SEARCH_RESOURCE);
        mock.setStatusCode(404);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        System.assertEquals(false, webServiceClass.send());
        System.assertEquals(null, webServiceClass.emailSearchResponses);
        Test.stopTest();
    }

}