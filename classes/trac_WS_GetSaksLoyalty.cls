/**
 *  @description SaksFirst Loyalty API
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        2/21/2020
 */
public with sharing class trac_WS_GetSaksLoyalty {

    public String loyaltyId;

    private final String ENDPOINT = (trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c != null) ?
            trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.Loyalty_Saks_Endpoint__c : trac_WS_WebServiceHelper.webServiceSettings.Loyalty_Saks_Endpoint__c;

    private HttpResponse res = new HttpResponse();
    public GetSaksLoyaltyResponse getSaksLoyaltyResponse;
    public String jsonError;
    public String dynamicEndpoint;

    private Map<String, String> getParameters() {
        Map<String, String> extraParameters = new Map<String, String>();

        return extraParameters;
    }
    public Boolean send() {

        dynamicEndpoint = (loyaltyId != null ? ENDPOINT.replace('{id}',loyaltyId) : ENDPOINT);
        System.debug('dynamicEndpoint: ' + dynamicEndpoint);
        res = trac_WS_WebServiceHelper.sendGetRequest(dynamicEndpoint, getParameters());
        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            getSaksLoyaltyResponse = parse(res.getBody());
            System.debug('RES: '+ res.getBody());
            return true;
        }
        else {
            jsonError = trac_WS_WebServiceHelper.getError(res);
            System.debug('Error: ' + trac_WS_WebServiceHelper.getError(res));
        }
        return false;
    }
    public static GetSaksLoyaltyResponse parse(String json) {
        return (GetSaksLoyaltyResponse) System.JSON.deserialize(json, GetSaksLoyaltyResponse.class);
    }

    public class res_requestWrapper {
        public String url;
        public String server_received_time;
        public String api_version;
        public String help;
    }
    public class res_responseWrapper {
        public res_resultsWrapper results;
    }
    public class res_resultsWrapper {
        public Boolean enabled;
        public Boolean enabled_redemption;
        public Boolean enabled_beauty;
        public res_member_infoWrapper member_info;
        //public List<res_gift_card_historyWrapper> gift_card_history;
        public res_user_loyalty_infoWrapper user_loyalty_info;
        public res_beautyWrapper beauty;
    }
    public class res_member_infoWrapper {
        public Boolean linked;
        public String loyalty_id;
        public String available_points;
        public String tier_status;
        public String gift_card_amount;
        public String next_gift_card_amount;
        public Integer points_to_next_reward;
        public Integer redeemable_points;
        public Integer points_multiplier;
        public Integer rewards_increment;
    }
//    public class res_gift_card_historyWrapper {
//    }
    public class res_user_loyalty_infoWrapper {
        public String first_name;
        public String last_name;
        public String line_one;
        public String line_two;
        public String city;
        public String state;
        public String zip;
        public String last_updated_date;
    }
    public class res_beautyWrapper {
        public String status;
        //public List<res_boxesWrapper> boxes;
    }
//    public class res_boxesWrapper {
//    }
//    public class res_errorsWrapper {
//    }
    public class GetSaksLoyaltyResponse {
        public res_requestWrapper request;
        public res_responseWrapper response;
        //public List<res_errorsWrapper> errors;
    }
}