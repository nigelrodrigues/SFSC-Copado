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

        Case aCase = (Case)factory.createSObject(
                new Case(
                        Business_Unit__c = 'Hudson\'s Bay',
                        Subject = 'Test Case'
                ),
                true
        );
    }

    @IsTest
    static void testSubmitAppeasement() {
        List<Contact> cnts = [SELECT Id, FirstName, LastName, Email, Loyalty_Number__c FROM Contact];
        List<Case> caseList = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'Test Case'];

        Test.setMock(HttpCalloutMock.class, new trac_WS_RecordLoyaltyEventTest.RecordEventMock());
        Test.startTest();
        TLAuraResponse resp = trac_IssueAppeasementController.submitAppeasement(loyaltyNumber, email, 10, caseList.get(0));
        Test.stopTest();

        System.assertEquals(true, resp.isSuccess);
    }

    @IsTest
    static void testSubmitAppeasementFail() {
        List<Contact> cnts = [SELECT Id, FirstName, LastName, Email, Loyalty_Number__c FROM Contact];
        List<Case> caseList = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'Test Case'];

        Test.setMock(HttpCalloutMock.class, new trac_WS_RecordLoyaltyEventTest.RecordEventMock('fail'));
        Test.startTest();
        TLAuraResponse resp = trac_IssueAppeasementController.submitAppeasement(loyaltyNumber, email, 10, caseList.get(0));
        Test.stopTest();

        System.assertEquals(false, resp.isSuccess);
    }

    @IsTest
    static void testSubmitAppeasementError() {
        List<Contact> cnts = [SELECT Id, FirstName, LastName, Email, Loyalty_Number__c FROM Contact];
        List<Case> caseList = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'Test Case'];

        Test.setMock(HttpCalloutMock.class, new trac_WS_RecordLoyaltyEventTest.RecordEventMock('error'));
        Test.startTest();
        TLAuraResponse resp = trac_IssueAppeasementController.submitAppeasement(loyaltyNumber, email, 10, caseList.get(0));
        Test.stopTest();

        System.assertEquals(false, resp.isSuccess);
    }

    @IsTest
    static void testSubmitAppeasementInvalidParams() {
        List<Contact> cnts = [SELECT Id, FirstName, LastName, Email, Loyalty_Number__c FROM Contact];
        cnts[0].Loyalty_Number__c = null;
        update cnts[0];

        List<Case> caseList = [SELECT Id, CaseNumber FROM Case WHERE Subject = 'Test Case'];

        Test.setMock(HttpCalloutMock.class, new trac_WS_RecordLoyaltyEventTest.RecordEventMock());
        Test.startTest();

        // null loyaltyNumber
        TLAuraResponse resp = trac_IssueAppeasementController.submitAppeasement(null, null, 10, caseList.get(0));
        System.assertEquals(false, resp.isSuccess);

        // null email
        resp = trac_IssueAppeasementController.submitAppeasement(loyaltyNumber, null, 10, caseList.get(0));
        System.assertEquals(false, resp.isSuccess);

        // zero points
        resp = trac_IssueAppeasementController.submitAppeasement(loyaltyNumber, email, 0, caseList.get(0));
        System.assertEquals(false, resp.isSuccess);

        Test.stopTest();

        System.assertEquals(false, resp.isSuccess);
    }

    @IsTest
    static void testGetProfileAppeasementLimit() {

        List<Bay_Loyalty_Profile_Appeasement_Cap__mdt> profileCaps = [SELECT Id, Label, Max_Appeasement__c
                                                                        FROM Bay_Loyalty_Profile_Appeasement_Cap__mdt];
        System.assert(!profileCaps.isEmpty(), 'Bay Loyalty Profile Appeasement Cap custom metadata not defined');

        Profile p = [SELECT Id FROM Profile WHERE Name = :profileCaps[0].Label][0];
        System.assertNotEquals(null, p, 'Cannot find profile with name ' + profileCaps[0].Label);

        User u = new User(Alias = 'standt', Email='standarduser@testtest.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='test@testtest.hbc.test');
        insert u;

        System.runAs(u) {
            Test.startTest();
            Map<String,String> retmap = trac_IssueAppeasementController.getProfileAppeasementLimit();
            Test.stopTest();

            System.assertEquals(profileCaps[0].Label, retmap.get('profileName'));
            System.assertEquals(profileCaps[0].Max_Appeasement__c, retmap.get('maxAppeasement'));
        }


    }
}