/**
 * Batch class processes Case Time Log records created between two dates stored in
 * Aggregation Batch Settings and create Aggregated Time Log records.
 * @author Shubham Jain, Traction on Demand
 * @date 2019-07-18
 */

global class todft_AggregatedCaseTimeLogBatch implements
                Database.Batchable<sObject>, Database.Stateful {

    global Map<String, Aggregated_Case_Time_Log__c> insertedAggregatedTimeLogs = new Map<String, Aggregated_Case_Time_Log__c>();

    private Aggregation_Batch_Settings__c aggregationBatchSettings = todft_AggregatedCaseTimeLogBatchUtility.aggregationBatchSettings;

    /**
	 * @description Query data from Case Time Log object.
	 * @param bc - BatchableContext
	 */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String whereClause = ' End_Time__c != NULL AND Is_Aggregated__c = false';
        //If check if custom setting record is null
        if (aggregationBatchSettings.Batch_Start_Date__c != null && aggregationBatchSettings.Batch_End_Date__c != null) {
            String startDate = (aggregationBatchSettings.Batch_Start_Date__c).formatGMT(todft_TimeLogAggregationConstants.GMT_FORMAT);
            String endDate = (aggregationBatchSettings.Batch_End_Date__c).formatGMT(todft_TimeLogAggregationConstants.GMT_FORMAT);
            whereClause = whereClause + ' ' + ' AND CreatedDate >= ' + startDate + ' AND CreatedDate < ' + endDate;
        }
        String queryString = 'SELECT Business_Hours_Duration__c, Calendar_Duration__c, Case__c, Case_Status__c, ' +
                'Case_Status_New__c, Case_Status_Group__c, Owner_Type__c, Parent_Owner__c, ' +
                'Parent_Owner_User__c, Parent_Owner_User_New__c, Case_Status_Change__c, ' +
                'Parent_Owner_Change__c, Parent_Owner_New__c, CreatedDate ' +
                'FROM Case_Time_Log__c WHERE' + ' ' + whereClause + ' Order By CreatedDate';
        return Database.getQueryLocator(queryString);
    }

    /**
	 * @description Query data from Case Time Log object
	 * @param bc - BatchableContext
	 * @param scope - Case Time Log records to process
	 */
    global void execute(Database.BatchableContext bc, List<Case_Time_Log__c> scope) {

        Map<String, List<Case_Time_Log__c>> caseTimeLogsByKeyStrings = new Map<String, List<Case_Time_Log__c>>();
        List<Aggregated_Case_Time_Log__c> aggregatedCaseTimeLogs = new List<Aggregated_Case_Time_Log__c>();
        List<Aggregated_Case_Time_Log__c> aggregatedTimeLogsToUpsert = new List<Aggregated_Case_Time_Log__c>();
        Map<String, Integer> statusChangeCountByCase = new Map<String, Integer>();
        Map<String, Integer> ownerChangeCountByCase = new Map<String, Integer>();
        Set<Id> caseIds = new Set<Id>();

        for (Case_Time_Log__c ctLog : scope) {

            //Status - Status New Aggregation
            if (ctLog.Case_Status__c != null
                    && ctLog.Case_Status_New__c != null
                    && ctLog.Case_Status__c != ctLog.Case_Status_New__c) {

                List<Case_Time_Log__c> caseTimeLogs =
                        caseTimeLogsByKeyStrings.get(todft_TimeLogAggregationConstants.STATUS_TYPE_AGGREGATION_IDENTIFIER + ctLog.Case_Status__c + ' - ' + ctLog.Case_Status_New__c);
                if (caseTimeLogs == null)
                    caseTimeLogs = new List<Case_Time_Log__c>();
                caseTimeLogs.add(ctLog);
                caseTimeLogsByKeyStrings.put(todft_TimeLogAggregationConstants.STATUS_TYPE_AGGREGATION_IDENTIFIER + ctLog.Case_Status__c + ' - ' + ctLog.Case_Status_New__c, caseTimeLogs);
            }

            //Owner - Owner New Aggregation
            if ((ctLog.Parent_Owner__c != null
                    && ctLog.Parent_Owner_New__c != null
                    && !ctLog.Parent_Owner__c.equals(ctLog.Parent_Owner_New__c))) {

                List<Case_Time_Log__c> caseTimeLogs = caseTimeLogsByKeyStrings.get(todft_TimeLogAggregationConstants.OWNER_TYPE_AGGREGATION_IDENTIFIER + ctLog.Parent_Owner__c + ' - ' + ctLog.Parent_Owner_New__c);
                if (caseTimeLogs == null)
                    caseTimeLogs = new List<Case_Time_Log__c>();
                caseTimeLogs.add(ctLog);
                caseTimeLogsByKeyStrings.put(todft_TimeLogAggregationConstants.OWNER_TYPE_AGGREGATION_IDENTIFIER + ctLog.Parent_Owner__c + ' - ' + ctLog.Parent_Owner_New__c, caseTimeLogs);
            }

            //Owner - Status Aggregation
            if (ctLog.Parent_Owner__c != null
                    && ctLog.Case_Status_New__c != null
                    && ctLog.Case_Status__c != ctLog.Case_Status_New__c) {

                List<Case_Time_Log__c> caseTimeLogs = caseTimeLogsByKeyStrings.get(todft_TimeLogAggregationConstants.OWNER_STATUS_TYPE_AGGREGATION_IDENTIFIER + ctLog.Parent_Owner__c + ' - ' + ctLog.Case_Status__c);
                if (caseTimeLogs == null)
                    caseTimeLogs = new List<Case_Time_Log__c>();
                caseTimeLogs.add(ctLog);
                caseTimeLogsByKeyStrings.put(todft_TimeLogAggregationConstants.OWNER_STATUS_TYPE_AGGREGATION_IDENTIFIER + ctLog.Parent_Owner__c + ' - ' + ctLog.Case_Status__c, caseTimeLogs);
            }

            //Populate caseIds Set
            if (ctLog.Case__c != null) {
                caseIds.add(ctLog.Case__c);
            }
            //Check if it is a Status Change log and create map to count total status changes for each case
            if (ctLog.Case_Status_Change__c == 1) {
                Integer count = statusChangeCountByCase.get(ctLog.Case__c);
                if (count == null)
                    count = 0;
                count++;
                statusChangeCountByCase.put(ctLog.Case__c, count);
            }
            //Check if it is a Owner Change log and create map to count total owner changes for each case
            if (ctLog.Parent_Owner_Change__c == 1) {
                Integer count = ownerChangeCountByCase.get(ctLog.Case__c);
                if (count == null)
                    count = 0;
                count++;
                ownerChangeCountByCase.put(ctLog.Case__c, count);
            }

        }

        List<Integer> statusCountList = statusChangeCountByCase.values();
        statusCountList.sort();
        List<Integer> ownerCountList = ownerChangeCountByCase.values();
        ownerCountList.sort();

        //Call Utility method to create one touches type aggregation record.
        if (!scope.isEmpty()) {
            if (!caseTimeLogsByKeyStrings.isEmpty()) {
                aggregatedCaseTimeLogs = todft_AggregatedCaseTimeLogBatchUtility.getAggregatedCaseTimeLogs(caseTimeLogsByKeyStrings);
            }
            Aggregated_Case_Time_Log__c touchesAggregation =
                    todft_AggregatedCaseTimeLogBatchUtility.getTouchesAggregationRecord(scope.size(), caseIds.size(), statusCountList, ownerCountList);
            aggregatedCaseTimeLogs.add(touchesAggregation);
            aggregatedTimeLogsToUpsert = todft_AggregatedCaseTimeLogBatchUtility.updateExistingRecords(aggregatedCaseTimeLogs, insertedAggregatedTimeLogs);
        }

        if (!aggregatedTimeLogsToUpsert.isEmpty()) {
            try {
                upsert aggregatedTimeLogsToUpsert;
                for (Aggregated_Case_Time_Log__c thisLog : aggregatedTimeLogsToUpsert) {
                    insertedAggregatedTimeLogs.put(thisLog.Aggregation_Name__c, thisLog);
                }
            } catch (DmlException e) {
                System.debug('Unhandled exception occurred ' + e.getMessage());
            }
        }

    }

    /**
	 * @description Sends email to user when batch is processed.
	 * @param bc - BatchableContext
	 */

    global void finish(Database.BatchableContext bc) {

        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,
                TotalJobItems, CreatedBy.Email
        from AsyncApexJob where Id =:BC.getJobId()];

        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Case Time Logs Aggregation Batch ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
                ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}