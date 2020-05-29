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
        } else if(callouttype == 'pause') {
            body = '{"success":true}';
        } else if(callouttype == 'pause.fail') {
            body = '{"success":false,"data":{"code":201,"message":"Authentication failed, invalid or missing signature."}}';
        }
        res.setBody(body);
        return res;
    }
}