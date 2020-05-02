@IsTest
public with sharing class ShoppingCartAuraControllerTest {
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

        Contact contact = (Contact)factory.createSObject(new Contact(AccountId = account.Id), true);

        Case aCase = (Case)factory.createSObject(new Case(AccountId = account.Id, ContactId = contact.Id, Business_Unit__c = 'Saks'), true);

    }

    @IsTest
    static void testGetAccessTokenCase() {

        Account testAccount = [SELECT Id FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];
        Case testCase =       [SELECT Id FROM Case WHERE AccountId =: testAccount.Id LIMIT 1];
        User sfccUser =       [SELECT Id, SFCC_Username__c, SFCC_Password__c FROM User WHERE Alias = 'CCuser' LIMIT 1];
        TLAuraResponse response;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        System.runAs(sfccUser) {
            response = ShoppingCartAuraController.getAgentAccessToken(testCase.Id);
        }
        Test.stopTest();
        System.assertEquals(true, response.isSuccess);
    }
    
    @IsTest
    static void testErrorGetAccessTokenCase() {
        TLAuraResponse response;
        Account testAccount = [SELECT Id FROM Account WHERE Name =: ACCOUNT_NAME LIMIT 1];
        Case testCase =       [SELECT Id FROM Case WHERE AccountId =: testAccount.Id LIMIT 1];
        User sfccUser =       [SELECT Id, SFCC_Username__c, SFCC_Password__c FROM User WHERE Alias = 'CCuser' LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
        System.runAs(sfccUser) {
            Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('AccessToken'));
            response = ShoppingCartAuraController.getAgentAccessToken('');
        }
        Test.stopTest();
        System.assertEquals(false, response.isSuccess);
    }    

}