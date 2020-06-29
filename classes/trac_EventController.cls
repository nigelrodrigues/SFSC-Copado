/**
 * @author Nigel Rodrigues, Traction on Demand
 * @date 4-June-2020
 * @description Controller related to customer event history.
 */

public with sharing class trac_EventController {

    @AuraEnabled
    public static TLAuraResponse getTransactionHistory(String email, String customerId)
    {
        TLAuraResponse response = new TLAuraResponse(true);


        trac_WS_LoyaltyEvent request = new trac_WS_LoyaltyEvent();
        if( request.send(email, customerId) ){

            if( request.eventResponse != null)
            {
                for(trac_WS_LoyaltyEvent.res_dataWrapper dataItem : request.eventResponse.data )
                {
                    dataItem.showDetails = false;
                }
            }
            response.returnValuesMap.put('transactions', request.eventResponse);
        }
        else{
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = request.jsonError,
                    Endpoint__c = trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_Base_Endpoint__c
                            + trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_API_Version__c
                            + trac_WS_WebServiceHelper.webServiceSettings.Bay_Event_History__c + '',
                    Request__c = '',
                    Service__c = 'Loyalty Customer Event History'
            ));
            insert integrationError;

            String errorMessage = trac_WS_WebServiceHelper.DEFAULT_ERROR + integrationError.Id;
            response = new TLAuraResponse(false, errorMessage);
        }

        return response;
    }

}