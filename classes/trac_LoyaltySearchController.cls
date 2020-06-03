public with sharing class trac_LoyaltySearchController {
    
    @AuraEnabled
    public static TLAuraResponse getLoyalty(String loyaltyId, String email) {
        TLAuraResponse response = new TLAuraResponse(true);
        trac_WS_GetLoyalty request = new trac_WS_GetLoyalty();

        request.include = 'purchase_stats,reward_stats,detail,badges,badge_groups,rewards,reward_groups,offers,coupons,redemption_limits,tier_stats,referrals,member_attributes,identities,points_expiration_schedule,points_summary';
        
        if(loyaltyId != null)
        	request.loyaltyId = loyaltyId;
        
        if(email != null)
        	request.email = email;
        
        try {
            if(request.send()) {
                response.returnValuesMap.put('loyalty', request.loyaltyResponse);
            } else if (!request.send() && request.isNotFound()) {
                response = new TLAuraResponse(false, 'loyalty not found');
            } else {
                throw new LoyaltySearchException(request.jsonError);
            }
        } catch (Exception e) {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = request.ENDPOINT,
                    Service__c = 'Loyalty Lookup'
            ));
            insert integrationError;

            String errorMessage = trac_WS_WebServiceHelper.DEFAULT_ERROR + integrationError.Id;

            response = new TLAuraResponse(false, errorMessage);
        }

        response.returnValuesMap.put('statusCode', request.getStatusCode());

        return response;
    }

    public class LoyaltySearchException extends Exception {}
}