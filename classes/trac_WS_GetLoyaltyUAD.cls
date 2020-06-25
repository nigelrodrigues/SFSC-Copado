public with sharing class trac_WS_GetLoyaltyUAD {
    public final String ENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_GW_Endpoint__c
            + trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_UAD_Lookup_Endpoint__c;

    private final String SECRET_KEY = trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_Secret_Key__c;
    private final String UUID = trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_UUID__c;

    private HttpResponse res = new HttpResponse();
    public LoyaltyUADRequest loyaltyUADRequest;
    public LoyaltyUADResponse loyaltyUADResponse;
    public String jsonError;

    public Boolean send() {
        Boolean success = false;

        Map<String, String> additionalHeaders = new Map<String, String>();
        additionalHeaders.put('x-api-key', trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_X_API_Key__c);
        additionalHeaders.put('x-apigw-api-id', trac_WS_WebServiceHelper.webServiceSettings.Bay_Loyalty_X_APIGW_API_ID__c);


        res = trac_WS_WebServiceHelper.sendPostRequest(ENDPOINT, loyaltyUADRequest, additionalHeaders);

        System.debug('res: ' + res);
        System.debug('res.getBody(): ' + res.getBody());
        if (trac_WS_WebServiceHelper.isValidResponse(res)) {
            loyaltyUADResponse = parse(res.getBody());
            success = loyaltyUADResponse.success;
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

    public static LoyaltyUADResponse parse(String json) {
        return (LoyaltyUADResponse) System.JSON.deserialize(json, LoyaltyUADResponse.class);
    }

    public class LoyaltyUADRequest {
        public String loyalty_id;
        public String email;
        public String phone_no;
        public String banner_id;
    }

    public class LoyaltyUADResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String response_code;
        @AuraEnabled public String error_message;
        @AuraEnabled public String first_name;
        @AuraEnabled public String last_name;
        @AuraEnabled public String email;
        @AuraEnabled public String phone_no;
        @AuraEnabled public Long loyalty_id;
        @AuraEnabled public String account_holder_flag;
        @AuraEnabled public String channel;
        @AuraEnabled public String address_line_1  ;
        @AuraEnabled public String address_line_2;
        @AuraEnabled public String postal_code;
        @AuraEnabled public String city;
        @AuraEnabled public String state_province ;
        @AuraEnabled public String language_pref;
        @AuraEnabled public String points_block;
        @AuraEnabled public String points_block_value;
        @AuraEnabled public String minimum_points;
        @AuraEnabled public Boolean petro_flag;
        @AuraEnabled public String linked_partnerships;
        @AuraEnabled public String rbc_airmiles_opt_in_date;
        @AuraEnabled public res_DataWrapper data;
        @AuraEnabled public String offline_flag;
        @AuraEnabled public List<res_CardDetailsWrapper> card_details;
    }

    public class res_DataWrapper {
        @AuraEnabled public String code;
        @AuraEnabled public String message;
        @AuraEnabled public String email;
        @AuraEnabled public String name;
        @AuraEnabled public String channel;
//        @AuraEnabled public List<String> customer_rewards;
        @AuraEnabled public List<res_CustomerBadgeWrapper> customer_badges;
        @AuraEnabled public List<res_CustomerOffersWrapper> customer_offers;
//        @AuraEnabled public List<String> customer_coupons;
        @AuraEnabled public String purchase_stats;
        @AuraEnabled public String reward_stats;
        @AuraEnabled public String reward_groups;
        @AuraEnabled public String detail;
        @AuraEnabled public String redemption_limits;
        @AuraEnabled public String tier_stats;
        @AuraEnabled public List<res_PointsExpirationScheduleWrapper> points_expiration_schedule;
        @AuraEnabled public String referrals;
        @AuraEnabled public List<String> identities;
        @AuraEnabled public String status;
        @AuraEnabled public String top_tier_expiration_date;
        @AuraEnabled public String top_tier_join_date;
        @AuraEnabled public String top_tier_description;
        @AuraEnabled public String actions_needed_for_next_tier;
        @AuraEnabled public String actions_needed_to_keep_tier;
        @AuraEnabled public String unsubscribed_sms;
        @AuraEnabled public String created_at;
        @AuraEnabled public String enrolled_at;
        @AuraEnabled public String last_activity;
        @AuraEnabled public String updated_at;
        @AuraEnabled public Long lifetime_balance;
        @AuraEnabled public String subscription_type;
        @AuraEnabled public String top_tier_name;
        @AuraEnabled public Long balance;
        @AuraEnabled public String external_customer_id;
        @AuraEnabled public String sub_channel;
        @AuraEnabled public String sub_channel_detail;
        @AuraEnabled public res_MemberAttributesWrapper member_attributes;
    }

    public class res_CustomerBadgeWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String badge_url;
        @AuraEnabled public String description;
        @AuraEnabled public String display_name;
        @AuraEnabled public String earned_at;
        @AuraEnabled public String featured;
        @AuraEnabled public String name;
        @AuraEnabled public String enabled;
        @AuraEnabled public String active;
        @AuraEnabled public String points;
        @AuraEnabled public String instructions;
    }

    public class res_PointsExpirationScheduleWrapper {
        @AuraEnabled public String expiration_date;
        @AuraEnabled public String expiration_points;
    }

    public class res_MemberAttributesWrapper {
        @AuraEnabled public String attrib1;
        @AuraEnabled public String attribute2;
    }

    public class res_CustomerOffersWrapper {
        @AuraEnabled public String created_at;
        @AuraEnabled public String description;
        @AuraEnabled public String destination_url;
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String start_date;
        @AuraEnabled public String updated_at;
        @AuraEnabled public String promotion_type;
        @AuraEnabled public String status;
        @AuraEnabled public String image_url;
        @AuraEnabled public String target;
        @AuraEnabled public String terms_and_conditions;
        @AuraEnabled public String display_name;
    }

    public class res_CardDetailsWrapper {
        @AuraEnabled public String card_type;
    }

}