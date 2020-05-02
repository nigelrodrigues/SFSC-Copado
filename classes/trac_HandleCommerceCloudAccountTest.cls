/**
 * Created by nrodrigues on 4/3/2020.
 */

@IsTest
private class trac_HandleCommerceCloudAccountTest {
    private final static String ACCOUNT_NAME = 'SFCC Account';

    @TestSetup
    static void setup() {

        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        TLTestFactory factory = new TLTestFactory();
        User sfccUser = (User)factory.createSObject(new User(LastName = 'User',
                FirstName='SFCC',
                Alias = 'CCuser',
                Email = 'sfcc@example.com',
                Username = 'sfcc@example.com',
                ProfileId = profileId.id,
                TimeZoneSidKey = 'GMT',
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US',
                SFCC_Username__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
                SFCC_Password__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
        ), true);

        Account account = (Account)factory.createSObject(new Account(Name = ACCOUNT_NAME), true);

        Contact contact = (Contact)factory.createSObject(
                new Contact(AccountId = account.Id, FirstName = 'Test', LastName = 'Test',
                        Email = 'testuser@example.com', Business_Unit__c = 'Saks'), true);

        Case aCase = (Case)factory.createSObject(new Case(AccountId = account.Id, ContactId = contact.Id, Business_Unit__c = 'Saks'), true);

    }

    @IsTest
    static void testCreateNewUser() {
        TLAuraResponse response;
        Account testAccount = [SELECT Id FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];
        Case testCase =       [SELECT Id FROM Case WHERE AccountId =: testAccount.Id LIMIT 1];
        User sfccUser =       [SELECT Id, SFCC_Username__c, SFCC_Password__c FROM User WHERE Alias = 'CCuser' LIMIT 1];
        Contact testContact =     [SELECT Id, FirstName, LastName, Business_Unit__c, Email FROM Contact WHERE FirstName = 'Test' LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerAuthAccessToken'));

        System.runAs(sfccUser) {
            response = trac_HandleCommerceCloudAccount.createNewUser(testContact.Email, testContact.FirstName,
                                            testContact.LastName, testContact.Business_Unit__c, testContact.Id);
        }

        System.assertEquals(true, response.isSuccess);
        testContact = [SELECT Id, SFCC_Customer_Id__c, Business_Unit__c FROM Contact WHERE FirstName = 'Test' LIMIT 1];
        System.assertEquals(false, String.isBlank(testContact.SFCC_Customer_Id__c));

        Test.stopTest();

    }

    @IsTest
    static void testCreateAddress() {
        TLAuraResponse response;
        Account testAccount = [SELECT Id FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];
        Case testCase =       [SELECT Id FROM Case WHERE AccountId =: testAccount.Id LIMIT 1];
        User sfccUser =       [SELECT Id, SFCC_Username__c, SFCC_Password__c FROM User WHERE Alias = 'CCuser' LIMIT 1];
        Contact testContact =     [SELECT Id, FirstName, LastName, Business_Unit__c, Email FROM Contact WHERE FirstName = 'Test' LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerAuthAccessToken'));
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('/addresses'));

        testContact = [SELECT Id, SFCC_Customer_Id__c, Business_Unit__c FROM Contact WHERE FirstName = 'Test' LIMIT 1];
        System.runAs(sfccUser) {
            response = trac_HandleCommerceCloudAccount.createAddress(String.valueOf(testContact.SFCC_Customer_Id__c),
                    '5145145140', 'H3H2C3', testContact.Business_Unit__c);
        }

        System.assertEquals(true, response.isSuccess);

        Test.stopTest();

    }

    @isTest
    static void testResetPassword()
    {
        Account testAccount = [SELECT Id FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];
        Case testCase =       [SELECT Id FROM Case WHERE AccountId =: testAccount.Id LIMIT 1];
        User sfccUser =       [SELECT Id, SFCC_Username__c, SFCC_Password__c FROM User WHERE Alias = 'CCuser' LIMIT 1];
        Contact testContact =     [SELECT Id, FirstName, LastName, Business_Unit__c, Email FROM Contact WHERE FirstName = 'Test' LIMIT 1];

        testContact = [SELECT Id, Email, Business_Unit__c,SFCC_Customer_Id__c, SFCC_Customer_Number__c FROM Contact WHERE FirstName = 'Test' LIMIT 1 ];
        testContact.SFCC_Customer_Id__c ='acI4Lg0fMrBZ6shBanPpvkIKHZ';
        testContact.SFCC_Customer_Number__c = '00001140';
        testContact.Email = 'mail@example.com';
        update testContact;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerAuthAccessToken'));

        Boolean isSuccessful = true;

        System.runAs(sfccUser) {
            try {
                trac_HandleCommerceCloudAccount.resetPassword(testContact.Email, testContact.Business_Unit__c);
            }
            catch(Exception e)
            {
                isSuccessful = false;
            }
        }
        Test.stopTest();
        System.assertEquals(true, isSuccessful);
    }

    @isTest
    static void testGetCustomerAccountStatus()
    {
        TLAuraResponse response;
        Account testAccount = [SELECT Id FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];
        Case testCase =       [SELECT Id FROM Case WHERE AccountId =: testAccount.Id LIMIT 1];
        User sfccUser =       [SELECT Id, SFCC_Username__c, SFCC_Password__c FROM User WHERE Alias = 'CCuser' LIMIT 1];
        Contact testContact =     [SELECT Id, FirstName, LastName, Business_Unit__c, Email FROM Contact WHERE FirstName = 'Test' LIMIT 1];

        testContact = [SELECT Id, Email, Business_Unit__c,SFCC_Customer_Id__c, SFCC_Customer_Number__c FROM Contact WHERE FirstName = 'Test' LIMIT 1 ];
        testContact.SFCC_Customer_Id__c ='acI4Lg0fMrBZ6shBanPpvkIKHZ';
        testContact.SFCC_Customer_Number__c = '1234567890';
        testContact.Email = 'mail@example.com';
        update testContact;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerAuthAccessToken'));
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('?expand=addresses,paymentinstruments'));

            System.runAs(sfccUser) {
                response = trac_HandleCommerceCloudAccount.getCustomerAccountStatus(testContact.SFCC_Customer_Id__c, testContact.Business_Unit__c);
            }

        System.assertEquals(true, response.isSuccess);
        //Testing that customer account is active. Account update is processed from Lightning component.
        System.assertEquals(true, response.returnValuesMap.get('enabled'));

        response = trac_HandleCommerceCloudAccount.getToken(String.valueOf(testCase.Id));
        Test.stopTest();

        //trac_SFCC_ErrorClass

    }


