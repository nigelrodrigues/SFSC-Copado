/**
 * Created by nrodrigues on 3/23/2020.
 */

@IsTest
private class trac_WS_GetEmailBodyTest {
    private static final String EMAIL_GET_BODY_RESOURCE = 'trac_EmailGetBodyResource';

    @IsTest static void test_getEmailBody() {
        trac_WS_GetEmailBody webServiceClass = new trac_WS_GetEmailBody();
        webServiceClass.id = '106714';
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource(EMAIL_GET_BODY_RESOURCE);
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'text/html');
        Test.setMock(HttpCalloutMock.class, mock);
        System.assertNotEquals(null, webServiceClass.getEmailBody());
        Test.stopTest();
    }

}