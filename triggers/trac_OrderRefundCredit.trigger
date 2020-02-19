/**
 * Created by jhoran on 8/9/2019.
 */

trigger trac_OrderRefundCredit on Order_Refund_Credit__c (before insert, before update, after insert, after update) {
    try {
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                trac_OrderRefundCreditHelper.setApprovedBy(Trigger.new, new Map<Id, Order_Refund_Credit__c>());
            } else if (Trigger.isUpdate) {
                trac_OrderRefundCreditHelper.setApprovedBy(Trigger.new, Trigger.oldMap);
            }
        } else if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                trac_OrderRefundCreditHelper.setCaseStatus(Trigger.new, new Map<Id, Order_Refund_Credit__c>());
            } else if (Trigger.isUpdate) {
                trac_OrderRefundCreditHelper.setCaseStatus(Trigger.new, Trigger.oldMap);
                trac_OrderRefundCreditHelper.postOnParentCase(Trigger.newMap,Trigger.oldMap);
            }
        }
    } catch (Exception e) {
        System.debug(e.getMessage() + '\n' + e.getStackTraceString());
    }
}