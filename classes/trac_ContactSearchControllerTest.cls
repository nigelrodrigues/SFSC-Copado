/**
 * @description Test class for trac_ContactSearchController
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-07-08
 */
@IsTest
private class trac_ContactSearchControllerTest {

    static final TLTestFactory factory = new TLTestFactory();

    @IsTest
    static void testGetContacts() {
        /*Web_Service_Settings__c settings = new Web_Service_Settings__c(
                API_Key__c = 'BAgIdATJjI1jJ5ytc0Onq7JQYOrGNfsNPPoKxUN5',
                Create_Order_Endpoint__c = '/orders',
                Get_Order_Details_Endpoint__c = '/orders/details',
                UCID_Create_Endpoint__c = '/customers/me',
                Timeout__c = 120000,
                Base_Url__c = 'https://uat.thebay.com/live',
                Update_Order_Endpoint__c = '/orders',
                Get_Order_List_Endpoint__c = '/orders/list',
                UCID_Update_Endpoint__c = '/customers/me',
                UCID_Query_Endpoint__c = '/customers/search'
        );
        insert settings;*/
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List<Contact> contacts = new List<Contact>();
        Contact con = new Contact(LastName = 'Test',Order_Number__c='1234',Business_Unit__c='MHF');
        contacts = trac_ContactSearchController.getContacts(con, false);
        System.assert(contacts.size() > 0, 'Contacts not found.');
    }

    @IsTest
    static void testUpsertContact() {
        Contact con = (Contact)factory.createSObject(new Contact(UCID_Number__c = 'UCID123455', Business_Unit__c = 'MHF'), false);
        Test.startTest();
        Contact updatedCon = trac_ContactSearchController.upsertContact(con);
        Test.stopTest();
        System.assertEquals(con.Business_Unit__c + '-' + con.UCID_Number__c, updatedCon.Unique_External_Id__c, 'Contact not updated.');
    }

    @IsTest
    static void testUpdateCase() {
        Contact con = (Contact)factory.createSObject(new Contact(Business_Unit__c = 'MHF'), true);
        Case cs = (Case)factory.createSObject(new Case(), true);
        Test.startTest();
        Id caseId = trac_ContactSearchController.updateCase(con, cs.Id);
        Test.stopTest();
        Case updatedCase = [SELECT Id, Business_Unit__c FROM Case WHERE Id =: caseId];
        System.assertEquals(con.Business_Unit__c, updatedCase.Business_Unit__c, 'Case not updated.');
    }
    
    @IsTest
    static void testGetBusinessUnit(){
        Case cs = (Case)factory.createSObject(new Case(), true);
        Case retCase;
        retCase = trac_ContactSearchController.getBusinessUnit(cs.id);
        System.assert(retCase != null, 'Case not found.');
    }
    
    @IsTest
    static void testLinkContactWithCase(){
        Contact con = (Contact)factory.createSObject(new Contact(Business_Unit__c = 'MHF', Order_Number__c = null), true);
        Case cs = (Case)factory.createSObject(new Case(), true);
        Test.startTest();
        Id caseId = trac_ContactSearchController.linkContactWithCase(con.id, cs.Id);
        Test.stopTest();
        Case updatedCase = [SELECT Id, ContactId FROM Case WHERE Id =: caseId];
        System.assertEquals(con.id, updatedCase.ContactId, 'Contact not linked with Case.');
        System.assertEquals(false, String.isBlank(trac_ContactSearchController.buildQuery(con)));
        trac_ContactSearchController.getContacts(con, false);

    }

    @isTest
    static void testGetContactFromResponse()
    {
        Contact testContact = new Contact(LastName='Test', Order_Number__c = '12345', Business_Unit__c ='SAKS');
        insert testContact;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new trac_CustomerDetailsResponse());
        Contact contact = trac_WS_CustomerUtils.getContactFromOrderByContact(testContact);
        Test.stopTest();
        System.assertEquals(true, contact!=null);
    }

    @isTest
    static void testSyncContactFromExternal()
    {
        Contact testContact = new Contact(LastName='Test', Order_Number__c = '12345', Business_Unit__c ='SAKS', Email ='test@example.com');
        insert testContact;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new trac_GetCustomerDetailsResource());
        trac_WS_CustomerUtils.syncContactFromExternal(testContact);
        Test.stopTest();
    }
}