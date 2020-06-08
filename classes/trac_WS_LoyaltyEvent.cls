/**
 * @author Nigel Rodrigues, Traction on Demand
 * @date 4-June-2020
 * @description To get the customer's transaction history
 */

public with sharing class trac_WS_LoyaltyEvent {
    public final String ENDPOINT = ''+trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_Base_Endpoint__c
            + trac_WS_WebServiceHelper.webServiceSettings.Bay_Event_History__c;
    private final String SECRET_KEY = trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_Secret_Key__c;
    private final String UUID = trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_UUID__c;
    private HttpResponse res = new HttpResponse();
    public EventRequest eventRequest;
    public EventResponse eventResponse;
    public String jsonError;
    Map<String, String> params =  new Map<String, String>();
    Map<String, String> additionalHeaders = new Map<String, String>();

    public Boolean send(String email, String externalcustomerId) {
        additionalHeaders.put('x-api-key', trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_X_API_Key__c);
        additionalHeaders.put('x-apigw-api-id', trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_X_APIGW_API_ID__c);

        params.put('uuid', UUID);
        if( !String.isBlank(email)) {
            params.put('email', email);
        }
        if( !String.isBlank(externalCustomerId)) {
            params.put('external_customer_id', externalCustomerId);
        }
        params.put('points_detail', 'true');

        String sig = trac_WS_LoyaltyUtils.generateHash(SECRET_KEY, params);
        params.put('sig', sig);


        res = trac_WS_WebServiceHelper.SendGetRequest(ENDPOINT, params, false, additionalHeaders);
        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            System.debug('Event response: ' + res.getBody());
            eventResponse = parse(res.getBody());
            return true;
        }
        else {
            jsonError = trac_WS_WebServiceHelper.getError(res);
            System.debug('Error: ' + trac_WS_WebServiceHelper.getError(res));
        }
        return false;
    }
    public static EventResponse parse(String json) {
        return (EventResponse) System.JSON.deserialize(json, EventResponse.class);
    }

    public class EventRequest {
    }
    public class res_dataWrapper {
        @AuraEnabled public Boolean showDetails = false;
        @AuraEnabled public Integer id;
        @AuraEnabled public String event_id;
        @AuraEnabled public Integer customer_id;
        @AuraEnabled public String email;
        @AuraEnabled public String event_type;
        @AuraEnabled public Integer status;
        @AuraEnabled public String detail;
        @AuraEnabled public String created_at;
        @AuraEnabled public String updated_at;
        @AuraEnabled public String value;
        @AuraEnabled public Decimal points;
        @AuraEnabled public String external_customer_id;
        @AuraEnabled public String channel;
        @AuraEnabled public Integer tier_id;
        @AuraEnabled public String display_detail;
        @AuraEnabled public res_ruleWrapper rule;
    }
    public class res_ruleWrapper {
        @AuraEnabled public Integer id;
        @AuraEnabled public String rule_type;
        @AuraEnabled public List<res_ledgerWrapper> ledger;
    }
    public class res_ledgerWrapper {
        @AuraEnabled public Integer id;
        @AuraEnabled public String ledger_type;
        @AuraEnabled public String title;
        @AuraEnabled public Decimal points;
        @AuraEnabled public res_dataWrapper data;
    }
    public class res_event_paramsWrapper {
        @AuraEnabled public String event_type;
        @AuraEnabled public Integer reference_id;
        @AuraEnabled public String event_id;
    }
    public class EventResponse {
        @AuraEnabled public List<res_dataWrapper> data;
        @AuraEnabled public Boolean success;
    }
}