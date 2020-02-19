/**
 * Tests for TLTrigger
 * @author Grant Adamson, Traction on Demand
 * @date 2017-05-01
 * @group TLTrigger
 */
@IsTest
private class TLTriggerTest {
    private static List<Account> records;
    private static Map<Id, Account> existingRecords;

    static {
        records = new List<Account>{
                new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'test1'),
                new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'test2')
        };

        existingRecords = new Map<Id, Account>{
                records[0].Id => new Account(Id = records[0].Id, Name = 'test1'),
                records[1].Id => new Account(Id = records[1].Id, Name = 'oldtest2')
        };
    }

    @IsTest
    private static void filterByFieldChangedSObjectField() {
        Test.startTest();

        final List<Account> results = TLTrigger.filterByFieldChanged(records, existingRecords, Account.Name);

        Test.stopTest();


        System.assertEquals(1, results.size(), 'One record should be returned');
        System.assertEquals(records[1], results[0],
                'The record returned should be the one with a field change for the specified field');
    }

    @IsTest
    private static void filterByFieldChangedString() {
        Test.startTest();

        final List<Account> results = TLTrigger.filterByFieldChanged(records, existingRecords, 'Name');

        Test.stopTest();


        System.assertEquals(1, results.size(), 'One record should be returned');
        System.assertEquals(records[1], results[0],
                'The record returned should be the one with a field change for the specified field');
    }

    @IsTest
    private static void checkRecordProcess() {
        Test.startTest();

        for (Account account : records) {
            TLTrigger.addRecordProcess(account.Id, 'checkRecordProcess');
        }

        Test.stopTest();


        for (Account account : records) {
            System.assertEquals(true, TLTrigger.wasRecordProcessed(account.Id, 'checkRecordProcess'), 'Record should be processed');
        }

    }
}