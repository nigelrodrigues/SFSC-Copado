/**
 *  @description Web Service Class for getting the balance of a Gift Card
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        2/24/2020
 */
public without sharing class trac_WS_GiftCardBalance {

    public final String ENDPOINT = (trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c != null) ?
            trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.IPA_Gift_Card_Balance_Endpoint__c : trac_WS_WebServiceHelper.webServiceSettings.IPA_Gift_Card_Balance_Endpoint__c;
    private HttpResponse res = new HttpResponse();
    public GiftCardBalanceRequest giftCardBalanceRequest;
    public GiftCardBalanceResponse giftCardBalanceResponse;
    public String jsonError;

    public trac_WS_GiftCardBalance() {
        giftCardBalanceRequest = new GiftCardBalanceRequest();
    }

    public Boolean send() {
        res = trac_WS_WebServiceHelper.sendPostRequest(ENDPOINT, giftCardBalanceRequest);
        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            giftCardBalanceResponse = parse(res.getBody());
            return true;
        }
        else {
            try {
                giftCardBalanceResponse = parse(res.getBody());
            } catch (Exception e) {}
            jsonError = trac_WS_WebServiceHelper.getError(res);
            System.debug('Error: ' + trac_WS_WebServiceHelper.getError(res));
        }
        return false;
    }
    public static GiftCardBalanceResponse parse(String json) {
        return (GiftCardBalanceResponse) System.JSON.deserialize(json, GiftCardBalanceResponse.class);
    }

    public class GiftCardBalanceRequest {
        public String banner_code;
        public String language_code;
        public String order_number;
        public String country_code;
        public String store_number;
        public String channel;
        public String sub_channel;
        public req_cardWrapper card;

        public GiftCardBalanceRequest() {
            card = new req_cardWrapper();
        }
    }

    public class req_cardWrapper {
        public String number_x;
        public String pin;
        public String type;
        public String entry_mode;
        public String currency_code;
    }

    public class GiftCardBalanceResponse {
        public String banner_code;
        public res_cardWrapper card;
        public String response_code;
        public String response_message;
    }

    public class res_cardWrapper {
        public String number_x;
        public String funds_available;
        public String currency_code;
    }
}