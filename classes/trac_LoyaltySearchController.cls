public with sharing class trac_LoyaltySearchController {

    @AuraEnabled
    public static TLAuraResponse getLoyalty(String email, String loyaltyId, String phoneNum) {
        TLAuraResponse response = new TLAuraResponse(true);
        trac_WS_GetLoyalty request = new trac_WS_GetLoyalty();

        request.loyaltyRequest = new trac_WS_GetLoyalty.LoyaltyRequest(
                email,
                loyaltyId,
                phoneNum,
                '4');
        try {
            if(request.send() && request.loyaltyRequest != null) {
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
                    Request__c = JSON.serializePretty(request.loyaltyRequest),
                    Service__c = 'Loyalty Lookup'
            ));
            insert integrationError;

            String errorMessage = trac_WS_WebServiceHelper.DEFAULT_ERROR + integrationError.Id;

            response = new TLAuraResponse(false, errorMessage);
        }

        response.returnValuesMap.put('statusCode', request.getStatusCode());

        return response;
    }

    @AuraEnabled
    public static TLAuraResponse testAPI() {
        TLAuraResponse response = new TLAuraResponse(true);
        trac_WS_GetLoyaltyById request = new trac_WS_GetLoyaltyById();

        if(request.send()) {
            response.returnValuesMap.put('loyalty', request.loyaltyResponse);
        }

        return response;
    }

    public class LoyaltySearchException extends Exception {}
}