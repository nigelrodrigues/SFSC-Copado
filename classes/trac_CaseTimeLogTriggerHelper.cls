/**
 * @description Helper for trac_CaseTimeLogTrigger
 * @author      Abhishek Solanki, Traction on Demand
 * @date        2019-09-12
 */
public without sharing class trac_CaseTimeLogTriggerHelper{

    /**
    * @description Map Case's fields to Case Time Log record
    * @param       newList, list of new Case Time Log objects
    */
    public static void updateTeamLeadAndLocation(List<Case_Time_Log__c> newList){
        Set<Id> caseIdSet = new Set<Id>();
        Map<Id,Case> idVsCaseMap= new Map<Id,Case>();
        for(Case_Time_Log__c tl : newList){
            if(tl.Case__c != null)
                caseIdSet.add(tl.Case__c);
        }
        for(Case cse : [SELECT Id,Case_Owner_Supervisor_ID__c,Case_Owner_Location__c FROM Case WHERE Id IN :caseIdSet]){
            idVsCaseMap.put(cse.Id,cse);
        }
        for(Case_Time_Log__c tl : newList){
            if(tl.Case__c != null){
                tl.Agent_Team_Lead__c = idVsCaseMap.get(tl.Case__c).Case_Owner_Supervisor_ID__c;
                tl.Agent_Location__c = idVsCaseMap.get(tl.Case__c).Case_Owner_Location__c;
            }
        }
    }
}