public with sharing class trac_WS_LoyaltyPointValue {
    public final String ENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_Base_Endpoint__c
            + trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_API_Version__c
            + trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_Point_Value_Endpoint__c;
    
    private final String SECRET_KEY = trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_Secret_Key__c;
    private final String UUID = trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_UUID__c;

    private HttpResponse res = new HttpResponse();
    public PointValueResponse pointValueResponse;
    public String jsonError;

    public Boolean send() {
        Boolean success = false;

        Map<String, String> params =  new Map<String, String>();
        Map<String, String> additionalHeaders = new Map<String, String>();

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
            pointValueResponse = parse(res.getBody());
            success = pointValueResponse.success;
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

    public static PointValueResponse parse(String json) {
        return (PointValueResponse) System.JSON.deserialize(json, PointValueResponse.class);
    }

    public class res_DataWrapper {
        @AuraEnabled public Integer code;
        @AuraEnabled public String message;
    }

    public class PointValueResponse {
        @AuraEnabled public res_DataWrapper data;
        @AuraEnabled public Boolean success;
        @AuraEnabled public String conversion_rate;
    }

}