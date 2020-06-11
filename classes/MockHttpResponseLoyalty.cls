@IsTest
global class MockHttpResponseLoyalty implements HttpCalloutMock {

    private String callouttype;

    public MockHttpResponseLoyalty(){
        this.callouttype = 'customer/show';
    }

    public MockHttpResponseLoyalty(String reqType){
        this.callouttype = reqType;
    }

    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        String body = null;

        if(callouttype == 'customer/show'){
            body = '{"customerLookupResponse":[{"email":"MANIRKRISH@OPTONLINE.NET","city":null,"loyaltyExpDate":null,"enrollTS":1581710911079,"enrollLastUpdatedSource":"SFCC","enrolllastUpdateTS":1581710911079,"externalIdDetails":[{"id":null,"lastModDate":1578614400000,"lastModId":"12345","token_value":null,"token_type":"capone1234567"}],"loyalty_id":"123456999999830","account_holder_flag":null,"banner_id":"4","first_name":"VLADANA","last_name":"ZARUBINA","phone_no":"9173451234","secondary_phone_no":null,"address_line_1":null,"address_line_2":null,"state_province":null,"postal_code":"11235","language_pref":null,"consent_date":null,"consent_source":null,"casl_email":true,"casl_phone":false,"casl_address":false,"points_expired":null,"last_known_points":null,"points_available_value":null,"associate_flag":false,"discount_eligible_flag":false,"enroll_type":null,"channel":"SFCC","tier_name":null,"phone_no_type":"H","loyalty_status":null,"points_available":null,"account_holder_indicator":null,"minimum_points":null}],"response_code":"01","success":true}';
        } else if(callouttype == 'update') {
            body = '{"success":true,"data":{"id":295788481,"points":0}}';
        } else if (callouttype == 'update.fail') {
            body = '{"success":false,"data":{"code":601,"message":"Duplicate closed_account event 64532"}}';
        } else if(callouttype == 'pause') {
            body = '{"success":true}';
        } else if(callouttype == 'pause.fail') {
            body = '{"success":false,"data":{"code":201,"message":"Authentication failed, invalid or missing signature."}}';
        } else if(callouttype == 'loyaltyUAD') {
            body = '{"success":true,"response_code":"01","error_message":null,"first_name":"ABHI17","last_name":"AANAM","email":"ABHISHAR9768@HBC.COM","phone_no":"85636499329","loyalty_id":600294999992297,"account_holder_flag":"primary_no_card","channel":null,"address_line_1":"12773 MARYLAND HEIGHTS","address_line_2":null,"postal_code":"L5N1R2","city":null,"state_province":"SAINT LOUIS","language_pref":"1","points_block":"2","points_block_value":"$0.01","minimum_points":"$5.00","petro_flag":false,"linked_partnerships":null,"rbc_airmiles_opt_in_date":null,"data":{"code":null,"message":null,"email":"abhishar9768@hbc.com","name":"abhi17 aanam","channel":"POS","customer_rewards":[],"customer_badges":[{"id":"38726","badge_url":"https://s3.amazonaws.com/loyalty-cdn-stage.500friends.com/merchant/5b417c4612ec36f28566eb48ffdca73f.PNG","description":"Signup Gift Registry","display_name":"Signup Gift Registry","earned_at":null,"featured":"false","name":"Signup Gift Registry","enabled":"true","active":"true","points":"250","instructions":""}],"customer_offers":[],"customer_coupons":[],"purchase_stats":null,"reward_stats":null,"reward_groups":null,"detail":null,"redemption_limits":null,"tier_stats":null,"points_expiration_schedule":[{"expiration_date":"2022-06-06","expiration_points":"11100"}],"referrals":null,"identities":[],"status":"active","top_tier_expiration_date":null,"top_tier_join_date":"2020-04-17T08:44:49-07:00","top_tier_description":"Hudson\'s Bay Rewards","actions_needed_for_next_tier":"400","actions_needed_to_keep_tier":"0","unsubscribed_sms":"true","created_at":1587138288000,"enrolled_at":1587138288000,"last_activity":1591382644000,"updated_at":1591794249000,"lifetime_balance":11100,"subscription_type":null,"top_tier_name":"Hudson\'s Bay Rewards","balance":11100,"external_customer_id":"600294999992297","sub_channel":"Bay","sub_channel_detail":null,"member_attributes":{"attrib1":null,"attribute2":null}}}';
        } else if(callouttype == 'customer/show.exception') {
            body = '{"success":"true","response_code":"01","error_message":null,"first_name":"ABHI17","last_name":"AANAM","email":"ABHISHAR9768@HBC.COM","phone_no":"85636499329","loyalty_id":600294999992297,"account_holder_flag":"primary_no_card","channel":null,"address_line_1":"12773 MARYLAND HEIGHTS","address_line_2":null,"postal_code":"L5N1R2","city":null,"state_province":"SAINT LOUIS","language_pref":"1","points_block":"2","points_block_value":"$0.01","minimum_points":"$5.00","petro_flag":false,"linked_partnerships":null,"rbc_airmiles_opt_in_date":null,"data":{"code":null,"message":null,"email":"abhishar9768@hbc.com","name":"abhi17 aanam","channel":"POS","customer_rewards":[],"customer_badges":[{"id":"38726","badge_url":"https://s3.amazonaws.com/loyalty-cdn-stage.500friends.com/merchant/5b417c4612ec36f28566eb48ffdca73f.PNG","description":"Signup Gift Registry","display_name":"Signup Gift Registry","earned_at":null,"featured":"false","name":"Signup Gift Registry","enabled":"true","active":"true","points":"250","instructions":""}],"customer_offers":[],"customer_coupons":[],"purchase_stats":null,"reward_stats":null,"reward_groups":null,"detail":null,"redemption_limits":null,"tier_stats":null,"points_expiration_schedule":[{"expiration_date":"2022-06-06","expiration_points":"11100"}],"referrals":null,"identities":[],"status":"active","top_tier_expiration_date":null,"top_tier_join_date":"2020-04-17T08:44:49-07:00","top_tier_description":"Hudson\'s Bay Rewards","actions_needed_for_next_tier":"400","actions_needed_to_keep_tier":"0","unsubscribed_sms":"true","created_at":1587138288000,"enrolled_at":1587138288000,"last_activity":1591382644000,"updated_at":1591794249000,"lifetime_balance":11100,"subscription_type":null,"top_tier_name":"Hudson\'s Bay Rewards","balance":11100,"external_customer_id":"600294999992297","sub_channel":"Bay","sub_channel_detail":null,"member_attributes":{"attrib1":null,"attribute2":null}}}';
        }

        res.setBody(body);
        return res;
    }
}