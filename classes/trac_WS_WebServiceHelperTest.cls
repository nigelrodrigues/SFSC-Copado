/**
 *  @description Tests for
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        7/12/2018
 */
@isTest
private class trac_WS_WebServiceHelperTest {

    private final static String ENDPOINT = 'https://test.com';
    private static final String RESOURCE = 'trac_GenericResponse';

    @isTest static void test_sendPostRequest() {
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        Test.setMock(HttpCalloutMock.class, myMock);
        trac_WS_WebServiceHelper.sendPostRequest(ENDPOINT, 'test');
        Test.stopTest();
    }

    @isTest static void test_sendPutRequest() {
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        Test.setMock(HttpCalloutMock.class, myMock);
        trac_WS_WebServiceHelper.sendPutRequest(ENDPOINT, 'test');
        Test.stopTest();
    }

    @isTest static void test_sendGetRequest() {
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        Test.setMock(HttpCalloutMock.class, myMock);
        trac_WS_WebServiceHelper.sendGetRequest(ENDPOINT, new Map<String, String>());
        Test.stopTest();
    }

    @isTest static void test_sendDeleteRequest() {
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        Test.setMock(HttpCalloutMock.class, myMock);
        trac_WS_WebServiceHelper.sendDeleteRequest(ENDPOINT, new Map<String, String>());
        Test.stopTest();
    }

    @isTest static void test_sendDeleteRequestObject() {
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        Test.setMock(HttpCalloutMock.class, myMock);
        trac_WS_WebServiceHelper.sendDeleteRequest(ENDPOINT, 'test');
        Test.stopTest();
    }

    @isTest static void test_isValidResponse() {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        Boolean result = trac_WS_WebServiceHelper.isValidResponse(res);
        System.assertEquals(true, result);
    }

    @isTest static void test_getError() {
        HttpResponse res = new HttpResponse();
        String result = trac_WS_WebServiceHelper.getError(res);
    }

    @isTest static void test_cleanString() {
        trac_WS_WebServiceHelper.cleanString('test');
    }

    @isTest static void test_fixString() {
        trac_WS_WebServiceHelper.fixString('test');
    }

    @isTest static void test_stripJsonNulls() {
        trac_WS_WebServiceHelper.stripJsonNulls('test');
    }
}