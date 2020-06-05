/**
 * @description Web service class for Merkle Record Event API
 * @author Alex Kong
 * @date 2020-05-26
 */

public with sharing class trac_WS_RecordLoyaltyEvent {
    /*public final String ENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_Base_Endpoint__c
                                    + trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_API_Version__c
                                    + trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_Record_Event_Endpoint__c;*/
    private final String ENDPOINT = 'https://api-stage.500friends.com'
            + trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_Record_Event_Endpoint__c;
    private final String SECRET_KEY = trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_Secret_Key__c;
    private final String UUID = trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_UUID__c;

    private HttpResponse res = new HttpResponse();
    public RecordLoyaltyEventResponse eventResponse;
    public String jsonError;
    public String loyaltyId;
    public String email;
    public String eventId;
    public String eventType;
    public Decimal value;

    public Boolean send() {
        Boolean success = false;

        Map<String, String> params =  new Map<String, String>();
        Map<String, String> additionalHeaders = new Map<String, String>();

        params.put('external_customer_id', loyaltyId);
        params.put('email', email);
        params.put('event_id', String.isNotBlank(eventId) ? eventId : generateUniqueEventId());
        params.put('type', eventType);
        params.put('uuid', UUID);
        params.put('value', String.valueOf(value));

        String sig = trac_WS_LoyaltyUtils.generateHash(SECRET_KEY, params);
        params.put('sig', sig);
        System.debug('params: ' + params);

        additionalHeaders.put('x-api-key', trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_X_API_Key__c);
        additionalHeaders.put('x-apigw-api-id', trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_X_APIGW_API_ID__c);

        res = trac_WS_WebServiceHelper.sendGetRequest(ENDPOINT, params, false, additionalHeaders);
        System.debug('res: ' + res);
        System.debug('res.getBody(): ' + res.getBody());
        if (trac_WS_WebServiceHelper.isValidResponse(res)) {
            eventResponse = parse(res.getBody());
            success = eventResponse.success;
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

    public String generateUniqueEventId() {
        User u = [SELECT Id, EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId()];
        String prefix = String.valueOf( String.isNotBlank(u.EmployeeNumber) ? u.EmployeeNumber : u.Id );
        return prefix + Datetime.now().formatGmt('yyyyMMddHHmmss');
    }

    public static RecordLoyaltyEventResponse parse(String json) {
        return (RecordLoyaltyEventResponse) System.JSON.deserialize(json, RecordLoyaltyEventResponse.class);
    }

    public class RecordLoyaltyEventResponse {
        public res_Data data;
        public Boolean success;
    }

    public class res_Data {
        public Integer id;
        public Integer points;
        public Integer code;
        public String message;
    }
}