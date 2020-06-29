public with sharing class trac_WS_UpdateLoyaltyEvent {
    public final String ENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_Base_Endpoint__c
            + trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_API_Version__c
            + trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_Update_Info_Endpoint__c;
    
    private final String SECRET_KEY = trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_Secret_Key__c;
    private final String UUID = trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_UUID__c;

    private HttpResponse res = new HttpResponse();
    public UpdateLoyaltyEventResponse updateLoyaltyEventResponse;
    public String jsonError;
    public String loyaltyId;
    public String email;
    public String firstName;
    public String lastName;

    public Boolean send() {
        Boolean success = false;

        Map<String, String> params =  new Map<String, String>();
        Map<String, String> additionalHeaders = new Map<String, String>();

        if(loyaltyId != null){
            params.put('external_customer_id', loyaltyId);
        }
        if(email != null) {
            params.put('new_email', email);
        }
        if(firstName != null) {
            params.put('first_name', firstName);
        }
        if(lastName != null) {
            params.put('last_name', lastName);
        }

        params.put('uuid', UUID);

        String sig = trac_WS_LoyaltyUtils.generateHash(SECRET_KEY, params);

        params.put('sig', sig);
        System.debug('params: ' + params);

        additionalHeaders.put('x-api-key', trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_X_API_Key__c);
        additionalHeaders.put('x-apigw-api-id', trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_X_APIGW_API_ID__c);

        Integer timeout = 5000;
        res = trac_WS_WebServiceHelper.sendGetRequest(ENDPOINT, params, false, additionalHeaders, timeout);
        System.debug('res: ' + res);
        System.debug('res.getBody(): ' + res.getBody());
        if (trac_WS_WebServiceHelper.isValidResponse(res)) {
            updateLoyaltyEventResponse = parse(res.getBody());
            success = updateLoyaltyEventResponse.success;
        } else {
            jsonError = trac_WS_WebServiceHelper.getError(res);
            System.debug('Error: ' + trac_WS_WebServiceHelper.getError(res));
        }

        return success;
    }

    public Integer getStatusCode() {
        return res.getStatusCode();
    }

    public String getBody() {
        return res.getBody();
    }

    private String getEndpoint() {
        String dynamicEndpoint = ENDPOINT;

        return dynamicEndpoint;
    }

    public static UpdateLoyaltyEventResponse parse(String json) {
        return (UpdateLoyaltyEventResponse) System.JSON.deserialize(json, UpdateLoyaltyEventResponse.class);
    }

    public class UpdateLoyaltyEventResponse {
        @AuraEnabled public res_Data data;
        @AuraEnabled public Boolean success;
    }

    public class res_Data {
        @AuraEnabled public Integer code;
        @AuraEnabled public String message;
    }
}