public with sharing class trac_LoyaltyController {

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
            if (response.isSuccess) {
                // no errors so far; callout to endpoint
                trac_WS_RecordLoyaltyEvent evt = new trac_WS_RecordLoyaltyEvent();
                evt.loyaltyId = loyaltyId;
                evt.email = email;
                evt.eventType = eventType;
                evt.value = points;

                if (evt.send()) {
                    // successful callout
                    response.message = 'Successfully updated points to ' + points + ' to Loyalty Number ' + loyaltyId;
                    response.returnValuesMap.put('response', evt.eventResponse);
                } else {
                    // unsuccessful callout
                    response.isSuccess = false;
                    if (evt.eventResponse != null) {
                        response.message  = evt.eventResponse.data.message;
                    } else {
                        response.message = evt.jsonError;
                        System.debug('JSON error response: ' + evt.jsonError);
                    }
                    response.returnValuesMap.put('response', evt.eventResponse);
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return response;
    }

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