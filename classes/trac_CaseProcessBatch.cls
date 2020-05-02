/**
* @Name trac_CaseProcessBatch
* @Author Piyush Bansal, Traction on Demand
* @Date January 1, 2019
*
* @Description Batch class to process Cases for Follow up or reassignment to TL
*/

global class trac_CaseProcessBatch implements Database.Batchable<sObject>, Schedulable {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Datetime last48Hours = Datetime.now().addHours(-48);
        Datetime last10Days = Datetime.now().addHours(-240);
        String query = 'SELECT Id, No_Activity_on_Case__c, LastModifiedDate, Follow_Up_Date__c, Follow_Up_Misses__c, Case_Owner_Supervisor_ID__c, Owner.Type, OwnerId, Status FROM Case';
        query += ' WHERE (Owner.Type = \'User\' AND Status = \'Follow Up\' AND Follow_Up_Date__c = YESTERDAY AND Case_Owner_Supervisor_ID__c != null)';
        query += ' OR (LastModifiedDate < Last_N_Days:5 AND Status NOT IN (\'Follow Up\',\'Awaiting Customer Response\'))';
        query += ' OR (Status = \'Awaiting Internal Response\' AND LastModifiedDate <: last48Hours)';
        query += ' OR (Status = \'Follow Up\' AND LastModifiedDate <=: last10Days)';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        List<Case> reassignFollowUpCases = new List<Case>();
        List<Case> inactiveCases = new List<Case>();
        List<Case> reassignAwaitingInternalCases = new List<Case>();
        List<Case> nonResponsiveCases = new List<Case>();
        Datetime last48Hours = Datetime.now().addHours(-48);
        Datetime last10Days = Datetime.now().addHours(-240);

        for (Case cs : scope) {
            if (cs.Owner.Type == 'User' && cs.Status == trac_CaseConstants.STATUS_FOLLOW_UP && cs.Follow_Up_Date__c == (System.today() - 1) && String.isNotBlank(cs.Case_Owner_Supervisor_ID__c)) {
                reassignFollowUpCases.add(cs);
            } else if (!cs.No_Activity_on_Case__c && cs.LastModifiedDate < (System.today() - 5) && cs.Status != trac_CaseConstants.STATUS_FOLLOW_UP && cs.Status != trac_CaseConstants.STATUS_AWAITING_INTERNAL_REVIEW) {
                inactiveCases.add(cs);
            } else if (cs.Owner.Type == 'User' && cs.Status == trac_CaseConstants.STATUS_AWAITING_INTERNAL_REVIEW && cs.LastModifiedDate < last48Hours) {
                reassignAwaitingInternalCases.add(cs);
            } else if (cs.Status == trac_CaseConstants.STATUS_FOLLOW_UP && cs.LastModifiedDate <= last10Days) {
                nonResponsiveCases.add(cs);
            }
        }
        if (!reassignFollowUpCases.isEmpty()){
            trac_CaseProcessBatchHelper.reAssignUserIdToManagerQueue(reassignFollowUpCases);
        }
        if (!inactiveCases.isEmpty()){
            trac_CaseProcessBatchHelper.flagInactiveCases(inactiveCases);
        }
        if (!reassignAwaitingInternalCases.isEmpty()){
            trac_CaseProcessBatchHelper.reAssignUserIdToManagerQueue(reassignAwaitingInternalCases);
        }
        if (!nonResponsiveCases.isEmpty()) {
            trac_CaseProcessBatchHelper.closeNonResponsiveCases(nonResponsiveCases);
        }
    }

    global void finish(Database.BatchableContext BC) {

    }

    global void execute(SchedulableContext SC) {
        trac_CaseProcessBatch batchObj = new trac_CaseProcessBatch();
        Database.executeBatch(batchObj,1000);
    }
}