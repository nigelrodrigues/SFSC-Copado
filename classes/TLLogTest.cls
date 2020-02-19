/**
 *  @description Tests for TLLog
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        11/1/2018
 */
@IsTest
private class TLLogTest {
    private static final String TEST_MESSAGE = 'Test message';
    private static final String TAG = 'Test tag';

    @IsTest static void testBehaviourString() {
        Account account = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'test1');

        Test.startTest();
        TLLog.d(TAG, TEST_MESSAGE);
        TLLog.post(TAG, TEST_MESSAGE);
        TLLog.postAndEmail(TAG, TEST_MESSAGE);
        TLLog.postAndEmail(TAG, TEST_MESSAGE, account);
        TLLog.postAndEmail(TAG, TEST_MESSAGE, account, account);
        Test.stopTest();
    }

    @IsTest static void testSafeSerializer() {
        TLLog.loggingEnabled = false;
        TLLog.hideRecordDataForTest = true;
        final String MAP_SET_RESULT = '{ a map/set of something }';

        String txt;

        txt = TLLog.safeSerialize(new Set<String>{'Hi, I am a string'});
        System.assert(txt.contains('Hi, I am a string'));

        // is it null safe
        txt = TLLog.safeSerialize(null);
        System.assertEquals(null, txt);

        List<Account> emptyList = new List<Account>();
        txt = TLLog.safeSerialize(emptyList);
        System.assertEquals('()', txt);

        List<Account> nullList;
        txt = TLLog.safeSerialize(nullList);
        System.assertEquals(null, txt);

        Account account = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'test1');

        Map<Id, Account> accountsByIds = new Map<Id, Account>{account.Id => account};
        txt = TLLog.safeSerialize(accountsByIds);
        System.assertEquals('{001000000000001AAA={Type=Account, Id=001000000000001AAA}}', txt);

        Map<String, Account> accountsByString = new Map<String, Account>{account.Id => account};
        txt = TLLog.safeSerialize(accountsByString);
        System.assertEquals('{001000000000001AAA={Type=Account, Id=001000000000001AAA}}', txt);

        List<Account> accountList = new List<Account>{account};
        txt = TLLog.safeSerialize(accountList);
        System.assertEquals('({Type=Account, Id=001000000000001AAA})', txt);

        Set<Account> accountSet = new Set<Account>{account};
        txt = TLLog.safeSerialize(accountSet);
        System.assertEquals('{ a map/set of something }', txt);

        txt = TLLog.safeSerialize(account);
        System.assertEquals('{Type=Account, Id=001000000000001AAA}', txt);
    }

    @IsTest static void testLogging() {
        Account account = new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'test1');
        Test.startTest();
        TLLog.d(TAG, TEST_MESSAGE, account);
        TLLog.d(TAG, TEST_MESSAGE, account, account);
        TLLog.d(TAG, TEST_MESSAGE, account, account, account);
        TLLog.d(TAG, TEST_MESSAGE, account, account, account, account);
        TLLog.d(TAG, TEST_MESSAGE, account, account, account, account, account);

        TLLog.i(TAG, TEST_MESSAGE, account);
        TLLog.i(TAG, TEST_MESSAGE, account, account);
        TLLog.i(TAG, TEST_MESSAGE, account, account, account);
        TLLog.i(TAG, TEST_MESSAGE, account, account, account, account);
        TLLog.i(TAG, TEST_MESSAGE, account, account, account, account, account);

        TLLog.w(TAG, TEST_MESSAGE);
        TLLog.w(TAG, TEST_MESSAGE, account);
        TLLog.w(TAG, TEST_MESSAGE, account, account);

        TLLog.e(TAG, TEST_MESSAGE);
        TLLog.e(TAG, TEST_MESSAGE, account);
        TLLog.e(TAG, TEST_MESSAGE, account, account);
        try {
            delete new Account();
        }
        catch (Exception e) {
            TLLog.e(TAG, TEST_MESSAGE, e);
            TLLog.e(TAG, TEST_MESSAGE, account, e);
        }


        Test.stopTest();
    }

    private static void assertFullDebugs(String str) {
        System.assert(str.contains('Initial_Fee_Amount__c=10'), str);
        System.assert(str.contains('Effective_Date__c='+Date.today()), str);
        System.assert(!str.contains('token'), str);
    }
}