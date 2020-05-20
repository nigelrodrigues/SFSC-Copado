public with sharing class trac_WS_GetLoyalty {

    public final String ENDPOINT = (trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c != null) ?
            null : trac_WS_WebServiceHelper.webServiceSettings.Get_Order_List_Endpoint__c;
    private HttpResponse res = new HttpResponse();
    public LoyaltyResponse loyaltyResponse;
    public LoyaltyRequest loyaltyRequest;
    public String jsonError;

    public Boolean send() {
        Boolean success = false;

        Map<String, String> params =  new Map<String, String>();
        params.put('x-api-key', 'UyKvFXvTRIaGmZks0a03a2w4LwbJHrED4ahMPF58');
        params.put('x-apigw-api-id', 'pcdkqq8k73');
        res = trac_WS_WebServiceHelper.sendPostRequest('https://api-gateway.hbc.io/dev/v1/customerlookup', loyaltyRequest, params);
        if (trac_WS_WebServiceHelper.isValidResponse(res)) {
            System.debug(res.getBody());
            loyaltyResponse = parse(res.getBody());
            success = true;
        } else {
            jsonError = trac_WS_WebServiceHelper.getError(res);
            System.debug('Error: ' + trac_WS_WebServiceHelper.getError(res));
        }

        return success;
    }

    public Boolean isNotFound() {
        return res.getStatusCode() == 404 ? true : false;
    }

    public Integer getStatusCode() {
        return res.getStatusCode();
    }

    private String getEndpoint() {
        String dynamicEndpoint = ENDPOINT;

        return dynamicEndpoint;
    }

    public static LoyaltyResponse parse(String json) {
        return (LoyaltyResponse) System.JSON.deserialize(json, LoyaltyResponse.class);
    }


    public class LoyaltyRequest {

        public LoyaltyRequest(String email,  String loyalty_id, String phone_no, String banner_id) {
            this.email = email;
            this.loyalty_id = loyalty_id;
            this.phone_no = phone_no;
            this.banner_id = banner_id;
        }

        public String email;
        public String loyalty_id;
        public String phone_no;
        public String banner_id;
    }

    public class res_LoyaltyWrapper {
        @AuraEnabled public String email;
        @AuraEnabled public String loyaltyExpDate;
        @AuraEnabled public String loyalty_id;
        @AuraEnabled public String banner_id;
        @AuraEnabled public String first_name;
        @AuraEnabled public String last_name;
        @AuraEnabled public String phone_no;
        @AuraEnabled public String points_expired;
        @AuraEnabled public String last_known_points;
        @AuraEnabled public String points_available_value;
        @AuraEnabled public String tier_name;
        @AuraEnabled public String loyalty_status;
        @AuraEnabled public String points_available;
        @AuraEnabled public String minimum_points;
    }

    public class LoyaltyResponse {
        @AuraEnabled public List<res_LoyaltyWrapper> customerLookupResponse;
        @AuraEnabled public Boolean success;
        @AuraEnabled public String response_code;
    }
}