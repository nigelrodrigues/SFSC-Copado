/**
 * Service class for Case object
 * @author Shubham Jain, Traction on Demand
 * @date 2019-08-01
 */
public without sharing class todft_CaseService {

    /**
	 * @description Check Case's closed status, also check if case is reopened.
	 * @param newRecords - sObject Records being processed
	 * @param oldRecordMap - old record's map
	 */
    public static void checkCaseStatus(List<sObject> newRecords, Map<Id, sObject> oldRecordMap) {
        List<Case> casesToUpdateTimeLogInfo = new List<Case>();
        List<Case> casesToUpdateReopenedInfo = new List<Case>();
        List<Case> newCases = new List<Case>();
        Map<Id, Case> oldCaseMap = new Map<Id, Case>();
        //Typecast sobject list into Case's list
        for (sObject sobj : newRecords) {
            newCases.add((Case) sobj);
        }

        //Typecast sObject map into Case's map
        for (Id sId : oldRecordMap.keySet()) {
            oldCaseMap.put(sId, (Case) oldRecordMap.get(sId));
        }

        for (Case cs : newCases) {
            //Check if case closed
            if ((cs.IsClosed || cs.IsClosedOnCreate) && !oldCaseMap.get(cs.Id).IsClosed) {
                casesToUpdateTimeLogInfo.add(cs);
            }
            //Check if case reopened.
            if ((!cs.IsClosed) && oldCaseMap.get(cs.Id).IsClosed) {
                casesToUpdateReopenedInfo.add(cs);
            }
        }

        if (!casesToUpdateTimeLogInfo.isEmpty())
            updateTimeLogInformationOnCase(casesToUpdateTimeLogInfo, oldCaseMap);

        if (!casesToUpdateReopenedInfo.isEmpty())
            updateCaseReopenedInfo(casesToUpdateReopenedInfo);
    }

    /**
	 * @description Updates Time Log fields on Case record.
	 * @param casesToProcess - case records being processed
	 * @param oldCaseMap - old case records map
	 */
    public static void updateTimeLogInformationOnCase(List<Case> casesToProcess, Map<Id, Case> oldCaseMap) {
        Set<Id> caseIds = new Map<Id, Case>(casesToProcess).keySet();
        Map<Id, List<Case_Time_Log__c>> caseTimeLogsByCaseIds = new Map<Id, List<Case_Time_Log__c>>();
        List<Case> caseListToUpdate = new List<Case>();
        Case cs;
        //Query time log records
        for (Case_Time_Log__c thisLog : [
                SELECT Id, Business_Hours_Duration__c, Calendar_Duration__c, Case__c
                        , Case_Status_Change__c, Owner_Type__c, Parent_Owner_Change__c
                        , Parent_Owner_New__c, Case_Status_Group__c, Parent_Owner_User_New__c
                        , Parent_Owner__c, Case_Status_New__c
                FROM Case_Time_Log__c
                WHERE Case__c IN :caseIds
        ]) {
            List<Case_Time_Log__c> caseTimeLogs = caseTimeLogsByCaseIds.get(thisLog.Case__c);
            if (caseTimeLogs == null)
                caseTimeLogs = new List<Case_Time_Log__c>();
            caseTimeLogs.add(thisLog);
            caseTimeLogsByCaseIds.put(thisLog.Case__c, caseTimeLogs);
        }

        //Get Case owner's name
        Map<Id, String> ownerNameByCaseIds = getCaseOwnerName(caseTimeLogsByCaseIds.keySet());

        //Loop over caseTimeLogsByCaseIds map
        for (Id caseId : caseTimeLogsByCaseIds.keySet()) {
            cs = createCaseInstance(caseId);
            for (Case_Time_Log__c thisLog : caseTimeLogsByCaseIds.get(caseId)) {
                //Check if it is a Owner Change log
                if (thisLog.Parent_Owner_Change__c == 1 && thisLog.Parent_Owner_New__c != null) {
                    cs.No_Owner_changes__c += 1;
                    if (thisLog.Parent_Owner_User_New__c == null) {
                        cs.No_Queue_changes__c += 1;
                    } else {
                        cs.No_Agent_changes__c += 1;
                    }
                }
                //Check if it is a status change log.
                if (thisLog.Case_Status_Change__c == 1) {
                    cs.No_Status_changes__c += 1;
                }
                //Check if Case Status Group is Company
                if (thisLog.Case_Status_Group__c == todft_TimeLogAggregationConstants.CASE_STATUS_GROUP_COMPANY) {
                    cs.Calendar_Time_with_Company__c
                            = thisLog.Calendar_Duration__c != null ?
                            cs.Calendar_Time_with_Company__c + thisLog.Calendar_Duration__c : cs.Calendar_Time_with_Company__c;

                    cs.Business_Time_with_Company__c
                            = thisLog.Business_Hours_Duration__c != null ?
                            cs.Business_Time_with_Company__c + thisLog.Business_Hours_Duration__c : 0;
                }
                //Check if Case Status Group is Customer
                if (thisLog.Case_Status_Group__c == todft_TimeLogAggregationConstants.CASE_STATUS_GROUP_CUSTOMER) {
                    cs.Business_Time_with_Customers__c
                            = thisLog.Business_Hours_Duration__c != null ?
                            cs.Business_Time_with_Customers__c + thisLog.Business_Hours_Duration__c : cs.Business_Time_with_Customers__c;

                    cs.Calendar_Time_with_Customers__c
                            = thisLog.Calendar_Duration__c != null ?
                            cs.Calendar_Time_with_Customers__c + thisLog.Calendar_Duration__c : cs.Calendar_Time_with_Customers__c;
                }

                //Check if owner type is User
                if (thisLog.Owner_Type__c == todft_TimeLogAggregationConstants.OWNER_TYPE_USER) {
                    cs.Business_Time_with_Agents__c
                            = thisLog.Business_Hours_Duration__c != null ?
                            cs.Business_Time_with_Agents__c + thisLog.Business_Hours_Duration__c : cs.Business_Time_with_Agents__c;
                    cs.Calendar_Time_with_Agents__c
                            = thisLog.Calendar_Duration__c != null ?
                            cs.Calendar_Time_with_Agents__c + thisLog.Calendar_Duration__c : cs.Calendar_Time_with_Agents__c;
                }
                //Check if owner type is Queue
                if (thisLog.Owner_Type__c == todft_TimeLogAggregationConstants.OWNER_TYPE_QUEUE) {
                    cs.Business_Time_with_Queues__c
                            = thisLog.Business_Hours_Duration__c != null ?
                            cs.Business_Time_with_Queues__c + thisLog.Business_Hours_Duration__c : cs.Business_Time_with_Queues__c;

                    cs.Calendar_Time_with_Queues__c
                            = thisLog.Calendar_Duration__c != null ?
                            cs.Calendar_Time_with_Queues__c + thisLog.Calendar_Duration__c : cs.Calendar_Time_with_Queues__c;
                }
                //Calculate total Calendar Time and Business Time for case
                cs.Total_Calender_Time__c
                        = thisLog.Calendar_Duration__c != null ?
                        cs.Total_Calender_Time__c + thisLog.Calendar_Duration__c : cs.Total_Calender_Time__c;

                cs.Total_BusinessTime__c
                        = thisLog.Business_Hours_Duration__c != null ?
                        cs.Total_BusinessTime__c + thisLog.Business_Hours_Duration__c : cs.Total_BusinessTime__c;

            }

            cs.No_Status_changes__c = cs.No_Status_changes__c > 1 ? cs.No_Status_changes__c - 1 : cs.No_Status_changes__c;
            if (oldCaseMap.get(caseId).Reopened_Flag__c == null || oldCaseMap.get(caseId).Reopened_Flag__c == 0) {
                cs.First_Close_Duration_Calendar__c = cs.Total_Calender_Time__c;
                cs.First_Close_Duration_Business__c = cs.Total_BusinessTime__c;
                cs.First_Close_Date_Time__c = System.Now();
                cs.First_Close_Owner__c = ownerNameByCaseIds.get(caseId);
            }
            caseListToUpdate.add(cs);
        }
        if (!caseListToUpdate.isEmpty()) {
            try {
                update caseListToUpdate;
            } catch (DmlException e) {
                System.debug('Unhandled exception occurred ' + e.getMessage());
            }
        }

    }

    /**
	 * @description Returns new case instance and set all time log field value as 0
	 * @param caseId The case record id.
	 * @return cs The Case record instance.
	 */
    public static Case createCaseInstance(Id caseId) {
        Case cs = new Case(Id = caseId);
        cs.No_Owner_changes__c = 0;
        cs.No_Status_changes__c = 0;
        cs.No_Agent_changes__c = 0;
        cs.No_Queue_changes__c = 0;
        cs.Business_Time_with_Agents__c = 0;
        cs.Calendar_Time_with_Agents__c = 0;
        cs.Calendar_Time_with_Company__c = 0;
        cs.Business_Time_with_Company__c = 0;
        cs.Total_Calender_Time__c = 0;
        cs.Total_BusinessTime__c = 0;
        cs.Business_Time_with_Queues__c = 0;
        cs.Calendar_Time_with_Queues__c = 0;
        cs.Business_Time_with_Customers__c = 0;
        cs.Calendar_Time_with_Customers__c = 0;
        return cs;
    }

    /**
	 * @description Updates Case's Reopened Flag and reset all time log fields.
	 * @param casesToProcess - sObject Records being processed
	 */
    public static void updateCaseReopenedInfo(List<Case> casesToProcess) {
        List<Case> casesToUpdate = new List<Case>();
        Case cs;
        for (Case thisCase : casesToProcess) {
            cs = createCaseInstance(thisCase.Id);
            cs.Reopened_Flag__c = thisCase.Reopened_Flag__c == null ? 1 : thisCase.Reopened_Flag__c + 1;
            casesToUpdate.add(cs);
        }
        if (!casesToUpdate.isEmpty()) {
            try {
                update casesToUpdate;
            } catch (Exception e) {
                System.debug('Unhandled exception occurred ' + e.getMessage());
            }
        }
    }

    /**
	 * @description Returns a map of case id and related owner's name
	 * @param casIds - case record ids being processed
	 */
    public static Map<Id, String> getCaseOwnerName(Set<Id> casIds) {
        Map<Id, String> ownerNameByCaseIds = new Map<Id, String>();
        for (Case cs : [SELECT Id, Owner.Name FROM Case WHERE Id IN : casIds]) {
            ownerNameByCaseIds.put(cs.Id, cs.Owner.Name);
        }
        return ownerNameByCaseIds;
    }

}