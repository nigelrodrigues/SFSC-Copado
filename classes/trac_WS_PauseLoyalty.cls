public with sharing class trac_WS_PauseLoyalty {

    public final String ENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_Base_Endpoint__c
            + trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_API_Version__c
            + trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_Pause_Endpoint__c;
    private final String SECRET_KEY = trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_Secret_Key__c;
    private final String UUID = trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_UUID__c;
    private HttpResponse res = new HttpResponse();
    public PauseResponse pauseResponse;
    public String jsonError;
    public String loyaltyId;
    public String email;

    public Boolean send() {
        Boolean success = false;

        Map<String, String> params =  new Map<String, String>();
        Map<String, String> additionalHeaders = new Map<String, String>();

        if(loyaltyId != null){
            params.put('external_customer_id', loyaltyId);
        }
        if(email != null) {
            params.put('email', email);
        }
        params.put('uuid', UUID);

        String sig = trac_WS_LoyaltyUtils.generateHash(SECRET_KEY, params);

        params.put('sig', sig);
        System.debug('params: ' + params);

        additionalHeaders.put('x-api-key', trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_X_API_Key__c);
        additionalHeaders.put('x-apigw-api-id', trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_X_APIGW_API_ID__c);

        res = trac_WS_WebServiceHelper.sendGetRequest(ENDPOINT, params, false, additionalHeaders);
        System.debug('res: ' + res);
        System.debug('res.getBody(): ' + res.getBody());
        if (trac_WS_WebServiceHelper.isValidResponse(res)) {
            pauseResponse = parse(res.getBody());
            success = true;
        } else {
            jsonError = trac_WS_WebServiceHelper.getError(res);
        }

        return success;
    }

    public Integer getStatusCode() {
        return res.getStatusCode();
    }

    public static PauseResponse parse(String json) {
        return (PauseResponse) System.JSON.deserialize(json, PauseResponse.class);
    }

    public class res_Data {
        @AuraEnabled public Integer code;
        @AuraEnabled public String message;
    }

    public class PauseResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public res_Data data;
    }
}