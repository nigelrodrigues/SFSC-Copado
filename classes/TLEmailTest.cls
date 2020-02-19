/**
 *  @description Tests for TLEmail
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        11/1/2018
 */
@IsTest
private class TLEmailTest {

    @IsTest
    private static void test_sendEmail() {
        String email1 = 'test1@example.com';
        String email2 = 'test2@example.com';
        String subject = 'Apex Test Class';
        String message = 'Running Test';

        List<Messaging.SendEmailResult> results = TLEmail.sendEmail(new List<String>{email1, email2}, subject, message);

        System.assertEquals(1, results.size(), 'A single email should have been sent');
        System.assert(results[0].isSuccess(), 'Email should have been successful');
    }

    @IsTest
    private static void test_sendEmails() {
        String email1 = 'test1@example.com';
        String email2 = 'test2@example.com';
        String subject = 'Apex Test Class';
        String message = 'Running Test';

        List<Messaging.SendEmailResult> results = TLEmail.sendEmails(new List<String>{email1, email2}, subject, message);

        System.assertEquals(2, results.size(), 'A single email should have been sent');
        System.assert(results[0].isSuccess(), 'Email 1 should have been successful');
        System.assert(results[1].isSuccess(), 'Email 2 should have been successful');
    }
}