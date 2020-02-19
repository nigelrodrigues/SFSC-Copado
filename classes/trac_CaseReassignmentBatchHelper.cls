/**
 * @description Helper class for trac_CaseReassignmentBatch class
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-06-10
 */
public with sharing class trac_CaseReassignmentBatchHelper {

    /**
     * @description Assign cases back to the “Action Required” queue
     * @param       cases, Case records for which the Owner is to be reassigned
     * @return      void
     */
    public static void reassignCases(List<Case> cases) {
        Map<Id, Case> caseMap = new Map<Id, Case>();

        Group holdQueue = [SELECT Id FROM Group WHERE DeveloperName = 'Hold' AND Type = 'Queue' LIMIT 1];

        for (Case caseObj : cases) {
            if (!caseObj.IsClosed && !caseObj.Executive_Escalation__c && holdQueue != null && caseObj.OwnerId != holdQueue.Id && caseObj.Status != trac_CaseConstants.STATUS_FOLLOW_UP) {
                caseMap.put(caseObj.Id, caseObj);
            }
        }

        if (caseMap.isEmpty()) return;

        Map<String, List<Case>> mapQueueToCase = new Map<String, List<Case>>();
        for (Case aCase : caseMap.values()) {
            if(!mapQueueToCase.containsKey(aCase.Previous_Queue_Owner_ID__c)){
                mapQueueToCase.put(aCase.Previous_Queue_Owner_ID__c, new List<Case>());
            }
            mapQueueToCase.get(aCase.Previous_Queue_Owner_ID__c).add(aCase);
        }

        List<Case> casesToUpdate = new List<Case>();
        for (QueueSobject queueSobject : [SELECT Id, Queue.Id, Queue.Name FROM QueueSobject WHERE Queue.Id IN: mapQueueToCase.keySet()]) {
            for(Case caseObj : mapQueueToCase.get(queueSobject.Queue.Id)){
                caseObj.OwnerId = queueSobject.Queue.Id;
                casesToUpdate.add(caseObj);
            }
        }

        update casesToUpdate;
    }

}