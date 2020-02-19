/**
 * Utility class for AggregatedCaseTimeLogBatchUtility
 * @author Shubham Jain, Traction on Demand
 * @date 2019-07-18
 */
public with sharing class todft_AggregatedCaseTimeLogBatchUtility {

    public static Aggregation_Batch_Settings__c aggregationBatchSettings = Aggregation_Batch_Settings__c.getOrgDefaults();

    /**
	 * @description Query data from Case Time Log object
	 * @param caseTimeLogsByAggType - Time logs records
	 * @return aggregatedCaseTimeLogs - list of Aggregated_Case_Time_Log__c to upsert
	 */
    public static List<Aggregated_Case_Time_Log__c> getAggregatedCaseTimeLogs(Map<String, List<Case_Time_Log__c>> caseTimeLogsByAggType) {
        List<Aggregated_Case_Time_Log__c> aggregatedCaseTimeLogs = new List<Aggregated_Case_Time_Log__c>();
        Set<Id> caseIds;
        List<Decimal> businessHoursList;
        List<Decimal> calendarHoursList;
        Set<Id> caseTimeLogIds = new Set<Id>();

        for (String keyString : caseTimeLogsByAggType.keySet()) {
            caseIds = new Set<Id>();
            businessHoursList = new List<Decimal>();
            calendarHoursList = new List<Decimal>();
            Decimal totalBusinessHoursDuration = 0;
            Decimal totalCalHoursDuration = 0;

            //Loop over same type time log records to calculate total time duration
            for (Case_Time_Log__c thisTimeLog : caseTimeLogsByAggType.get(keyString)) {
                businessHoursList.add(thisTimeLog.Business_Hours_Duration__c);
                calendarHoursList.add(thisTimeLog.Calendar_Duration__c);
                totalBusinessHoursDuration += thisTimeLog.Business_Hours_Duration__c;
                totalCalHoursDuration += thisTimeLog.Calendar_Duration__c;
                caseTimeLogIds.add(thisTimeLog.Id);
                caseIds.add(thisTimeLog.Case__c);
            }
            businessHoursList.sort();
            calendarHoursList.sort();

            //Create new instance of Aggregated Case Time Log
            Aggregated_Case_Time_Log__c aggCsTimeLog =
                    new Aggregated_Case_Time_Log__c(Aggregation_Name__c = keyString.substringAfter('-'));
            aggCsTimeLog.Business_Hours_Duration_Sum__c = totalBusinessHoursDuration;
            aggCsTimeLog.Business_Hours_Duration_Maximum__c = businessHoursList[businessHoursList.size() - 1];
            aggCsTimeLog.Business_Hours_Duration_Minimum__c = businessHoursList[0];
            aggCsTimeLog.Number_of_Cases__c = caseIds.size();
            aggCsTimeLog.No_of_Time_Logs_Touched__c = businessHoursList.size();
            aggCsTimeLog.Calendar_Hours_Sum__c = totalCalHoursDuration;
            aggCsTimeLog.Calendar_Hours_Maximum__c = calendarHoursList[calendarHoursList.size() - 1];
            aggCsTimeLog.Calendar_Hours_Minimum__c = calendarHoursList[0];
            aggCsTimeLog.Aggregation_Start_Date__c = aggregationBatchSettings.Batch_Start_Date__c != null ? aggregationBatchSettings.Batch_Start_Date__c : null;
            aggCsTimeLog.Aggregation_End_Date__c = aggregationBatchSettings.Batch_End_Date__c != null ? aggregationBatchSettings.Batch_End_Date__c : null;
            if (keyString.substringBefore('-').equals('SS')) {
                //Populate status information
                aggCsTimeLog.Aggregation_Type__c = todft_TimeLogAggregationConstants.STATUS_STATUS_NEW;
                aggCsTimeLog.Status__c = caseTimeLogsByAggType.get(keyString)[0].Case_Status__c;
                aggCsTimeLog.Status_New__c = caseTimeLogsByAggType.get(keyString)[0].Case_Status_New__c;
                aggCsTimeLog.Case_Status_Group__c = caseTimeLogsByAggType.get(keyString)[0].Case_Status_Group__c;

            } else if (keyString.substringBefore('-').equals('OO')) {
                //Populate owner information
                aggCsTimeLog.Owner_Type__c = caseTimeLogsByAggType.get(keyString)[0].Owner_Type__c;
                aggCsTimeLog.Aggregation_Type__c = todft_TimeLogAggregationConstants.OWNER_OWNER_NEW;
                aggCsTimeLog.Parent_Owner_Text__c = caseTimeLogsByAggType.get(keyString)[0].Parent_Owner__c;
                aggCsTimeLog.Parent_Owner_New_Text__c = caseTimeLogsByAggType.get(keyString)[0].Parent_Owner_New__c;
                if (caseTimeLogsByAggType.get(keyString)[0].Parent_Owner_User__c != null) {
                    aggCsTimeLog.Parent_Owner__c = caseTimeLogsByAggType.get(keyString)[0].Parent_Owner_User__c;
                }
                if (caseTimeLogsByAggType.get(keyString)[0].Parent_Owner_User_New__c != null) {
                    aggCsTimeLog.Parent_Owner_New__c = caseTimeLogsByAggType.get(keyString)[0].Parent_Owner_User_New__c;
                }

            } else if (keyString.substringBefore('-').equals('OS')) {
                //Populate status - owner information
                aggCsTimeLog.Owner_Type__c = caseTimeLogsByAggType.get(keyString)[0].Owner_Type__c;
                aggCsTimeLog.Aggregation_Type__c = todft_TimeLogAggregationConstants.OWNER_STATUS;
                aggCsTimeLog.Status__c = caseTimeLogsByAggType.get(keyString)[0].Case_Status__c;
                aggCsTimeLog.Case_Status_Group__c = caseTimeLogsByAggType.get(keyString)[0].Case_Status_Group__c;
                aggCsTimeLog.Parent_Owner_Text__c = caseTimeLogsByAggType.get(keyString)[0].Parent_Owner__c;
                if (caseTimeLogsByAggType.get(keyString)[0].Parent_Owner_User__c != null) {
                    aggCsTimeLog.Parent_Owner__c = caseTimeLogsByAggType.get(keyString)[0].Parent_Owner_User__c;
                }
            }
            aggregatedCaseTimeLogs.add(aggCsTimeLog);
        }
        //Update processed time log records.
        if (!caseTimeLogIds.isEmpty()) {
            updateCaseTimeLogs(caseTimeLogIds);
        }
        return aggregatedCaseTimeLogs;
    }

    /**
	 * @description Updates Is_Aggregated__c true on all processed case time log records.
	 * @param caseTimeLogIds - Case Time log ids.
	 */

    public static void updateCaseTimeLogs(Set<Id> caseTimeLogIds) {
        List<Case_Time_Log__c> caseTimeLogs = new List<Case_Time_Log__c>();
        Case_Time_Log__c thisTimeLog;
        for (Id ctId : caseTimeLogIds) {
            thisTimeLog = new Case_Time_Log__c(Id = ctId);
            thisTimeLog.Is_Aggregated__c = true;
            caseTimeLogs.add(thisTimeLog);
        }
        try{
            update caseTimeLogs;
        }catch (DmlException e){
            System.debug('Unhandled exception occurred '+ e.getMessage());
        }

    }

    /**
	 * @description Updates Is_Aggregated__c true on all processed case time log records.
	 * @param totalTLogs - Count of case time logs
	 * @param totalCases - Count of cases touched
	 * @param statusCountList - List of status count
	 * @param ownerCountList - List of owner count
	 * @return newAggTimeLog - Touches aggregation record
	 */
    public static Aggregated_Case_Time_Log__c getTouchesAggregationRecord(Integer totalTLogs, Integer totalCases, List<Integer> statusCountList, List<Integer> ownerCountList) {
        Aggregated_Case_Time_Log__c newAggTimeLog = new Aggregated_Case_Time_Log__c();
        newAggTimeLog.Aggregation_Name__c = todft_TimeLogAggregationConstants.TOUCHES + System.today();
        newAggTimeLog.Aggregation_Type__c = todft_TimeLogAggregationConstants.TOUCHES;
        newAggTimeLog.No_of_Cases_Touched__c = totalCases;
        newAggTimeLog.No_of_Time_Logs_Touched__c = totalTLogs;
        newAggTimeLog.Aggregation_Start_Date__c = aggregationBatchSettings.Batch_Start_Date__c != null ? aggregationBatchSettings.Batch_Start_Date__c : null;
        newAggTimeLog.Aggregation_End_Date__c = aggregationBatchSettings.Batch_End_Date__c != null ? aggregationBatchSettings.Batch_End_Date__c : null;
        if (statusCountList.size() > 0) {
            newAggTimeLog.Time_Log_Status_Count__c = sumListElements(statusCountList);
            newAggTimeLog.Status_Count_Maximum__c = statusCountList[statusCountList.size() - 1];
            newAggTimeLog.Status_Count_Minimum__c = statusCountList[0];
        }
        if (ownerCountList.size() > 0) {
            newAggTimeLog.Time_Log_Owner_Count__c = sumListElements(ownerCountList);
            newAggTimeLog.Owner_Count_Maximum__c = ownerCountList[ownerCountList.size() - 1];
            newAggTimeLog.Owner_Count_Minimum__c = ownerCountList[0];
        }
        return newAggTimeLog;
    }

    /**
	 * @description Sum all the Integer list elements.
	 * @param lstValues - List of Integer
	 * @return sum - sum of all list elements.
	 */

    public static Integer sumListElements(List<Integer> lstValues) {
        Integer sum = 0;
        for (Integer a : lstValues) {
            sum += a;
        }
        return sum;
    }

    /**
	 * @description Returns a list of Aggregated_Case_Time_Log__c to upsert, while processing batch chunks so
	 * this method checks if record with same Aggregation Name is already inserted via this batch, if yes updates
	 * existing one else create a new record.
	 * @param newRecords - List of Integer
	 * @param insertedAggregatedTimeLogs - Map of already inserted Aggregated Case time log records.
	 * @return aggregatedCaseTimeLogsToUpsert - Returns a list of Aggregated_Case_Time_Log__c to upsert
	 */
    public static List<Aggregated_Case_Time_Log__c> updateExistingRecords(List<Aggregated_Case_Time_Log__c> newRecords, Map<String, Aggregated_Case_Time_Log__c> insertedAggregatedTimeLogs) {
        List<Aggregated_Case_Time_Log__c> aggregatedCaseTimeLogsToUpsert = new List<Aggregated_Case_Time_Log__c>();
        for (Aggregated_Case_Time_Log__c thisLog : newRecords) {
            //Check if already exist.
            if (insertedAggregatedTimeLogs.containsKey(thisLog.Aggregation_Name__c)) {
                //Check if it is Touches record.
                if (thisLog.Aggregation_Name__c.containsIgnoreCase(todft_TimeLogAggregationConstants.TOUCHES)) {
                    Aggregated_Case_Time_Log__c touchLog = insertedAggregatedTimeLogs.get(thisLog.Aggregation_Name__c);
                    touchLog.No_of_Cases_Touched__c += thisLog.No_of_Cases_Touched__c;
                    touchLog.No_of_Time_Logs_Touched__c += thisLog.No_of_Time_Logs_Touched__c;
                    touchLog.Time_Log_Status_Count__c += thisLog.Time_Log_Status_Count__c;
                    //touchLog.Time_Log_Owner_Count__c += thisLog.Time_Log_Owner_Count__c;
                    touchLog.Status_Count_Maximum__c = touchLog.Status_Count_Maximum__c > thisLog.Status_Count_Maximum__c ?
                            touchLog.Status_Count_Maximum__c : thisLog.Status_Count_Maximum__c;
                    touchLog.Status_Count_Minimum__c = touchLog.Status_Count_Minimum__c < thisLog.Status_Count_Minimum__c ?
                            touchLog.Status_Count_Minimum__c : thisLog.Status_Count_Minimum__c;
                    touchLog.Owner_Count_Maximum__c = touchLog.Owner_Count_Maximum__c > thisLog.Owner_Count_Maximum__c ?
                            touchLog.Owner_Count_Maximum__c : thisLog.Owner_Count_Maximum__c;
                    touchLog.Owner_Count_Minimum__c = touchLog.Owner_Count_Minimum__c < thisLog.Owner_Count_Minimum__c ?
                            touchLog.Owner_Count_Minimum__c : thisLog.Owner_Count_Minimum__c;
                    aggregatedCaseTimeLogsToUpsert.add(touchLog);
                } else {
                    Aggregated_Case_Time_Log__c tlog = insertedAggregatedTimeLogs.get(thisLog.Aggregation_Name__c);
                    tlog.Business_Hours_Duration_Sum__c += thisLog.Business_Hours_Duration_Sum__c;
                    tlog.Business_Hours_Duration_Minimum__c = tlog.Business_Hours_Duration_Minimum__c < thisLog.Business_Hours_Duration_Minimum__c ?
                            tlog.Business_Hours_Duration_Minimum__c : thisLog.Business_Hours_Duration_Minimum__c;
                    tlog.Business_Hours_Duration_Maximum__c = tlog.Business_Hours_Duration_Maximum__c > thisLog.Business_Hours_Duration_Maximum__c ?
                            tlog.Business_Hours_Duration_Maximum__c : thisLog.Business_Hours_Duration_Maximum__c;
                    tlog.No_of_Time_Logs_Touched__c += thisLog.No_of_Time_Logs_Touched__c;
                    tlog.Calendar_Hours_Sum__c += thisLog.Calendar_Hours_Sum__c;
                    tlog.Calendar_Hours_Minimum__c = tlog.Calendar_Hours_Minimum__c < thisLog.Calendar_Hours_Minimum__c ?
                            tlog.Calendar_Hours_Minimum__c : thisLog.Calendar_Hours_Minimum__c;
                    tlog.Calendar_Hours_Maximum__c = tlog.Calendar_Hours_Maximum__c > thisLog.Calendar_Hours_Maximum__c ?
                            tlog.Calendar_Hours_Maximum__c : thisLog.Calendar_Hours_Maximum__c;
                    tlog.Number_of_Cases__c += thisLog.Number_of_Cases__c;
                    aggregatedCaseTimeLogsToUpsert.add(tlog);
                }

            } else {
                aggregatedCaseTimeLogsToUpsert.add(thisLog);
            }
        }
        return aggregatedCaseTimeLogsToUpsert;
    }
}