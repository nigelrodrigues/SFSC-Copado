public with sharing class trac_WS_GetLoyaltyById {

    public final String ENDPOINT = (trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c != null) ?
            null : trac_WS_WebServiceHelper.webServiceSettings.Get_Order_List_Endpoint__c;
    private HttpResponse res = new HttpResponse();
    public LoyaltyResponse loyaltyResponse;
    public String jsonError;

    public Boolean send() {
        Boolean success = false;
        String url = 'https://api-gateway.hbc.io/dev/v1/uad/customer/show?uuid=6368bf5842b80d&external_customer_id=1200657659&sig=edc5a2661ba97b5756f6cc6b501ce41c&include=purchase_stats,reward_stats,detail,badges,badge_groups,rewards,reward_groups,offers,coupons,redemption_limits,tier_stats,referrals,member_attributes,identities,points_expiration_schedule,points_summary';

        Map<String, String> params =  new Map<String, String>();
        params.put('x-api-key', 'UyKvFXvTRIaGmZks0a03a2w4LwbJHrED4ahMPF58');
        params.put('x-apigw-api-id', 'pcdkqq8k73');

        res = trac_WS_WebServiceHelper.sendGetRequest(url,null, false, params);
        if (trac_WS_WebServiceHelper.isValidResponse(res)) {
            System.debug('in apex class');
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

    public class res_LoyaltyWrapper {
        @AuraEnabled public String channel;
        @AuraEnabled public String created_at;
        @AuraEnabled public String email;
        @AuraEnabled public String enrolled_at;
        @AuraEnabled public String external_customer_id;
        @AuraEnabled public Integer id;
        @AuraEnabled public String last_activity;
        @AuraEnabled public String last_reward_date;
        @AuraEnabled public Integer last_reward_event_id;
        @AuraEnabled public String status;
        @AuraEnabled public String sub_channel;
        @AuraEnabled public String sub_channel_detail;
        @AuraEnabled public String subscription_type;
        @AuraEnabled public Boolean unsubscribed;
        @AuraEnabled public Boolean unsubscribed_sms;
        @AuraEnabled public String updated_at;
        @AuraEnabled public String name;
        @AuraEnabled public Integer balance;
        @AuraEnabled public Integer lifetime_balance;
        @AuraEnabled public String image_url;
        @AuraEnabled public String top_tier_name;
        @AuraEnabled public String top_tier_expiration_date;
        @AuraEnabled public Integer authorized_points_balance;
        @AuraEnabled public Integer pending_points_balance;
        @AuraEnabled public String balance_in_dollars;
        @AuraEnabled public String locale;
        @AuraEnabled public Integer redeemed_rewards_count;
        @AuraEnabled public Integer redeemed_rewards_points;
        @AuraEnabled public Integer purchase_count;
        @AuraEnabled public String last_purchase_date;
        @AuraEnabled public String lifetime_revenue;
        @AuraEnabled public String birthdate;
        @AuraEnabled public String city;
        @AuraEnabled public String country;
        @AuraEnabled public String first_name;
        @AuraEnabled public String home_phone;
        @AuraEnabled public String home_store;
        @AuraEnabled public String last_name;
        @AuraEnabled public String last_visit_date;
        @AuraEnabled public String middle_name;
        @AuraEnabled public String mobile_phone;
        @AuraEnabled public String postal_code;
        @AuraEnabled public String state;
        @AuraEnabled public String work_phone;
        @AuraEnabled public String address_line_1;
        @AuraEnabled public String address_line_2;
        @AuraEnabled public String top_tier_join_date;
        @AuraEnabled public String top_tier_description;
        @AuraEnabled public Integer actions_needed_for_next_tier;
        @AuraEnabled public Integer actions_needed_to_keep_tier;
        @AuraEnabled public String top_tier_image;
        @AuraEnabled public String next_tier_name;
        @AuraEnabled public String next_tier_description;
        @AuraEnabled public String next_tier_image;
        @AuraEnabled public res_PointsWrapper points_summary;
        @AuraEnabled public List<res_BadgeWrapper> customer_badges;
    }

    public class res_PointsWrapper {
        @AuraEnabled public Long points_earned_total;
        @AuraEnabled public Long points_redeemed_total;
        @AuraEnabled public Long points_returned_total;
        @AuraEnabled public Long points_expired_total;
    }

    public class res_BadgeWrapper {
        @AuraEnabled public Integer id;
        @AuraEnabled public String badge_url;
        @AuraEnabled public String description;
        @AuraEnabled public String display_name;
        @AuraEnabled public String earned_at;
        @AuraEnabled public Boolean featured;
        @AuraEnabled public String name;
        @AuraEnabled public Boolean enabled;
        @AuraEnabled public Boolean active;
    }

    public class LoyaltyResponse {
        @AuraEnabled public res_LoyaltyWrapper data;
        @AuraEnabled public Boolean success;
        @AuraEnabled public String response_code;
    }

}