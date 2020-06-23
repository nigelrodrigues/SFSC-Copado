/**
 * Created by akong on 5/25/2020.
 */

public with sharing class trac_IssueAppeasementController {

    /**
    * @description Callout to Merkle API to record gift event
    * @param loyaltyNumber String, the customer's Loyalty Number
    * @param email String, the customer's email address
    * @param points Integer, the number of points to award
    * @return TLAuraResponse
    */
    @AuraEnabled
    public static TLAuraResponse submitAppeasement(String loyaltyNumber, String email, Integer points) {
        TLAuraResponse response = new TLAuraResponse(true);

        if (String.isBlank(loyaltyNumber)) {
            response.isSuccess = false;
            response.message = 'Loyalty number missing';
        } else if (String.isBlank(email)) {
            response.isSuccess = false;
            response.message = 'Email missing';
        } else if (points == null || points <= 0) {
            response.isSuccess = false;
            response.message = 'Points must be a positive integer';
        }

        // callout to Merkle API to award points
        try {
            if (response.isSuccess) {
                // no errors so far; callout to endpoint
                trac_WS_RecordLoyaltyEvent evt = new trac_WS_RecordLoyaltyEvent();
                evt.loyaltyId = loyaltyNumber;
                evt.email = email;
                evt.eventType = 'hb_lp_cs_appeasement';
                evt.value = points;

                if (evt.send()) {
                    // successful callout
                    response.message = 'Successfully awarded ' + points + ' point' + (points == 1 ? '' : 's') + ' to Loyalty Number ' + loyaltyNumber;

                    // send customer notification email

                } else {
                    // unsuccessful callout
                    response.isSuccess = false;
                    if (evt.eventResponse != null) {
                        response.message  = evt.eventResponse.data.message;
                    } else {
                        response.message = evt.jsonError;
                        System.debug('JSON error response: ' + evt.jsonError);
                    }
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return response;
    }

    /**
    * @description Returns the maximum appeasement allowed for current profile
    * @return Map<String,String>, keys are profileName and maxAppeasement
    */
    @AuraEnabled
    public static Map<String,String> getProfileAppeasementLimit() {
        Map<String,String> retMap = new Map<String,String>{'profileName' => null, 'maxAppeasement' => '0'};

        Profile p = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        retMap.put('profileName', p.Name);

        // query custom metadata type with this profile name
        List<Bay_Loyalty_Profile_Appeasement_Cap__mdt> profileCaps = [SELECT Id, Label, Max_Appeasement__c
                                                                        FROM Bay_Loyalty_Profile_Appeasement_Cap__mdt
                                                                        WHERE Label = :p.Name];
        String maxAppeasement = profileCaps.isEmpty() ? '0' : profileCaps[0].Max_Appeasement__c;
        retMap.put('maxAppeasement', maxAppeasement);
        //retMap.put('maxAppeasement', 'Unlimited'); // for testing

        return retMap;
    }
}