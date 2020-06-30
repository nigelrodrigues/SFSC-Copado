/**
 * @description Trigger for Case object
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-06-03
 */
trigger trac_CaseTrigger on Case (after insert, after update, before update, before insert) {
    try {
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                trac_CaseTriggerHelper.assignClickToCallCases(Trigger.new,Trigger.oldMap);
                trac_CaseTriggerHelper.keepOwnershipAndUpdateSteward(Trigger.new);
                trac_CaseTriggerHelper.updateCaseOriginIfChat(Trigger.new);
                trac_CaseTriggerHelper.mapCaseTypeFromCommunity(Trigger.new);
                trac_CaseTriggerHelper.updateCaseOwner(Trigger.new, null);
                trac_CaseTriggerHelper.caseStatusAutomation(Trigger.new, new Map<Id, Case>());
                trac_CaseTriggerHelper.transferStewardship(Trigger.new);
                trac_CaseTriggerHelper.ownerChanged(Trigger.new, new Map<Id, Case>());
                trac_CaseTriggerHelper.updateBusinessUnit(Trigger.new, null);
                trac_CaseTriggerHelper.removeBlockedContactFromCase(Trigger.new);
                trac_CaseTriggerHelper.changeOwnerToStoreOperationsQueue(Trigger.new, new Map<Id,Case>());
                trac_CaseTriggerHelper.changeOwnerForSpecificCommunityTopics(Trigger.new, new Map<Id,Case>());

            } else if (Trigger.isUpdate) {
                trac_CaseTriggerHelper.assignClickToCallCases(Trigger.new,Trigger.oldMap);
                trac_CaseTriggerHelper.updateCaseOwner(Trigger.new, Trigger.oldMap);
                trac_CaseTriggerHelper.caseStatusAutomation(Trigger.new, Trigger.oldMap);
                trac_CaseTriggerHelper.transferStewardship(Trigger.new);
                trac_CaseTriggerHelper.ownerChanged(Trigger.new, Trigger.oldMap);
                trac_CaseTriggerHelper.updateBusinessUnit(Trigger.new, Trigger.oldMap);
                trac_CaseTriggerHelper.caseGiftCardQueueHandler(Trigger.new, Trigger.oldMap);
                trac_CaseTriggerHelper.changeOwnerToStoreOperationsQueue(Trigger.new,Trigger.oldMap);
                trac_CaseTriggerHelper.changeOwnerForSpecificCommunityTopics(Trigger.new, Trigger.oldMap);
            }
        } else if (Trigger.isAfter) {
            if (Trigger.isInsert) {
                trac_CaseTriggerHelper.searchAndAssociateContact(Trigger.new,null);
                trac_CaseTriggerHelper.setFeedOnCase(Trigger.new);
                trac_CaseTriggerHelper.checkContact(Trigger.new);
                trac_CaseTriggerHelper.updateLastCaseOnContact(Trigger.new, null);
                trac_CaseTriggerHelper.updateParentCase(Trigger.new, null);
                trac_CaseTriggerHelper.setOrderRefundCreditApproval(Trigger.new, new Map<Id, Case>());
                trac_CaseTriggerHelper.setOrderInformation(Trigger.new, new Map<Id, Case>());
                trac_CaseTriggerHelper.setTranscriptContact(Trigger.new, new Map<Id, Case>());
            } else if (Trigger.isUpdate) {
                trac_CaseTriggerHelper.searchAndAssociateContact(Trigger.new,Trigger.oldMap);
                trac_CaseTriggerHelper.updateLastCaseOnContact(Trigger.new, Trigger.oldMap);
                trac_CaseTriggerHelper.updateParentCase(Trigger.new, Trigger.oldMap);
                trac_CaseTriggerHelper.channelRouting(Trigger.new, Trigger.oldMap);
                trac_CaseTriggerHelper.setOrderRefundCreditApproval(Trigger.new, Trigger.oldMap);
                trac_CaseTriggerHelper.setOrderInformation(Trigger.new, Trigger.oldMap);
                trac_CaseTriggerHelper.setTranscriptContact(Trigger.new, Trigger.oldMap);
            }
        }

        todft_TriggerHandlerBase.triggerHandler(new todft_CaseDomain());
    } catch (Exception e) {
        System.debug(e.getMessage() + '\n' + e.getStackTraceString());
    }
}