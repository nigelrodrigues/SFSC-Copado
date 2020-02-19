/**
 * Tests for TLTestFactory
 * public as it contains inner config classes used by TLTestFactory while it is under test
 *
 * @author Grant Adamson, Traction on Demand
 * @date 2018-03-08
 * @group TLTestFactory
 */

@IsTest
private class TLTestFactoryTest {
    private static final String ACCOUNT_NAME = 'TESTNAME';
    private static final String ACCOUNT_NAME2 = 'TESTNAME2';
    private static final Map<SObjectType,Type> VALUES_PROVIDERS = new Map<SObjectType,Type>{
            Account.SObjectType => TLTestFactoryTest.AccountTestValuesProvider.class,
            Contact.SObjectType => TLTestFactoryTest.class // used to generate errors by providing invalid class
    };
    private static final Map<SObjectType,Type> VALUES_PROVIDERS2 = new Map<SObjectType,Type>{
            Account.SObjectType => TLTestFactoryTest.AccountTestValuesProvider.class
    };

    @IsTest
    private static void defaultCtorNoConfigClass() {
        TLTestFactory.configurationClassName = 'BAD';

        Test.startTest();

        final TLTestFactory factory = new TLTestFactory();

        Test.stopTest();

        System.assertEquals(0, factory.valuesProviders.size(), 'No defaults should be available');
    }

    @IsTest
    private static void defaultCtorWithConfigClass() {
        // Override the configuration defaults class name to use a test version
        TLTestFactory.configurationClassName = 'TLTestFactoryTest.TLTestFactoryConfig';

        Test.startTest();

        final TLTestFactory factory = new TLTestFactory();

        Test.stopTest();

        System.assertEquals(VALUES_PROVIDERS, factory.valuesProviders,
                'The factory should use the defaults providers from the config class');
    }

    @IsTest
    private static void configCtor() {
        // Override the configuration defaults class name to use a test version
        TLTestFactory.configurationClassName = 'TLTestFactoryTest.TLTestFactoryConfig';

        Test.startTest();

        final TLTestFactory factory = new TLTestFactory(new TLTestFactoryConfig2());

        Test.stopTest();

        System.assertEquals(VALUES_PROVIDERS2, factory.valuesProviders,
                'The factory should use the defaults providers from the config class');
    }

    @IsTest
    private static void createSObjectNullSObject() {
        TLTestFactory.configurationClassName = 'TLTestFactoryTest.TLTestFactoryConfig';
        final TLTestFactory factory = new TLTestFactory();

        Exception result;

        Test.startTest();

        try {
            factory.createSObject(null);
        } catch(Exception e) {
            result = e;
        }

        Test.stopTest();

        System.assertNotEquals(null, result, 'An exception should have been thrown');
        System.assertEquals(TLTestFactory.NULL_SOBJECT_ERROR, result.getMessage(),
                'The correct exception message should have been used');
    }

    @IsTest
    private static void createSObject() {
        final TLTestFactory factory = new TLTestFactory(new TLTestFactoryConfig());

        Test.startTest();

        final Account a = (Account)factory.createSObject(new Account());

        Test.stopTest();

        System.assertEquals(ACCOUNT_NAME, a.Name, 'The account should have the expected field value');
    }

    @IsTest
    private static void createSObjectWithInsert() {
        final TLTestFactory factory = new TLTestFactory(new TLTestFactoryConfig());

        Test.startTest();

        final Account a = (Account)factory.createSObject(new Account(), true);

        Test.stopTest();

        System.assertEquals(ACCOUNT_NAME, a.Name, 'The account should have the expected field value');
        System.assertNotEquals(null, a.Id, 'The account should have been inserted');
    }

    @IsTest
    private static void createSObjectWithDefaultsProvider() {
        final TLTestFactory factory = new TLTestFactory(new TLTestFactoryConfig());

        Test.startTest();

        final Account a = (Account)factory.createSObject(new Account(), new AccountTestValuesProvider2());

        Test.stopTest();

        System.assertEquals(ACCOUNT_NAME2, a.Name, 'The account should have the expected field value');
    }

    @IsTest
    private static void createSObjectWithInsertAndDefaultsProvider() {
        final TLTestFactory factory = new TLTestFactory(new TLTestFactoryConfig());

        Test.startTest();

        final Account a = (Account)factory.createSObject(new Account(), new AccountTestValuesProvider2(), true);

        Test.stopTest();

        System.assertEquals(ACCOUNT_NAME2, a.Name, 'The account should have the expected field value');
        System.assertNotEquals(null, a.Id, 'The account should have been inserted');
    }

