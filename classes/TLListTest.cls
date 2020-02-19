/**
 * Tests for TLList
 * @author Grant Adamson, Traction on Demand
 * @date 2017-05-01
 * @group TLList
 */
@IsTest
private class TLListTest {
    private static List<Account> testAccounts;

    static {
        testAccounts = new List<Account>{
                new Account(Name = 'Account1', OwnerId = fflib_IDGenerator.generate(User.SObjectType)),
                new Account(Name = 'Account2', OwnerId = fflib_IDGenerator.generate(User.SObjectType)),
                new Account() // null Id values should be omitted
        };
    }

    @IsTest
    private static void collectIdsSObjectField() {
        Test.startTest();

        final Set<Id> results = TLList.collectIds(testAccounts, Account.OwnerId);

        Test.stopTest();


        System.assertEquals(2, results.size(), 'Two Ids should be returned');
        System.assert(results.contains(testAccounts[0].OwnerId),
                'The owner Id from the first account record should be in the set');
        System.assert(results.contains(testAccounts[1].OwnerId),
                'The owner Id from the second account record should be in the set');
    }

    @IsTest
    private static void collectIdsString() {
        Test.startTest();

        final Set<Id> results = TLList.collectIds(testAccounts, 'OwnerId');

        Test.stopTest();


        System.assertEquals(2, results.size(), 'Two Ids should be returned');
        System.assert(results.contains(testAccounts[0].OwnerId),
                'The owner Id from the first account record should be in the set');
        System.assert(results.contains(testAccounts[1].OwnerId),
                'The owner Id from the second account record should be in the set');
    }

    @IsTest
    private static void collectStringsSObjectField() {
        Test.startTest();

        final Set<String> results = TLList.collectStrings(testAccounts, Account.Name);

        Test.stopTest();


        System.assertEquals(2, results.size(), 'Two Strings should be returned');
        System.assert(results.contains(testAccounts[0].Name),
                'The Name from the first account record should be in the set');
        System.assert(results.contains(testAccounts[1].Name),
                'The Name from the second account record should be in the set');
    }

    @IsTest
    private static void collectStringsString() {
        Test.startTest();

        final Set<String> results = TLList.collectStrings(testAccounts, 'Name');

        Test.stopTest();


        System.assertEquals(2, results.size(), 'Two Strings should be returned');
        System.assert(results.contains(testAccounts[0].Name),
                'The Name from the first account record should be in the set');
        System.assert(results.contains(testAccounts[1].Name),
                'The Name from the second account record should be in the set');
    }

    @IsTest
    private static void combineSetList() {
        final Id testId1 = fflib_IDGenerator.generate(Account.SObjectType);
        final Id testId2 = fflib_IDGenerator.generate(Contact.SObjectType);


        Test.startTest();

        final Set<Id> results = TLList.combineSetList(new List<Set<Id>>{ new Set<Id>{ testId1 }, new Set<Id>{ testId2 } });

        Test.stopTest();


        System.assert(results.contains(testId1), 'The first test id should be contained in the result');
        System.assert(results.contains(testId1), 'The second test id should be contained in the result');
    }
}