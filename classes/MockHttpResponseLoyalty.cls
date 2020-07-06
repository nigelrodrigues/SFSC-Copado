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



        System.debug('CALLOUT TYPE: ' + callouttype);

        if(callouttype == 'customer/show'){
            body = '{' +
                    '    "data": {' +
                    '        "channel": null,' +
                    '        "created_at": "2020-06-02T11:27:26-07:00",' +
                    '        "email": "enroll2@test.com",' +
                    '        "enrolled_at": "2020-06-02T11:27:26-07:00",' +
                    '        "external_customer_id": "600294999999002",' +
                    '        "id": 73402484,' +
                    '        "last_activity": "2020-06-02T11:43:36-07:00",' +
                    '        "last_reward_date": null,' +
                    '        "last_reward_event_id": null,' +
                    '        "status": "paused",' +
                    '        "sub_channel": null,' +
                    '        "sub_channel_detail": null,' +
                    '        "subscription_type": null,' +
                    '        "unsubscribed": false,' +
                    '        "unsubscribed_sms": true,' +
                    '        "updated_at": "2020-06-02T11:47:35-07:00",' +
                    '        "name": "enroll test",' +
                    '        "balance": 0,' +
                    '        "lifetime_balance": 0,' +
                    '        "image_url": null,' +
                    '        "top_tier_name": "Hudson’s Bay Rewards VIP",' +
                    '        "top_tier_expiration_date": "2020-12-31T23:59:59-08:00",' +
                    '        "authorized_points_balance": null,' +
                    '        "pending_points_balance": 0,' +
                    '        "balance_in_dollars": "0.00",' +
                    '        "locale": null,' +
                    '        "redeemed_rewards_count": 0,' +
                    '        "redeemed_rewards_points": 0,' +
                    '        "purchase_count": 3,' +
                    '        "last_purchase_date": "2020-06-02T11:41:26-07:00",' +
                    '        "lifetime_revenue": "299999999.97",' +
                    '        "birthdate": null,' +
                    '        "city": null,' +
                    '        "country": null,' +
                    '        "first_name": "enroll",' +
                    '        "home_phone": null,' +
                    '        "home_store": null,' +
                    '        "last_name": "test",' +
                    '        "last_visit_date": null,' +
                    '        "middle_name": null,' +
                    '        "mobile_phone": null,' +
                    '        "postal_code": null,' +
                    '        "state": null,' +
                    '        "work_phone": null,' +
                    '        "address_line_1": null,' +
                    '        "address_line_2": null,' +
                    '        "top_tier_join_date": "2020-06-02T11:41:18-07:00",' +
                    '        "top_tier_description": "Hudson\'s Bay Rewards VIP",' +
            '        "actions_needed_for_next_tier": null,' +
            '        "actions_needed_to_keep_tier": 0,' +
            '        "top_tier_image": "https://s3.amazonaws.com/loyalty-cdn-stage.500friends.com/merchant/09d423e6cfb3bda2323b668a80c9ee73.jpg",' +
            '        "next_tier_name": null,' +
            '        "next_tier_description": null,' +
            '        "next_tier_image": null,' +
            '        "member_attributes": {' +
            '            "actions_needed_to_keep_tier": 0,' +
            '            "card_open_date": null,' +
            '            "card_close_date": null,' +
            '            "employee_flag": null,' +
            '            "gender": null,' +
            '            "card_spend": null,' +
            '            "visit_count": 2,' +
            '            "petro_bonus_flag": null,' +
            '            "actions_needed_for_next_tier": null,' +
            '            "partner_balance_transfer_optin": null,' +
            '            "card_billing_cycle": null,' +
            '            "charity_flag": null,' +
            '            "partner_balance_transfer_optin_date": null,' +
            '            "ytd_spend": "299999999.97",' +
            '            "ly_tier": null,' +
            '            "charity_gl_code": null' +
            '        },' +
            '        "identities": [],' +
            '        "points_expiration_schedule": [],' +
            '        "points_summary": {' +
            '            "points_earned_total": 0,' +
            '            "points_redeemed_total": 0,' +
            '            "points_returned_total": 0,' +
            '            "points_expired_total": 0,' +
            '            "years": [' +
            '                {' +
            '                    "year": 2020,' +
            '                    "points_earned_year": 0,' +
            '                    "points_redeemed_year": 0,' +
            '                    "points_returned_year": 0,' +
            '                    "points_expired_year": 0,' +
            '                    "months": [' +
            '                        {' +
            '                            "month": 6,' +
            '                            "points_earned": 0,' +
            '                            "points_redeemed": 0,' +
            '                            "points_returned": 0,' +
            '                            "points_expired": 0' +
            '                        }' +
            '                    ]' +
            '                }' +
            '            ]' +
            '        },' +
            '        "customer_badges": [' +
            '            {' +
            '                "id": 38726,' +
            '                "badge_url": "https://s3.amazonaws.com/loyalty-cdn-stage.500friends.com/merchant/5b417c4612ec36f28566eb48ffdca73f.PNG",' +
            '                "description": "Signup Gift Registry",' +
            '                "display_name": "Signup Gift Registry",' +
            '                "earned_at": null,' +
            '                "featured": false,' +
            '                "name": "Signup Gift Registry",' +
            '                "enabled": true,' +
            '                "active": true,' +
            '                "eligibility": {' +
            '                    "eligible": true,' +
            '                    "action_text": null,' +
            '                    "action_description": null,' +
            '                    "action_url": null' +
            '                },' +
            '                "media": [' +
            '                    {' +
            '                        "default": true,' +
            '                        "display_name": "key1",' +
            '                        "key": "key1",' +
            '                        "url": "https://s3.amazonaws.com/loyalty-cdn-stage.500friends.com/merchant/5b417c4612ec36f28566eb48ffdca73f.PNG"' +
            '                    }' +
            '                ],' +
            '                "redeemables": {' +
            '                    "rewards": [],' +
            '                    "deals": []' +
            '                },' +
            '                "points": 250,' +
            '                "instructions": ""' +
            '            }' +
            '        ],' +
            '        "customer_offers": [],' +
            '        "customer_rewards": [],' +
            '        "customer_coupons": [],' +
            '        "customer_reward_groups": [],' +
            '        "customer_badge_groups": [],' +
            '        "customer_referrals": {' +
            '            "referral_codes": [' +
            '                {' +
            '                    "referral_code": "nx7nfg9f",' +
            '                    "channel": "global",' +
            '                    "handle": null,' +
            '                    "status": "active",' +
            '                    "created_at": "2020-06-02T11:43:11-07:00",' +
            '                    "last_shared": null,' +
            '                    "referrals": []' +
            '                }' +
            '            ]' +
            '        }' +
            '    },' +
            '    "success": true' +
            '}';



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


        } else if(callouttype == 'update_customer_info') {
            body = '{"success":true}';
        } else if(callouttype == 'update_customer_info.fail') {
            body = '{"success":false,"data":{"code":201,"message":"Authentication failed, invalid or missing signature."}}';

        } else if(callouttype == 'pointValue') {
            body = '{"success":true,"conversion_rate":"0.005"}';
        } else if(callouttype == 'pointValue.fail') {
            body = '{"success":false,"data":{"code":101,"message":"Invalid or missing UUID."}}';
        } else if(callouttype == 'lsUpdate') {
            body = '{"success":true}';
        } else if(callouttype == 'lsUpdate.fail') {
            body = '{"success":false,"response_code":"89","error_message":"Loyalty Not Found"}';

        }

        res.setBody(body);
        return res;
    }
}