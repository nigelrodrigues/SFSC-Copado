/**
 *  @description Reference Data class to get values for other systems. Uses
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        6/17/2019
 */
public with sharing class trac_ReferenceData {

    public static Map<String, Map<String, Reference_Data__mdt>> getReferenceDataMappedByValueByType(String systemName, String keyApiName) {
        Map<String, Map<String, Reference_Data__mdt>> referenceDataByValueByType = new Map<String, Map<String, Reference_Data__mdt>>();

        List<Reference_Data__mdt> referenceDataList = getReferenceDataBySystem(systemName);

        for (Reference_Data__mdt referenceData : referenceDataList) {
            if (referenceData.Type__c != null && referenceData.System_Value__c != null) {
                if (!referenceDataByValueByType.containsKey(referenceData.Type__c)) {
                    referenceDataByValueByType.put(referenceData.Type__c, new Map<String, Reference_Data__mdt>());
                }
                referenceDataByValueByType.get(referenceData.Type__c).put((String)referenceData.get(keyApiName), referenceData);
            }
        }

        return referenceDataByValueByType;
    }

    public static List<Reference_Data__mdt> getReferenceDataBySystem(String systemName) {
        List<Reference_Data__mdt> referenceData = [
                SELECT Id, Language__c, Type__c, System_Value__c, Salesforce_Value__c, System__c
                FROM Reference_Data__mdt
                WHERE System__c = :systemName
        ];
        return referenceData;
    }
}