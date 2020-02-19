/**
 * Tests for TLSobj
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2017-08-01
 * @modified Jeremy Horan, Traction on Demand - 2018-11-07
 * @group TLSObj
 */
@IsTest
private class TLSObjTest {
    private static final Map<SObjectField, SObjectField> TEST_FIELD_MAP = new Map<SObjectField, SObjectField>{
            Account.Name => Opportunity.Name
    };

    @IsTest
    private static void testCopyUsingMapping() {
        final Account a = new Account(Name = 'Test');
        final Opportunity o = new Opportunity();


        Test.startTest();

        TLSObj.copyUsingMapping(a, o, TEST_FIELD_MAP);

        Test.stopTest();


        System.assertEquals(a.Name, o.Name,
                'The appropriate field value was copied as per the field mapping');
    }

    @IsTest
    private static void testGetRecordTypeForName() {
        final RecordType[] testRTs = [SELECT DeveloperName, SobjectType FROM RecordType LIMIT 1];

        // If the org has no RTs, skip this test
        if(testRTs.isEmpty()) {
            return;
        }

        final RecordType testRT = testRTs[0];
        final SObjectType sobjType = ((SObject)Type.forName(testRT.SobjectType).newInstance()).getSObjectType();


        Test.startTest();

        final Id result = TLSObj.getRecordTypeIdForName(sobjType, testRT.DeveloperName);

        Test.stopTest();


        System.assertEquals(testRT.Id, result, 'An Id should be returned');
    }

    @IsTest
    private static void testGetRecordTypeForNameInvalid() {
        final String badRTName = 'A BAD RECORD TYPE THAT DOES NOT EXIST';

        Test.startTest();

        String exceptionMsg;
        try {
            TLSObj.getRecordTypeIdForName(Account.SObjectType, badRTName);
        } catch(Exception e) {
            exceptionMsg = e.getMessage();
        }

        System.assertEquals('Invalid record type name "' + badRTName + '" for SObject type "Account"', exceptionMsg,
                'The correct error message should be generated');
    }

    @IsTest
    private static void testGetFieldValue() {
        final Account parentAccount = new Account(Name = 'test');
        final Account account = new Account(Name = 'test', Parent = parentAccount);

        Test.startTest();

        final String result = (String)TLSObj.getFieldValue(account, 'Name');
        final String parentResult = (String)TLSObj.getFieldValue(account, 'Parent.Name');
        final String nullResult = (String)TLSObj.getFieldValue(null, 'Name');

        Test.stopTest();

        System.assertEquals(account.Name, result, 'The result should be the value of the name field');
        System.assertEquals(parentAccount.Name, parentResult, 'The result should be the value of the parent name field');
        System.assertEquals(null, nullResult, 'The result should be null');
    }

    @IsTest
    static void testCopyFieldValues() {
        String contactJson ='{' +
                '"AccountId":"001f4000002W5brAAC",' +
                '"Id":"003f4000001rSZ6AAM",' +
                '"Account":{' +
                '"Id":"001f4000002W5brAAC",' +
                '"Name":"Spruce Household"' +
                '}' +
                '}';
        Contact source = (Contact) JSON.deserialize(contactJson, Contact.class);
        Contact destination = new Contact(FirstName='test');
        Map<String, SObjectField> sourceToDest = new Map<String, SObjectField> {
                'Account.Name' => Contact.FirstName
        };
        TLSObj.copyFieldValues(source, destination, sourceToDest);
        System.assertEquals('Spruce Household', destination.FirstName);
    }
}