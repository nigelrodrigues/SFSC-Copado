public with sharing class trac_LoyaltyController {
/*    @AuraEnabled
    public static TLAuraResponse updateLoyalty() {

        return null;
    }*/

    @AuraEnabled
    public static TLAuraResponse pauseLoyalty(String loyaltyId, String email) {
        TLAuraResponse response = new TLAuraResponse(true);
        trac_WS_PauseLoyalty request = new trac_WS_PauseLoyalty();

        if(loyaltyId != null)
            request.loyaltyId = loyaltyId;

        if(email != null)
            request.email = email;

        try {
            if(request.send() && request.pauseResponse.success) {
                response.returnValuesMap.put('response', request.pauseResponse);
            } else if (!request.pauseResponse.success) {
                response = new TLAuraResponse(false);
                response.returnValuesMap.put('response', request.pauseResponse);
            } else if (!request.send()) {
                response = new TLAuraResponse(false, 'Something went wrong, please contact support');
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
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

    public class LoyaltyException extends Exception {}
}