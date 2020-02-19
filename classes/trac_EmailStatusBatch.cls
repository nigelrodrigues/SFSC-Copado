/**
 *  @description Batch to set email statuses based on how long cases have been in certain statuses
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        9/12/2019
 */
global class trac_EmailStatusBatch implements Database.Batchable<SObject>, Schedulable {

    global Database.QueryLocator start(Database.BatchableContext batchableContext) {
        Datetime yesterday = Datetime.now().addDays(-1);
        return Database.getQueryLocator([SELECT Id, Status, Auto_Email_Status__c, Last_Status_Change__c FROM Case WHERE Last_Status_Change__c < :yesterday AND (Status = :trac_CaseConstants.STATUS_AWAITING_CUSTOMER OR Status = :trac_CaseConstants.STATUS_AWAITING_INTERNAL_REVIEW)]);
    }

    global void execute(Database.BatchableContext batchableContext, List<Case> scope) {
        List<Case> casesToUpdate = new List<Case>();

        for (Case caseRecord : scope) {
            String emailStatus = getEmailStatus(caseRecord);

            if (emailStatus != null && caseRecord.Auto_Email_Status__c != emailStatus) {
                caseRecord.Auto_Email_Status__c = emailStatus;
                casesToUpdate.add(caseRecord);
            }
        }

        if (!casesToUpdate.isEmpty()) {
            Database.update(casesToUpdate, false);
        }
    }

    private static String getEmailStatus(Case caseRecord) {
        String emailStatus;
        Decimal timeInStatusInDays = TLDatetime.getTimeBetweenDatetimesInDays(caseRecord.Last_Status_Change__c, Datetime.now());

        if (caseRecord.Status == trac_CaseConstants.STATUS_AWAITING_INTERNAL_REVIEW) {
            if (timeInStatusInDays > 2) {
                emailStatus = trac_CaseConstants.EMAIL_STATUS_INTERNAL_2;
            }
            else if (timeInStatusInDays > 1) {
                emailStatus = trac_CaseConstants.EMAIL_STATUS_INTERNAL_1;
            }
        }
        else if (caseRecord.Status == trac_CaseConstants.STATUS_AWAITING_CUSTOMER) {
            if (timeInStatusInDays > 7) {
                emailStatus = trac_CaseConstants.EMAIL_STATUS_CUSTOMER_7;
            }
            else if (timeInStatusInDays > 5) {
                emailStatus = trac_CaseConstants.EMAIL_STATUS_CUSTOMER_5;
            }
        }

        return emailStatus;
    }

    global void finish(Database.BatchableContext batchableContext) {}

    //Schedule batch job
    global void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(new trac_EmailStatusBatch(), 50);
    }

}