/**
 *  @description Batch to handle uncompleted ORCs on closed cases
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        9/10/2019
 */
global class trac_OrderRefundCreditCleanupBatch implements Database.Batchable<SObject>, Schedulable {

    global Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return Database.getQueryLocator([SELECT Id, ORC_Status__c, Case__c FROM Order_Refund_Credit__c WHERE Case__r.IsClosed = true AND ORC_Status__c = :trac_OrderRefundCreditConstants.STATUS_DRAFT]);
    }

    global void execute(Database.BatchableContext batchableContext, List<Order_Refund_Credit__c> scope) {
        for (Order_Refund_Credit__c orderRefundCredit : scope) {
            orderRefundCredit.ORC_Status__c = trac_OrderRefundCreditConstants.STATUS_CANCELLED;
        }

        update scope;
    }

    global void finish(Database.BatchableContext batchableContext) {}

    //Schedule batch job
    global void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(new trac_OrderRefundCreditCleanupBatch(), 200);
    }

}