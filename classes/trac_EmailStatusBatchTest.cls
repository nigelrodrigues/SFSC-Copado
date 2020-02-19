/**
 *  @description Tests for trac_EmailStatusBatch
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        9/12/2019
 */
@IsTest
private class trac_EmailStatusBatchTest {

    static final TLTestFactory factory = new TLTestFactory();

    @IsTest
    static void testBatch() {
        Case testCase = (Case) factory.createSObject(new Case(Status = trac_CaseConstants.STATUS_AWAITING_CUSTOMER), true);

        testCase.Last_Status_Change__c = Datetime.now().addDays(-6);
        update testCase;


        Test.startTest();
        Database.executeBatch(new trac_EmailStatusBatch(), 50);
        Test.stopTest();

        Case queriedCase = [SELECT Id, Auto_Email_Status__c FROM Case WHERE Id = :testCase.Id];

        System.assertEquals(trac_CaseConstants.EMAIL_STATUS_CUSTOMER_5, queriedCase.Auto_Email_Status__c, 'Case Email Status should be set based on last status update');
    }

    @IsTest
    static void testScheduler() {
        String CRON_EXP = '0 0 0 19 6 ? 2099';

        Test.startTest();
        trac_EmailStatusBatch emailStatusBatch = new trac_EmailStatusBatch();
        String jobId = System.schedule('TestEmailStatusBatch', CRON_EXP, emailStatusBatch);
        Test.stopTest();

        System.assert(jobId != null);
    }
}