    @isTest
    static void testGetCustomerAccountStatusError()
    {
        TLAuraResponse response;
        Account testAccount = [SELECT Id FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];
        Case testCase =       [SELECT Id FROM Case WHERE AccountId =: testAccount.Id LIMIT 1];
        User sfccUser =       [SELECT Id, SFCC_Username__c, SFCC_Password__c FROM User WHERE Alias = 'CCuser' LIMIT 1];
        Contact testContact =     [SELECT Id, FirstName, LastName, Business_Unit__c, Email FROM Contact WHERE FirstName = 'Test' LIMIT 1];

        testContact = [SELECT Id, Email, Business_Unit__c,SFCC_Customer_Id__c, SFCC_Customer_Number__c FROM Contact WHERE FirstName = 'Test' LIMIT 1 ];
        testContact.SFCC_Customer_Id__c ='acI4Lg0fMrBZ6shBanPpvkIKHZ';
        testContact.SFCC_Customer_Number__c = '1234567890';
        testContact.Email = 'mail@example.com';
        update testContact;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new trac_SFCC_ErrorClass('AccessToken'));
        Test.setMock(HttpCalloutMock.class, new trac_SFCC_ErrorClass('CustomerAuthAccessToken'));
        Test.setMock(HttpCalloutMock.class, new trac_SFCC_ErrorClass('?expand=addresses,paymentinstruments'));

        System.runAs(sfccUser) {
            response = trac_HandleCommerceCloudAccount.getCustomerAccountStatus(testContact.SFCC_Customer_Id__c, testContact.Business_Unit__c);
        }

        System.assertEquals(false, response.isSuccess);
        Test.stopTest();

    }

    @IsTest
    static void testCreateAddressError() {
        TLAuraResponse response;
        Account testAccount = [SELECT Id FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];
        Case testCase =       [SELECT Id FROM Case WHERE AccountId =: testAccount.Id LIMIT 1];
        User sfccUser =       [SELECT Id, SFCC_Username__c, SFCC_Password__c FROM User WHERE Alias = 'CCuser' LIMIT 1];
        Contact testContact =     [SELECT Id, FirstName, LastName, Business_Unit__c, Email FROM Contact WHERE FirstName = 'Test' LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new trac_SFCC_ErrorClass('AccessToken'));
        Test.setMock(HttpCalloutMock.class, new trac_SFCC_ErrorClass('CustomerAuthAccessToken'));
        Test.setMock(HttpCalloutMock.class, new trac_SFCC_ErrorClass('/addresses'));

        testContact = [SELECT Id, SFCC_Customer_Id__c, Business_Unit__c FROM Contact WHERE FirstName = 'Test' LIMIT 1];
        System.runAs(sfccUser) {
            response = trac_HandleCommerceCloudAccount.createAddress(String.valueOf(testContact.SFCC_Customer_Id__c),
                    '5145145140', 'H3H2C3', testContact.Business_Unit__c);
        }

        System.assertEquals(false, response.isSuccess);

        Test.stopTest();

    }

    @IsTest
    static void testCreatenewAccountError() {
        TLAuraResponse response;
        Account testAccount = [SELECT Id FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];
        Case testCase =       [SELECT Id FROM Case WHERE AccountId =: testAccount.Id LIMIT 1];
        User sfccUser =       [SELECT Id, SFCC_Username__c, SFCC_Password__c FROM User WHERE Alias = 'CCuser' LIMIT 1];
        Contact testContact =     [SELECT Id, FirstName, LastName, Business_Unit__c, Email FROM Contact WHERE FirstName = 'Test' LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new trac_SFCC_ErrorClass('AccessToken'));
        Test.setMock(HttpCalloutMock.class, new trac_SFCC_ErrorClass('CustomerAuthAccessToken'));
        Test.setMock(HttpCalloutMock.class, new trac_SFCC_ErrorClass('v19_1/customers'));

        testContact = [SELECT Id, SFCC_Customer_Id__c,FirstName,Email, Business_Unit__c, LastName FROM Contact WHERE FirstName = 'Test' LIMIT 1];
        System.runAs(sfccUser) {
            response = trac_HandleCommerceCloudAccount.createNewUser(testContact.Email, testContact.FirstName,
                    testContact.LastName, testContact.Business_Unit__c, testContact.Id);
        }

        System.assertEquals(false, response.isSuccess);

        Integration_Error__c errorRecord = [SELECT Id, Service__c FROM Integration_Error__c];
        System.assertEquals('Create new Commerce Cloud account: Invalid credentials', errorRecord.Service__c);
        Test.stopTest();

    }






}