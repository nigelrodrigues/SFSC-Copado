/**
 * Created by akong on 5/28/2020.
 */

@IsTest
private class trac_IssueAppeasementControllerTest {

    private static final String loyaltyNumber = '1000000';
    private static final String email = 'tester1@testtest.com';

    @TestSetup
    static void setup() {
        trac_TestUtils.setupWebServiceSettings();

        TLTestFactory factory = new TLTestFactory();

        Contact cnt = (Contact)factory.createSObject(
                new Contact(
                        FirstName = 'Testy',
                        LastName = 'Tester',
                        Business_Unit__c = 'Hudson\'s Bay',
                        Loyalty_Number__c = loyaltyNumber,
                        Email = email,
                        Available_Points__c = '145'
                ),
                true
        );
    }

    @IsTest
    static void testSubmitAppeasement() {
        List<Contact> cnts = [SELECT Id, FirstName, LastName, Email, Loyalty_Number__c FROM Contact];

        Test.setMock(HttpCalloutMock.class, new trac_WS_RecordLoyaltyEventTest.RecordEventMock());
        Test.startTest();
        TLAuraResponse resp = trac_IssueAppeasementController.submitAppeasement(loyaltyNumber, email, 10);
        Test.stopTest();

        System.assertEquals(true, resp.isSuccess);
    }

    @IsTest
    static void testSubmitAppeasementFail() {
        List<Contact> cnts = [SELECT Id, FirstName, LastName, Email, Loyalty_Number__c FROM Contact];

        Test.setMock(HttpCalloutMock.class, new trac_WS_RecordLoyaltyEventTest.RecordEventMock('fail'));
        Test.startTest();
        TLAuraResponse resp = trac_IssueAppeasementController.submitAppeasement(loyaltyNumber, email, 10);
        Test.stopTest();

        System.assertEquals(false, resp.isSuccess);
    }

    @IsTest
    static void testSubmitAppeasementError() {
        List<Contact> cnts = [SELECT Id, FirstName, LastName, Email, Loyalty_Number__c FROM Contact];

        Test.setMock(HttpCalloutMock.class, new trac_WS_RecordLoyaltyEventTest.RecordEventMock('error'));
        Test.startTest();
        TLAuraResponse resp = trac_IssueAppeasementController.submitAppeasement(loyaltyNumber, email, 10);
        Test.stopTest();

        System.assertEquals(false, resp.isSuccess);
    }

    @IsTest
    static void testSubmitAppeasementInvalidParams() {
        List<Contact> cnts = [SELECT Id, FirstName, LastName, Email, Loyalty_Number__c FROM Contact];
        cnts[0].Loyalty_Number__c = null;
        update cnts[0];

        Test.setMock(HttpCalloutMock.class, new trac_WS_RecordLoyaltyEventTest.RecordEventMock());
        Test.startTest();

        // null loyaltyNumber
        TLAuraResponse resp = trac_IssueAppeasementController.submitAppeasement(null, null, 10);
        System.assertEquals(false, resp.isSuccess);

        // null email
        resp = trac_IssueAppeasementController.submitAppeasement(loyaltyNumber, null, 10);
        System.assertEquals(false, resp.isSuccess);

        // zero points
        resp = trac_IssueAppeasementController.submitAppeasement(loyaltyNumber, email, 0);
        System.assertEquals(false, resp.isSuccess);

        Test.stopTest();

        System.assertEquals(false, resp.isSuccess);
    }
}