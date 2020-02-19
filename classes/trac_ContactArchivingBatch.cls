/**
 * @description Batch class to delete contacts (and related cases and accounts) where Last_Case__r.CloseDate is more days ago than the Days Inactive To Archive
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-06-11
 */
global class trac_ContactArchivingBatch implements Database.Batchable<sObject>, Schedulable {

    private static final Id CUSTOMER_RECORD_TYPE_ID = trac_CaseConstants.RECORD_TYPE_ID_CUSTOMER_CONTACT;

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Archive_Settings__c archiveSettings = Archive_Settings__c.getValues('Default');
        Integer daysInactive = archiveSettings.Days_Inactive_To_Archive__c.intValue();
        return Database.getQueryLocator('SELECT Id, (SELECT Id FROM Cases), AccountId FROM Contact WHERE Last_Case__r.Days_Closed__c >: daysInactive AND RecordTypeId =: CUSTOMER_RECORD_TYPE_ID');
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        trac_ContactArchivingBatchHelper.deleteContacts(scope);
    }

    global void finish(Database.BatchableContext BC) {}

    //Schedule batch job
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new trac_ContactArchivingBatch(), 200);
    }

}