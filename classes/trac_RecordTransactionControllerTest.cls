/**
 * Created by akong on 6/8/2020.
 */

@IsTest
private class trac_RecordTransactionControllerTest {

    @TestSetup
    static void setup() {

    }

    @IsTest
    static void testRecordTransactionSuccess() {
        Case aCase = new Case();
        insert aCase;
        String[] transactionOrigins = new String[] {'website', 'store', 'mhf'};
        trac_RecordTransactionController.RecordTransactionParameters params = new trac_RecordTransactionController.RecordTransactionParameters();
        params.caseRecordId = aCase.Id;
        params.loyaltyNumber = '1000142';
        params.email = 'test101@pfsweb.com';
        params.orderNumber = '000000002';
        params.transactionNumber = '0000111122306082020';
        params.transactionDate = 'Mar. 04, 2020, 06:31 a.m.';
        params.transactionSubtotal = 15.75;
        params.exclusionSubtotal = 9.25;

        Test.setMock(HttpCalloutMock.class, new trac_WS_RecordLoyaltyEventTest.RecordEventMock());
        Test.startTest();
        for (String transactionOrigin : transactionOrigins) {
            params.transactionOrigin = transactionOrigin;
            TLAuraResponse resp = trac_RecordTransactionController.recordTransaction(params);
            System.assertEquals(true, resp.isSuccess, 'origin: '+transactionOrigin);
            System.assertEquals(10, Integer.valueOf(resp.returnValuesMap.get('points')), 'origin: '+transactionOrigin);
        }
        Test.stopTest();


    }

    @IsTest
    static void testRecordTransactionInvalidParams() {

        trac_RecordTransactionController.RecordTransactionParameters params = new trac_RecordTransactionController.RecordTransactionParameters();

        Test.setMock(HttpCalloutMock.class, new trac_WS_RecordLoyaltyEventTest.RecordEventMock());
        Test.startTest();
        TLAuraResponse resp = trac_RecordTransactionController.recordTransaction(params);
        Test.stopTest();

        System.assertEquals(false, resp.isSuccess);
        System.assert(resp.returnValuesMap.size() > 0, 'returnValuesMap should have 1 or more field validation errors, but has 0');
    }

    @IsTest
    static void testRecordTransactionFail() {
        Case aCase = new Case();
        insert aCase;
        String[] transactionOrigins = new String[] {'website', 'store', 'mhf'};
        trac_RecordTransactionController.RecordTransactionParameters params = new trac_RecordTransactionController.RecordTransactionParameters();
        params.caseRecordId = aCase.Id;
        params.loyaltyNumber = '1000142';
        params.email = 'test101@pfsweb.com';
        params.orderNumber = '000000002';
        params.transactionNumber = '0000111122306082020';
        params.transactionDate = 'Mar. 04, 2020, 06:31 a.m.';
        params.transactionSubtotal = 15.75;
        params.exclusionSubtotal = 9.25;

        Test.setMock(HttpCalloutMock.class, new trac_WS_RecordLoyaltyEventTest.RecordEventMock('fail'));
        Test.startTest();
        for (String transactionOrigin : transactionOrigins) {
            params.transactionOrigin = transactionOrigin;
            TLAuraResponse resp = trac_RecordTransactionController.recordTransaction(params);
            System.assertEquals(false, resp.isSuccess, 'origin: '+transactionOrigin);
        }
        Test.stopTest();
    }
}