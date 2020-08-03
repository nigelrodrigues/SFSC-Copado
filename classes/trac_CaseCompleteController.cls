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
}