public with sharing class trac_CaseLoyaltyController {
    @AuraEnabled(Cacheable=true)
    public static TLAuraResponse getConversionRate() {
        TLAuraResponse response = new TLAuraResponse(true);
        trac_WS_LoyaltyPointValue request = new trac_WS_LoyaltyPointValue();

        try {
            if(request.send()) {
                response.returnValuesMap.put('body', request.pointValueResponse);
            } else {
                response = new TLAuraResponse(false, 'communication error with merkle');
                response.returnValuesMap.put('body', request.getBody());
            }
            response.returnValuesMap.put('statusCode', request.getStatusCode());
        } catch (Exception e) {
            System.debug(e.getMessage());
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = request.ENDPOINT,
                    Service__c = 'Loyalty Lookup'
            ));
            insert integrationError;

            String errorMessage = trac_WS_WebServiceHelper.DEFAULT_ERROR + integrationError.Id;

            throw new CaseLoyaltyException(errorMessage);
        }

        return response;
    }

    @AuraEnabled
    public static void unsetCustomerLoyaltyId(Id caseId) {
        Case cs = new Case(Id = caseId, Customer_Loyalty_Id__c = null);
        update cs;
    }

    public class CaseLoyaltyException extends Exception {}

}