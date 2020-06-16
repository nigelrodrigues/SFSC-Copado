public with sharing class trac_LoyaltySearchController {
    
    @AuraEnabled


    public static TLAuraResponse getLoyalty(String loyaltyId, String email, String recordId) {


        TLAuraResponse response = new TLAuraResponse(true);
        trac_WS_GetLoyalty request = new trac_WS_GetLoyalty();

        request.include = 'purchase_stats,reward_stats,detail,badges,badge_groups,rewards,reward_groups,offers,coupons,redemption_limits,tier_stats,referrals,member_attributes,identities,points_expiration_schedule,points_summary';

        if(loyaltyId != null) {
        	request.loyaltyId = loyaltyId;
        }

        if(email != null) {
        	request.email = email;
        }

        try {
            if(request.send()) {
                response.returnValuesMap.put('body', request.loyaltyResponse);


                updateLoyaltyIdOnCase(recordId, request.loyaltyResponse.data.external_customer_id);


            } else {
                response = new TLAuraResponse(false, 'communication error with merkle');
                response.returnValuesMap.put('body', request.getBody());
            }
            response.returnValuesMap.put('statusCode', request.getStatusCode());
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

        return response;
    }

    @AuraEnabled
    public static TLAuraResponse getLoyaltyUAD(String loyaltyId, String email, String phoneNum) {
        TLAuraResponse response = new TLAuraResponse(true);
        trac_WS_GetLoyaltyUAD request = new trac_WS_GetLoyaltyUAD();
        trac_WS_GetLoyaltyUAD.LoyaltyUADRequest loyaltyUADRequest = new trac_WS_GetLoyaltyUAD.LoyaltyUADRequest();

        loyaltyUADRequest.banner_id = '4';
        loyaltyUADRequest.loyalty_id = loyaltyId;
        request.loyaltyUADRequest = loyaltyUADRequest;

        try {
            if(request.send()) {
                response.returnValuesMap.put('body', request.loyaltyUADResponse);
            } else {
                response = new TLAuraResponse(false, 'communication error with uad');
                response.returnValuesMap.put('body', request.getBody());
            }
            response.returnValuesMap.put('statusCode', request.getStatusCode());
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

        return response;
    }





    private static void updateLoyaltyIdOnCase(String recordId, String loyaltyId)
    {
        if(recordId != null) {
            Case aCase = [SELECT Id, Customer_Loyalty_Id__c FROM Case WHERE Id = :recordId];
            aCase.Customer_Loyalty_Id__c = loyaltyId;
            update aCase;
        }
    }




    public class LoyaltySearchException extends Exception {}
}