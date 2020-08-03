public with sharing class trac_LoyaltyController {

    @AuraEnabled

    public static TLAuraResponse updateCustomerInfo(String loyaltyId, String firstName, String lastName, String email) {
        TLAuraResponse response = new TLAuraResponse(true);
        trac_WS_UpdateLoyaltyEvent request = new trac_WS_UpdateLoyaltyEvent();

        request.loyaltyId = loyaltyId;
        request.firstName = firstName;
        request.lastName = lastName;
        request.email = email;


        try {
            if(request.send()) {
                response.returnValuesMap.put('body', request.updateLoyaltyEventResponse);
            } else {
                response = new TLAuraResponse(false, 'communication error with merkle');
                response.returnValuesMap.put('body', request.getBody());
            }
            response.returnValuesMap.put('statusCode', request.getStatusCode());
        } catch (Exception e) {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = request.ENDPOINT,
                    Service__c = 'Loyalty Update'
            ));
            insert integrationError;

            String errorMessage = trac_WS_WebServiceHelper.DEFAULT_ERROR + integrationError.Id;

            response = new TLAuraResponse(false, errorMessage);

        }

        return response;
    }

    @AuraEnabled

    public static TLAuraResponse lsUpdateProfile(trac_WS_LsUpdateProfile.LsUpdateProfileRequest params) {
        TLAuraResponse response = new TLAuraResponse(true);
        validateParams(params, response);

        trac_WS_LsUpdateProfile request = new trac_WS_LsUpdateProfile();
        if (response.isSuccess) {
            try {
                request.lsUpdateProfileRequest = params;
                if(request.send()) {
                    response.returnValuesMap.put('body', request.lsUpdateProfileResponse);
                } else {
                    response = new TLAuraResponse(false, 'communication error with hbc');
                    response.returnValuesMap.put('body', request.getBody());
                }
                response.returnValuesMap.put('statusCode', request.getStatusCode());
            } catch(Exception e) {
                Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                        Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                        Endpoint__c = request.ENDPOINT,
                        Service__c = 'Loyalty Update'

                ));
                insert integrationError;

                String errorMessage = trac_WS_WebServiceHelper.DEFAULT_ERROR + integrationError.Id;

                response = new TLAuraResponse(false, errorMessage);
            }

        }
        return response;
    }

    private static Boolean validateParams(trac_WS_LsUpdateProfile.LsUpdateProfileRequest params, TLAuraResponse response) {
        if (String.isBlank(params.loyalty_id)) {
            response.isSuccess = false;
            response.returnValuesMap.put('loyalty_id', 'Loyalty Number missing');
        }
        if (String.isBlank(params.email)) {
            response.isSuccess = false;
            response.returnValuesMap.put('email', 'Email address missing');
        }

        response.returnValuesMap.put('validForm', response.isSuccess);

        return response.isSuccess;

    }

    public class LoyaltyException extends Exception {}
}