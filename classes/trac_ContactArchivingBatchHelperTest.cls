/**
 * @description Test class for trac_ContactArchivingBatchHelper
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-06-11
 */
@isTest
private class trac_ContactArchivingBatchHelperTest {

    static final TLTestFactory factory = new TLTestFactory();
    static final Integer daysInactive = -1;

    @isTest
    static void testDeleteContacts() {
        Archive_Settings__c archieveSet = new Archive_Settings__c(Name = 'Default', Days_Inactive_To_Archive__c = daysInactive);
        insert archieveSet;

        Contact testCon = (Contact) factory.createSObject(new Contact(), true);
        Case testCase = (Case) factory.createSObject(new Case(ContactId = testCon.Id, Status = 'Closed'), true);

        Test.startTest();
        trac_ContactArchivingBatch cab = new trac_ContactArchivingBatch();
        Database.executeBatch(cab);
        Test.stopTest();

        List<Case> cases = new List<Case>();
        cases = [SELECT Id FROM Case];
        System.assertEquals(0, cases.size(), 'Cases not deleted.');
        List<Contact> contacts = [SELECT Id FROM Contact];
        System.assertEquals(0, contacts.size(), 'Contact not deleted.');
        List<Account> accounts = [SELECT Id FROM Account];
        System.assertEquals(0, accounts.size(), 'Account not deleted.');
    }
}