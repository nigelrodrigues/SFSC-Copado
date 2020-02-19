/**
 *  @description Tests for trac_WS_UpdateCustomerDetails
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        6/3/2019
 */
@IsTest
private class trac_WS_UpdateCustomerDetailsTest {
    private static final String ENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.UCID_Update_Endpoint__c;
    private static final String RESOURCE = 'trac_UpdateCustomerDetails';

    /*
     * Chris Shinnimin, Traction on Demand:
     * Temporarily (possibly?) removing the PUT (Update) API call, as per James Cortois Oct. 1, 2019
     * See Jira ticket UAD-1104
     *
    @IsTest static void test_SendingWebService() {
        trac_WS_UpdateCustomerDetails webServiceClass = new trac_WS_UpdateCustomerDetails();
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(true, webServiceClass.send());
        System.assertNotEquals(null, webServiceClass.updateCustomerDetailsResponse);
        Test.stopTest();
    }
    *
    * END Jira ticket UAD-1104
    */

    @IsTest static void test_SendingWebServiceFailed() {
        trac_WS_UpdateCustomerDetails webServiceClass = new trac_WS_UpdateCustomerDetails();
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