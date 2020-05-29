public with sharing class trac_WS_PauseLoyalty {

    public final String ENDPOINT = (trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c != null) ?
            null : trac_WS_WebServiceHelper.webServiceSettings.Get_Order_List_Endpoint__c;
    private HttpResponse res = new HttpResponse();
    public PauseResponse pauseResponse;
    public String jsonError;
    public String loyaltyId;
    public String email;

    //TODO put in custom settings
    private final String SECRET_KEY = '93c45a6f0bdce2a9941ab54d7680f7fb';
    private final String UUID = '6368bf5842b80d';

    public Boolean send() {
        Boolean success = false;
        String url = 'https://api-stage.500friends.com/2019-01-01/api/pause.json';

        Map<String, String> params =  new Map<String, String>();
        Map<String, String> additionalHeaders = new Map<String, String>();
        String sig = generateHash(loyaltyId, email);

        if(loyaltyId != null)
            params.put('external_customer_id', loyaltyId);
        if(email != null)
            params.put('email', email);
        params.put('uuid', UUID);
        params.put('sig', sig);

        additionalHeaders.put('x-api-key', 'UyKvFXvTRIaGmZks0a03a2w4LwbJHrED4ahMPF58');
        additionalHeaders.put('x-apigw-api-id', 'pcdkqq8k73');

        res = trac_WS_WebServiceHelper.sendGetRequest(url,params, false, additionalHeaders);
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

    private String generateHash(String loyaltyId, String email) {
        String loyaltyIdString = 'external_customer_id' + loyaltyId;
        String uuid = 'uuid' + UUID;
        String emailString = 'email' + email;
        String sig = SECRET_Key;

        if(email != null && loyaltyId == null)
            sig = sig + emailString + uuid;
        else if(email == null && loyaltyId != null)
            sig =  sig + loyaltyIdString + uuid;
        else if(email != null && loyaltyId != null)
            sig =  sig + emailString + loyaltyIdString + uuid;
        else
                sig = sig + uuid;


        Blob requestBlob = Blob.valueOf(sig);
        Blob hash = Crypto.generateDigest('MD5', requestBlob);

        return EncodingUtil.convertToHex(hash);
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