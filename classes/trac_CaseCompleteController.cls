/**
* @description Controller for trac_CaseComplete
* @author      Abhishek Solanki, Traction on Demand
* @date        2019-03-17
*/

public without sharing class trac_CaseCompleteController {

    @AuraEnabled
    public static String getCaseRecordType(String caseRecTypeId) {
        if(String.isNotEmpty(caseRecTypeId)) {
            if (caseRecTypeId == TLSObj.getRecordTypeIdForName(Case.SObjectType, trac_CaseConstants.RECORD_TYPE_DEVNAME_SUPPORT_CASE)) {
                return 'bay';
            } else if (caseRecTypeId == TLSObj.getRecordTypeIdForName(Case.SObjectType, trac_CaseConstants.RECORD_TYPE_DEVNAME_OFF_5TH) ||
                    caseRecTypeId == TLSObj.getRecordTypeIdForName(Case.SObjectType, trac_CaseConstants.RECORD_TYPE_DEVNAME_SAKS)) {
                return 'saksoff5th';
            }
        }
        return 'error';
    }

    @AuraEnabled
    public static Case getCaseDetails(String recordId)
    {
        Case aCase = [SELECT Id, RecordTypeId, ContactId, Order_Number__c, ORC_Count__c, ORC_Closed_Count__c,
                        ORC_POS_Gift_Card_Saks_O5__c, Business_Unit__c, ORC_Virtual_Gift_Card_Queue__c,
                        ORC_MNR_El_Salvador_Follow_Up__c, ORC_Saks_O5_MNR_Review__c, ORC_El_Salvador_Review__c,
                        ORC_Jackson_POS__c, Open_ORC__c, ORC_Submitted__c, ORC_Missing_Item_or_No_Order__c,
                        ORC_Requiring_Approval_Count__c, PayPal_ORC__c
                    FROM Case WHERE Id=:recordId];
        return aCase;
    }
}