/**
 * @description Apex controller for trac_QuickLinks lightning component
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-06-27
 */
public without sharing class trac_QuickLinksController {

    /**
     * @description Method to return the quick links from the metadata
     * @return      List<External_Link_Setting__mdt>, List of quick links records
     */
    @AuraEnabled
    public static TLAuraResponse getQuickLinks() {

        TLAuraResponse response = new TLAuraResponse(true);
        Map<String, List<External_Link_Setting__mdt>> externalLinkSettings = new Map<String, List<External_Link_Setting__mdt>>();
        User currentUser = [SELECT UserRole.Name FROM User WHERE Id = :UserInfo.getUserId()];

        externalLinkSettings.put('Bay', new List<External_Link_Setting__mdt>());
        externalLinkSettings.put('LT', new List<External_Link_Setting__mdt>());
        externalLinkSettings.put('Saks', new List<External_Link_Setting__mdt>());
        externalLinkSettings.put('Off5th', new List<External_Link_Setting__mdt>());
        externalLinkSettings.put('MHF', new List<External_Link_Setting__mdt>());

        for (External_Link_Setting__mdt externalLink : [
                SELECT Id, Label, URL__c, Bay__c, LT__c, Saks__c, Off_5th__c, MHF__c 
                FROM External_Link_Setting__mdt
                ORDER BY Order__c ASC, Label ASC
        ]) {
            if (externalLink.Bay__c) {
                externalLinkSettings.get('Bay').add(externalLink);
            }
            if (externalLink.LT__c) {
                externalLinkSettings.get('LT').add(externalLink);
            }
            if (externalLink.Saks__c) {
                externalLinkSettings.get('Saks').add(externalLink);
            }
            if (externalLink.Off_5th__c) {
                externalLinkSettings.get('Off5th').add(externalLink);
            }
            if (externalLink.MHF__c) {
                externalLinkSettings.get('MHF').add(externalLink);
            }
        }

        response.returnValuesMap.put('externalLinks', externalLinkSettings);
        String userRole = currentUser.UserRole.Name;
        String defaultTab = 'Bay';
        if (userRole != null && userRole != '') {
            if (userRole.containsIgnoreCase('Bay')) {
                defaultTab = 'Bay';
            } else if (userRole.containsIgnoreCase('Saks')) {
                defaultTab = 'Saks';
            } else if (userRole.containsIgnoreCase('Off 5th')) {
                defaultTab = 'Off5th';
            } else if (userRole.containsIgnoreCase('L+T') || userRole.containsIgnoreCase('LT')) {
                defaultTab = 'LT';
            } else if (userRole.containsIgnoreCase('MHF')) {
                defaultTab = 'MHF';
            }
        }
        response.returnValuesMap.put('externalLinkSettings', externalLinkSettings);
        response.returnValuesMap.put('defaultTab', defaultTab);
        return response;
    }
}