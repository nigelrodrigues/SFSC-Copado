/**
 * Created by akong on 5/25/2020.
 */

public with sharing class trac_IssueAppeasementController {

    @AuraEnabled
    public static TLAuraResponse submitAppeasement(String loyaltyNumber, String email, Integer points, Integer pointsAvailable) {
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

//        // query for Contact
//        List<Contact> cnts = [SELECT Id, Email, Loyalty_Number__c FROM Contact WHERE Id =: contactId];
//        Contact cnt;
//        if (!cnts.isEmpty()) {
//            cnt = cnts[0];
//        }
//
//        if (cnt == null) {
//            response.isSuccess = false;
//            response.message = 'Unable to find contact record';
//        } else if (String.isBlank(cnt.Loyalty_Number__c)) {
//            response.isSuccess = false;
//            response.message = 'Contact record missing loyalty number';
//        }

        // callout to Merkle API to award points
        try {
            if (response.isSuccess) {
                // no errors so far; callout to endpoint
                trac_WS_RecordLoyaltyEvent evt = new trac_WS_RecordLoyaltyEvent();
                evt.loyaltyId = loyaltyNumber;
                evt.email = email;
                evt.eventType = 'gift';
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
}