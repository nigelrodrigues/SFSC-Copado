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
    public static Map<String,String> getCaseFieldLabels(List<String> fields) {
        Map<String,String> fieldMap = new Map<String, String>();
        Map<String,SObjectField> sobjectFields = Schema.SObjectType.Case.fields.getMap();
        for(String field : fields) {
            fieldMap.put(field,sobjectFields.get(field).getDescribe().getLabel());
        }
        return fieldMap;
    }



    /**
     * @description retrieve picklist values for the case type field
     * @return map of the picklist values
     */
    @AuraEnabled
    public static List<Map<String,String>> getCaseTypeValues(String businessUnitValue) {
        List<String> values = TLPicklist.getDependantPicklistValuesByFieldName(
                'Case',
                'Business_Unit__c',
                'Type').get(businessUnitValue);
System.debug(values);
        List<Map<String,String>> picklistValues = new List<Map<String,String>>();
        for(String value : values) {
            picklistValues.add(new Map<String, String>{'label' => value, 'value' => value});
        }
        return picklistValues;
    }


    /**
     * @description retreive the case type picklist values from the org (custom metadata type)
     *              that required an order number on case create
     * @return list of picklist string values
     */
    @AuraEnabled
    public static List<String> getCaseTypeValidations() {
        List<String> caseTypeValues = new List<String>();
        for(Case_Type_Validation__mdt mdt : [SELECT Case_Type__c FROM Case_Type_Validation__mdt]) {
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
    public static String attachFilesToCase(String caseId, List<Map<String,String>> uploadedFileIds) {
        List<ContentDocumentLink> newDocumentLinks = new List<ContentDocumentLink>();
        List<String> ids = new List<String>();

        for(Map<String,String> file : uploadedFileIds) {
            ids.add(file.get('name')); // This is a JSON object where {name : documentId}
        }

        List<ContentDocumentLink> queriedDocumentLinks = [
                SELECT ContentDocumentId,Id,IsDeleted,LinkedEntityId,ShareType,SystemModstamp,Visibility
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN :ids];

        for(ContentDocumentLink file : queriedDocumentLinks) {
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
        } catch (Exception e) {}

        return error;
    }
}