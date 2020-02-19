/**
 * @description Batch class to reassign cases to back to the “Action Required”  queue
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-06-10
 */
global class trac_CaseReassignmentBatch implements Database.Batchable<sObject>, Schedulable {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, OwnerId, Status, Previous_Queue_Owner_ID__c, IsClosed, Executive_Escalation__c FROM Case WHERE ClosedDate = null AND Previous_Queue_Owner_ID__c != null');
    }

    global void execute(Database.BatchableContext BC, List<Case> scope) {
        trac_CaseReassignmentBatchHelper.reassignCases(scope);
    }

    global void finish(Database.BatchableContext BC) {}

    //Schedule batch job
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new trac_CaseReassignmentBatch(), 200);
    }

}