/**
 *  @description Tests for trac_OrderRefundCreditHelper
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        8/9/2019
 */
@IsTest
private class trac_OrderRefundCreditHelperTest {

    static final TLTestFactory factory = new TLTestFactory();

    @IsTest
    static void test_setCaseStatus() {
        Case parentCase = (Case) factory.createSObject(new Case(Status = trac_CaseConstants.STATUS_NEW), true);

        Order_Refund_Credit__c orderRefundCredit = (Order_Refund_Credit__c) factory.createSObject(new Order_Refund_Credit__c(Case__c = parentCase.Id), true);

        orderRefundCredit.ORC_Status__c = trac_OrderRefundCreditConstants.STATUS_APPROVED;
        update orderRefundCredit;

        Case queriedCase = [SELECT Id, Status FROM Case WHERE Id = :parentCase.Id];

        System.assertNotEquals(trac_CaseConstants.STATUS_NEW, queriedCase.Status, 'Status should\'ve been updated by ORC approval');
    }

    @IsTest
    static void test_postOnParentCase() {
        Case parentCase = (Case) factory.createSObject(new Case(Status = trac_CaseConstants.STATUS_NEW), true);

        Order_Refund_Credit__c orderRefundCredit = (Order_Refund_Credit__c) factory.createSObject(new Order_Refund_Credit__c(Case__c = parentCase.Id, Transaction_Number__c='123456789', Amount_Charged__c=50), true);

        Test.startTest();
        orderRefundCredit.ORC_Status__c = trac_OrderRefundCreditConstants.STATUS_CLOSED;
        update orderRefundCredit;
        Test.stopTest();

        List<Order_Refund_Credit__c> orcList = new List<Order_Refund_Credit__c>([SELECT Id,Name, Transaction_Number__c,Amount_to_Refund__c FROM Order_Refund_Credit__c WHERE Id=: orderRefundCredit.Id]);
        List<FeedItem> feedList = new List<FeedItem>([SELECT Id, ParentId, Body FROM FeedItem WHERE ParentId =:parentCase.Id]);

        System.assertEquals(True, feedList[0].Body.contains(orcList[0].Name+' - '+orcList[0].Transaction_Number__c+' - '+orcList[0].Amount_to_Refund__c), 'Feed successfully posted on Parent Case');
    }
}