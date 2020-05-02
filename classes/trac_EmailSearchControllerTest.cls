/**
 * Created by nrodrigues on 3/23/2020.
 */

@IsTest
private class trac_EmailSearchControllerTest {


    @isTest
    static void testGetAssociatedEmails() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCNS_Email('stqa/search_log'));
        String orderNumber = '73108556';
        String businessUnit = 'saks';
        List<trac_WS_EmailSearch.EmailSearchResponse> res = (List<trac_WS_EmailSearch.EmailSearchResponse>) trac_EmailSearchController.getAssociatedEmails(businessUnit, orderNumber, '','', '').returnValuesMap.get('associatedEmails');
        //System.assertEquals(res != null, 'Emails not retrived successfully.');
        //System.debug('@@@@@res: ' + res);
    }

    @isTest
    static void testRetrieveEmails() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCNS_Email('/preview/email'));
        TLAuraResponse response = trac_EmailSearchController.retrieveEmailBody('12345');
        System.assertEquals(true, response.isSuccess);
    }

    @isTest
    static void testResendEmail() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCNS_Email('/resend_rendered_message/'));
        TLAuraResponse response = trac_EmailSearchController.resendEmailToCustomer('12345', 'test@test.com');
        System.assertEquals(true, response.isSuccess);
        System.assertEquals(1, response.returnValuesMap.get('emailSent'));
    }

    @isTest
    static void testResendEmailErrors() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCNS_EmailErrors('/resend_rendered_message/'));
        TLAuraResponse response = trac_EmailSearchController.resendEmailToCustomer('12345', 'test@test.com');
        System.assertEquals(false, response.isSuccess);

    }

    @isTest
    static void testGetAssociatedEmailsError() {
        TLAuraResponse response;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseCNS_EmailErrors('/search_log'));
        String orderNumber = '73108556';
        String businessUnit = 'saks';
        Boolean isSuccessful = true;
        try {
            response = trac_EmailSearchController.getAssociatedEmails(businessUnit, orderNumber, '', '', '');
        }
        catch(Exception e)
        {
            isSuccessful = false;
        }

        System.assertEquals(false, response.isSuccess);
    }
}