/**
 * Created by akong on 5/28/2020.
 */

@IsTest
private class trac_IssueAppeasementControllerTest {

    @TestSetup
    static void setup() {
        trac_TestUtils.setupWebServiceSettings();

        TLTestFactory factory = new TLTestFactory();

        Contact cnt = (Contact)factory.createSObject(
                new Contact(
                        FirstName = 'Testy',
                        LastName = 'Tester',
                        Business_Unit__c = 'Hudson\'s Bay',
                        Loyalty_Number__c = '1000000',
                        Email = 'tester1@testtest.com',
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
        TLAuraResponse resp = trac_IssueAppeasementController.submitAppeasement(cnts[0].Id, 10, 0);
        Test.stopTest();

        System.assertEquals(true, resp.isSuccess);
    }

    @IsTest
    static void testSubmitAppeasementFail() {
        List<Contact> cnts = [SELECT Id, FirstName, LastName, Email, Loyalty_Number__c FROM Contact];

        Test.setMock(HttpCalloutMock.class, new trac_WS_RecordLoyaltyEventTest.RecordEventMock('fail'));
        Test.startTest();
        TLAuraResponse resp = trac_IssueAppeasementController.submitAppeasement(cnts[0].Id, 10, 0);
        Test.stopTest();

        System.assertEquals(false, resp.isSuccess);
    }

    @IsTest
    static void testSubmitAppeasementError() {
        List<Contact> cnts = [SELECT Id, FirstName, LastName, Email, Loyalty_Number__c FROM Contact];

        Test.setMock(HttpCalloutMock.class, new trac_WS_RecordLoyaltyEventTest.RecordEventMock('error'));
        Test.startTest();
        TLAuraResponse resp = trac_IssueAppeasementController.submitAppeasement(cnts[0].Id, 10, 0);
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

        // null contactId
        TLAuraResponse resp = trac_IssueAppeasementController.submitAppeasement(null, 10, 0);
        System.assertEquals(false, resp.isSuccess);

        // zero points
        resp = trac_IssueAppeasementController.submitAppeasement(cnts[0].Id, 0, 0);
        System.assertEquals(false, resp.isSuccess);

        // contact missing Loyalty_Number__c
        resp = trac_IssueAppeasementController.submitAppeasement(cnts[0].Id, 10, 0);
        System.assertEquals(false, resp.isSuccess);

        // non-existant contact
        resp = trac_IssueAppeasementController.submitAppeasement('003000000000000AAA', 10, 0);
        System.assertEquals(false, resp.isSuccess);

        Test.stopTest();

        System.assertEquals(false, resp.isSuccess);
    }
}