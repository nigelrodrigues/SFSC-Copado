/**
 * Created by jhoran on 9/10/2019.
 */

@IsTest
private class trac_OrderRefundCreditCleanupBatchTest {

    static final TLTestFactory factory = new TLTestFactory();

    @IsTest
    static void testBatch() {
        Case parentCase = (Case) factory.createSObject(new Case(Status = trac_CaseConstants.STATUS_CLOSED), true);

        Order_Refund_Credit__c orderRefundCredit = (Order_Refund_Credit__c) factory.createSObject(new Order_Refund_Credit__c(
                Case__c = parentCase.Id,
                ORC_Status__c = trac_OrderRefundCreditConstants.STATUS_DRAFT
        ), true);

        Test.startTest();
        Database.executeBatch(new trac_OrderRefundCreditCleanupBatch(), 200);
        Test.stopTest();

        Order_Refund_Credit__c queriedOrderRefundCredit = [SELECT Id, ORC_Status__c FROM Order_Refund_Credit__c WHERE Id = :orderRefundCredit.Id];

        System.assertEquals(trac_OrderRefundCreditConstants.STATUS_CANCELLED, queriedOrderRefundCredit.ORC_Status__c, 'ORC should be closed by batch');
    }

    @IsTest
    static void testScheduler() {
        String CRON_EXP = '0 0 0 19 6 ? 2099';

        Test.startTest();
        trac_OrderRefundCreditCleanupBatch orderRefundCreditCleanupBatch = new trac_OrderRefundCreditCleanupBatch();
        String jobId = System.schedule('TestOrderRefundCreditCleanupBatch', CRON_EXP, orderRefundCreditCleanupBatch);
        Test.stopTest();

        System.assert(jobId != null);
    }
}