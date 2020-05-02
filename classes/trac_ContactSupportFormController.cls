/**
* @Name trac_ContactSupportFormController
* @Author Daniel Labonte, Traction on Demand
* @Date June 13, 2019
*
* @Description apex controller for the contact support form lightning component
*/
public with sharing class trac_ContactSupportFormController {

        /**
    * @description retrieve the user id of the guest user
    * @return string of the user id
    */
    @AuraEnabled
    public static String getGuestUserId() {
        return [SELECT Id FROM User WHERE Name = 'Hudson Bay Site Guest User' OR UserType = 'guest' LIMIT 1].Id;
    }

    @AuraEnabled
    public static MetaDataWrapper getCommunityDependentValues() {
        Id networkId = Network.getNetworkId();
        Id RecordTypeId;
        String BusinessUnit;
        String Language;
        MetaDataWrapper obj = new MetaDataWrapper();
        if (networkId != null) {
            List<Network> networkList = [SELECT Id, Name FROM Network WHERE Id = :networkId];
            if (networkList != null && !networkList.isEmpty()) {
                List<Community_Business_Unit_Setting__mdt> communityMdtList = [SELECT Community_Network_Name__c,Language__c,Record_Type_Developer_Name__c,Business_Unit__c FROM Community_Business_Unit_Setting__mdt WHERE Community_Network_Name__c = :networkList[0].Name];
                for (Community_Business_Unit_Setting__mdt mdtObj : communityMdtList) {
                    obj.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(mdtObj.Record_Type_Developer_Name__c).getRecordTypeId();
                    obj.BusinessUnit = mdtObj.Business_Unit__c;
                    obj.Language = mdtObj.Language__c;
                }
            }

        }
        return obj;
    }

    public class MetaDataWrapper {
        @AuraEnabled
        public Id RecordTypeId;
        @AuraEnabled
        public String BusinessUnit;
        @AuraEnabled
        public String Language;
    }
    @AuraEnabled
    public static Map<String, String> getCaseFieldLabels(List<String> fields) {
        Map<String, String> fieldMap = new Map<String, String>();
        Map<String, SObjectField> sobjectFields = Schema.SObjectType.Case.fields.getMap();
        for (String field : fields) {
            fieldMap.put(field, sobjectFields.get(field).getDescribe().getLabel());
        }
        return fieldMap;
    }


    /**
* @description retreive the case type picklist values from the org (custom metadata type)
*              that required an order number on case create
* @return list of picklist string values
*/
    @AuraEnabled
    public static List<String> getCaseTypeValidations() {
        List<String> caseTypeValues = new List<String>();
        for (Case_Type_Validation__mdt mdt : [SELECT Case_Type__c FROM Case_Type_Validation__mdt]) {
            caseTypeValues.add(mdt.Case_Type__c);
        }
        return caseTypeValues;
    }


    /**
* @description create a new link between the uploaded files and the case created
* @param caseId - newly created case
* @param uploadedFileIds - list of json objects where { name : documentId }
* @return whether the link was successfully created
*/
    @AuraEnabled
    public static String attachFilesToCase(String caseId, List<Map<String, String>> uploadedFileIds) {
        List<ContentDocumentLink> newDocumentLinks = new List<ContentDocumentLink>();
        List<String> ids = new List<String>();

        for (Map<String, String> file : uploadedFileIds) {
            ids.add(file.get('name')); // This is a JSON object where {name : documentId}
        }

        List<ContentDocumentLink> queriedDocumentLinks = [
                SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId,ShareType,SystemModstamp,Visibility
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN :ids
        ];

        for (ContentDocumentLink file : queriedDocumentLinks) {
            ContentDocumentLink newLink = file.clone(false);
            newLink.LinkedEntityId = caseId;
            newLink.ShareType = 'V'; // V C I
            newDocumentLinks.add(newLink);
        }

        String error = 'false';
        try {
            insert newDocumentLinks;
        } catch (Exception e) {
            error = e.getMessage();
        }

        try {
            if (error == 'false') delete queriedDocumentLinks;
        } catch (Exception e) {
        }

        return error;
    }
}