    @IsTest
    private static void createSObjectListWithInvalidNumberOfObjects() {
        TLTestFactory.configurationClassName = 'TLTestFactoryTest.TLTestFactoryConfig';
        final TLTestFactory factory = new TLTestFactory();

        Exception result;

        Test.startTest();

        try {
            factory.createSObjects(new Account(), -1);
        } catch(Exception e) {
            result = e;
        }

        Test.stopTest();

        System.assertNotEquals(null, result, 'An exception should have been thrown');
        System.assertEquals(TLTestFactory.INVALID_NUMBER_OF_OBJECTS_ERROR, result.getMessage(),
                'The correct exception message should have been used');
    }

    @IsTest
    private static void createSObjectList() {
        final TLTestFactory factory = new TLTestFactory(new TLTestFactoryConfig());

        Test.startTest();

        final List<Account> accts = (List<Account>)factory.createSObjects(new Account(), 2);

        Test.stopTest();

        System.assertEquals(2, accts.size());
        System.assertEquals(ACCOUNT_NAME + ' 0', accts[0].Name, 'The account should have the expected field value');
        System.assertEquals(ACCOUNT_NAME + ' 1', accts[1].Name, 'The account should have the expected field value');
    }

    @IsTest
    private static void createSObjectListWithInsert() {
        final TLTestFactory factory = new TLTestFactory(new TLTestFactoryConfig());

        Test.startTest();

        final List<Account> accts = (List<Account>)factory.createSObjects(new Account(), 2, true);

        Test.stopTest();

        System.assertEquals(2, accts.size());
        System.assertEquals(ACCOUNT_NAME + ' 0', accts[0].Name, 'The account should have the expected field value');
        System.assertNotEquals(null, accts[0].Id, 'The account should have been inserted');
        System.assertEquals(ACCOUNT_NAME + ' 1', accts[1].Name, 'The account should have the expected field value');
        System.assertNotEquals(null, accts[1].Id, 'The account should have been inserted');
    }

    @IsTest
    private static void createSObjectListWithDefaultsProvider() {
        final TLTestFactory factory = new TLTestFactory(new TLTestFactoryConfig());

        Test.startTest();

        final List<Account> accts =
                (List<Account>)factory.createSObjects(new Account(), 2, new AccountTestValuesProvider2());

        Test.stopTest();

        System.assertEquals(2, accts.size());
        System.assertEquals(ACCOUNT_NAME2 + ' 0', accts[0].Name, 'The account should have the expected field value');
        System.assertEquals(ACCOUNT_NAME2 + ' 1', accts[1].Name, 'The account should have the expected field value');
    }

    @IsTest
    private static void createSObjectListWithInsertAndDefaultsProvider() {
        final TLTestFactory factory = new TLTestFactory(new TLTestFactoryConfig());

        Test.startTest();

        final List<Account> accts =
                (List<Account>)factory.createSObjects(new Account(), 2, new AccountTestValuesProvider2(), true);

        Test.stopTest();

        System.assertEquals(2, accts.size());
        System.assertEquals(ACCOUNT_NAME2 + ' 0', accts[0].Name, 'The account should have the expected field value');
        System.assertNotEquals(null, accts[0].Id, 'The account should have been inserted');
        System.assertEquals(ACCOUNT_NAME2 + ' 1', accts[1].Name, 'The account should have the expected field value');
        System.assertNotEquals(null, accts[1].Id, 'The account should have been inserted');
    }

    /**
     * Config and DefaultsProvider classes used in tests
     */
    public class TLTestFactoryConfig implements TLTestFactory.Configuration {
        public Map<SObjectType, Type> getValuesProviders() {
            return VALUES_PROVIDERS;
        }
    }

    public class TLTestFactoryConfig2 implements TLTestFactory.Configuration {
        public Map<SObjectType, Type> getValuesProviders() {
            return VALUES_PROVIDERS2;
        }
    }

    public class AccountTestValuesProvider implements TLTestFactory.ValuesProvider {
        public Map<Schema.SObjectField, Object> getFieldValues() {
            return new Map<Schema.SObjectField, Object> {
                    Account.Name => ACCOUNT_NAME,
                    Account.BillingState => 'Quebec',
                    Account.BillingCountry => 'Canada'
            };
        }

        public Schema.SObjectField getNameField() {
            return Account.Name;
        }
    }

    public class AccountTestValuesProvider2 implements TLTestFactory.ValuesProvider {
        public Map<Schema.SObjectField, Object> getFieldValues() {
            return new Map<Schema.SObjectField, Object> {
                    Account.Name => ACCOUNT_NAME2
            };
        }

        public Schema.SObjectField getNameField() {
            return Account.Name;
        }
    }
}