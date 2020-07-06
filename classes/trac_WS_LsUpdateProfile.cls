public with sharing class trac_WS_LsUpdateProfile {
    public final String ENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_GW_Endpoint__c
            + trac_WS_WebServiceHelper.webServiceSettings.Bay_LS_Update_Profile_Endpoint__c;

    private HttpResponse res = new HttpResponse();
    public LsUpdateProfileRequest lsUpdateProfileRequest;
    public LsUpdateProfileResponse lsUpdateProfileResponse;
    public String jsonError;

    public Boolean send() {
        Boolean success = false;

        Map<String, String> additionalHeaders = new Map<String, String>();
        additionalHeaders.put('x-api-key', trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_X_API_Key__c);
        additionalHeaders.put('x-apigw-api-id', trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_X_APIGW_API_ID__c);

        res = trac_WS_WebServiceHelper.sendPostRequest(ENDPOINT, lsUpdateProfileRequest, additionalHeaders);

        System.debug('res: ' + res);
        System.debug('res.getBody(): ' + res.getBody());
        if (trac_WS_WebServiceHelper.isValidResponse(res)) {
            lsUpdateProfileResponse = parse(res.getBody());
            success = lsUpdateProfileResponse.success;
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

    public static LsUpdateProfileResponse parse(String json) {
        return (LsUpdateProfileResponse) System.JSON.deserialize(json, LsUpdateProfileResponse.class);
    }

    public class LsUpdateProfileRequest {
        @AuraEnabled public String loyalty_id {get; set;}
        @AuraEnabled public String email {get; set;}
        @AuraEnabled public String new_email {get; set;}
        @AuraEnabled public String first_name {get; set;}
        @AuraEnabled public String last_name {get; set;}
        @AuraEnabled public String phone_no {get; set;}
        @AuraEnabled public String address_line_1 {get; set;}
        @AuraEnabled public String address_line_2 {get; set;}
        @AuraEnabled public String city {get; set;}
        @AuraEnabled public String state_province {get; set;}
        @AuraEnabled public String postal_code {get; set;}
        @AuraEnabled public String birthdate {get; set;}
        @AuraEnabled public String casl_email_notification {get; set;}
        @AuraEnabled public String language_pref {get; set;}
    }

    public class LsUpdateProfileResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String response_code;
        @AuraEnabled public String error_message;
    }
}