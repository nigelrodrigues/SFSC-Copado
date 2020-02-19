/**
 * @description Apex controller for trac_QuickLinks lightning component
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-06-27
 */
public with sharing class trac_QuickLinksController {

    /**
     * @description Method to return the quick links from the metadata
     * @return      List<External_Link_Setting__mdt>, List of quick links records
     */
    @AuraEnabled
    public static List<External_Link_Setting__mdt> getQuickLinks(){
        List<External_Link_Setting__mdt> externalLinkSettings = new List<External_Link_Setting__mdt>();
        externalLinkSettings = [SELECT Id, Label, URL__c FROM External_Link_Setting__mdt ORDER BY Order__c ASC, Label ASC];
        return externalLinkSettings;
    }
}