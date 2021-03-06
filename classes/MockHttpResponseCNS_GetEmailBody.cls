/**
 * Created by nrodrigues on 3/23/2020.
 */

@IsTest
global class MockHttpResponseCNS_GetEmailBody implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"raw_payload": "saks/payload/saks-order_received-73108556-3888e116-ece5-4d4f-9375-e2519ee7f67e.json", ' +
                '"sms_sent": false, "has_alternate": false, "message_success": true, "sms_info": "", ' +
                '"jms_id": "ID:414d5120424d532020202020202020205351a05d3bb14c20", "id": 123511573, ' +
                '"createdAt": "2019-11-26T22:38:39", "alternate_sentAt": null, "primary_info": "", ' +
                '"primary_sentAt": "2019-11-26T22:38:39", "email_name": "order_acknowledgement", "sms_skipped": false, ' +
                '"primary_sent": true, "primary_email": "test@test.com", "message_error": false, ' +
                '"alternate_email": "", "alternate_error": false, "phone_number": "", "alternate_sent": false, ' +
                '"render_skipped": false, "message_skipped": false, "primary_error": false, "sms_error": false, ' +
                '"sms_sentAt": null, "banner": "saks", ' +
                '"rendered_messages": "saks/rendered/saks-order_acknowledgement-73108556-a1628244-33be-437e-bd38-ad727cd4a4dd.json", ' +
                '"primary_skipped": false, "render_error": false, "render_info": "", "render_success": true, ' +
                '"has_sms": false, "alternate_skipped": false, "alternate_info": "", "order_number": 73108556}]');
        res.setStatusCode(200);
        return res;
    }
}