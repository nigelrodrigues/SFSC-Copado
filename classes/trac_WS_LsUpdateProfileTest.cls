@IsTest
public with sharing class trac_WS_LsUpdateProfileTest {
    private static final String ENDPOINT = 'https://api-gateway.hbc.io/dev/v1/ls-update-profile';
    private static final String RESOURCE = 'trac_PauseLoyalty'; // using this as the responses are the same between this API and pause loyalty API

    @IsTest static void test_SendingWebService() {
        trac_WS_LsUpdateProfile webServiceClass = new trac_WS_LsUpdateProfile();
        trac_WS_LsUpdateProfile.LsUpdateProfileRequest request = new trac_WS_LsUpdateProfile.LsUpdateProfileRequest();

        request.loyalty_id = '600294999992297';
        request.first_name = 'John';
        request.last_name = 'Doe';
        request.email = 'johndoe@hbc.com';
        request.new_email = null;
        request.phone_no = null;
        request.address_line_1 = null;
        request.address_line_2 = null;
        request.city = null;
        request.state_province = null;
        request.postal_code = null;
        request.birthdate = null;
        request.casl_email_notification = null;
        request.language_pref = null;
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStatus('OK');
        mock.setStatusCode(200);
        mock.setStaticResource(RESOURCE);
        Test.setMock(HttpCalloutMock.class, mock);
        System.assertEquals(true, webServiceClass.send());
        System.assertNotEquals(null, webServiceClass.lsUpdateProfileResponse);
        Test.stopTest();
    }

    @IsTest static void test_SendingWebServiceFailed() {
        trac_WS_LsUpdateProfile webServiceClass = new trac_WS_LsUpdateProfile();
        trac_WS_LsUpdateProfile.LsUpdateProfileRequest request = new trac_WS_LsUpdateProfile.LsUpdateProfileRequest();

        request.loyalty_id = '600294999992297';
        request.first_name = 'John';
        request.last_name = 'Doe';
        request.email = 'johndoe@hbc.com';
        request.new_email = null;
        request.phone_no = null;
        request.address_line_1 = null;
        request.address_line_2 = null;
        request.city = null;
        request.state_province = null;
        request.postal_code = null;
        request.birthdate = null;
        request.casl_email_notification = null;
        request.language_pref = null;
        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, RESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        myMock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, myMock);
        System.assertEquals(false, webServiceClass.send());
        System.assertEquals(null, webServiceClass.lsUpdateProfileResponse);
        Test.stopTest();
    }
}