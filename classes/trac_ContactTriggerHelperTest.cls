/**
 * @description Test class for trac_ContactTriggerHelper
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-06-04
 */
@IsTest
private class trac_ContactTriggerHelperTest {

    static final TLTestFactory factory = new TLTestFactory();

    @IsTest
    static void testCheckAccount() {

        List<Contact> contacts = new List<Contact>();

        contacts.add((Contact) factory.createSObject(new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                UCID_Number__c = 'UCID123455',
                Email = 'test@123.com',
                Phone = '1234567890'
        ), false));

        contacts.add((Contact) factory.createSObject(new Contact(
                LastName = 'OnlyLastName',
                FirstName = null,
                Phone = '0987654361'
        ), false));

        contacts.add((Contact) factory.createSObject(new Contact(
                LastName = 'Test Phone',
                Phone = '0987654321'
        ), false));

        contacts.add((Contact) factory.createSObject(new Contact(
                LastName = 'Test UCID',
                UCID_Number__c = 'ACCUCID123'
        ), false));

        contacts.add((Contact) factory.createSObject(new Contact(
                LastName = 'Test EMAIL',
                Email = 'abc@test.com'
        ), false));

        Account acc = (Account)factory.createSObject(new Account(
                Name = 'Test Account',
                UCID_Number__c = 'ACCUCID123',
                Email__c = 'abc@test.com',
                Phone = '0987654321'
        ), true);

        Test.startTest();
        insert contacts;
        Test.stopTest();

        for (Contact con : [SELECT Id, AccountId, FirstName, LastName FROM Contact]) {
            System.assert(con.AccountId != null, 'Account record not created for the Contact: ' + con.FirstName + '' + con.LastName);
        }
    }

    @IsTest
    static void testMergeWithUCID() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseContact());
        Contact con = ((Contact) factory.createSObject(new Contact(
                LastName = 'JACKSON'
        ), true));
    }

    @IsTest
    static void testMergeOnUniqueExternalId() {

        String emailString = TLString.generateRandomEmail();

        Contact duplicateContact = (Contact) factory.createSObject(new Contact(
                Business_Unit__c = trac_ContactConstants.BUSINESS_UNIT_BAY,
                UCID_Number__c = TLString.generateRandomString(10),
                Email = emailString
        ), true);

        Case childCase = (Case) factory.createSObject(new Case(ContactId = duplicateContact.Id), true);

        Contact masterContact = (Contact) factory.createSObject(new Contact(
                Business_Unit__c = trac_ContactConstants.BUSINESS_UNIT_BAY
        ), true);

        masterContact.UCID_Number__c = duplicateContact.UCID_Number__c;
        update masterContact;

        List<Contact> duplicateContacts = [SELECT Id FROM Contact WHERE Id = :duplicateContact.Id];
        System.assertEquals(0, duplicateContacts.size(), 'Duplicate Contacts should be deleted');

        Case queriedChildCase = [SELECT Id, ContactId FROM Case WHERE Id = :childCase.Id];
        System.assertEquals(masterContact.Id, queriedChildCase.ContactId, 'Child Case should be re-parented');

        Contact queriedMasterContact = [SELECT Id, Email FROM Contact WHERE Id = :masterContact.Id];
        System.assertEquals(emailString.toLowerCase(), queriedMasterContact.Email.toLowerCase(), 'Data from merged Contact should be passed to master record');
    }
}