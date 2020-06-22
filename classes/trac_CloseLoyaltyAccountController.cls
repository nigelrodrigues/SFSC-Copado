public with sharing class trac_CloseLoyaltyAccountController {
    @AuraEnabled
    public static TLAuraResponse updateLoyaltyPoints(String loyaltyId, String email, Integer points, String eventType) {
        TLAuraResponse response = new TLAuraResponse(true);

        if (String.isBlank(loyaltyId)) {
            response.isSuccess = false;
            response.message = 'Loyalty number missing';
        } else if (String.isBlank(email)) {
            response.isSuccess = false;
            response.message = 'Email missing';
        } else if (eventType == null) {
            response.isSuccess = false;
            response.message = 'Event type is missing';
        }

        try {
            String message = 'Successfully updated points to ' + points + ' to Loyalty Number ' + loyaltyId;
            handleResponse(response, loyaltyId, email, eventType, points, message);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return response;
    }

    private static void handleResponse(TLAuraResponse response, String loyaltyId, String email, String eventType, Integer points, String successMessage) {
        if (response.isSuccess) {
            // no errors so far; callout to endpoint
            trac_WS_RecordLoyaltyEvent evt = new trac_WS_RecordLoyaltyEvent();
            evt.loyaltyId = loyaltyId;
            evt.email = email;
            evt.eventType = eventType;
            evt.value = points;

            if (evt.send()) {
                // successful callout
                response.message = successMessage;
                response.returnValuesMap.put('body', evt.eventResponse);
            } else {
                // unsuccessful callout
                response.isSuccess = false;
                if (evt.eventResponse != null) {
                    response.message = evt.eventResponse.data.message;
                    response.returnValuesMap.put('body', evt.eventResponse);
                } else {
                    response.message = evt.jsonError;
                    System.debug('JSON error response: ' + evt.jsonError);
                    response.returnValuesMap.put('body', evt.getBody());
                }
            }
            response.returnValuesMap.put('statusCode', evt.getStatusCode());

        }
    }

    @AuraEnabled
    public static TLAuraResponse pauseLoyalty(String loyaltyId, String email) {
        TLAuraResponse response = new TLAuraResponse(true);
        trac_WS_PauseLoyalty request = new trac_WS_PauseLoyalty();

        if(loyaltyId != null) {
            request.loyaltyId = loyaltyId;
        }

        if(email != null) {
            request.email = email;
        }

        try {
            Boolean isSuccess = request.send();
            if(isSuccess && request.pauseResponse.success) {
                response.returnValuesMap.put('body', request.pauseResponse);
            } else if (isSuccess && !request.pauseResponse.success) {
                response = new TLAuraResponse(false);
                response.returnValuesMap.put('body', request.pauseResponse);
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

            response = new TLAuraResponse(false, errorMessage);
        }


        return response;
    }

    public class CloseLoyaltyAccountException extends Exception {}
}