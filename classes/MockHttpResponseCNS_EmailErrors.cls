/**
 * Created by nrodrigues on 4/27/2020.
 */

@IsTest
global class MockHttpResponseCNS_EmailErrors  implements HttpCalloutMock{
    private String callouttype;

    public MockHttpResponseCNS_EmailErrors(){
        this.callouttype = 'Email';
    }

    public MockHttpResponseCNS_EmailErrors(String reqType){
        this.callouttype = reqType;
    }

    global HTTPResponse respond(HTTPRequest req) {

        String body = null;
        if(this.callouttype.equalsIgnoreCase('/search_log')){
            body = '[{"raw_payload": true, ' +
                    '"sms_sent": false, "has_alternate": false, "message_success": true, "sms_info": "", ' +
                    '"jms_id": "ID:414d5120424d532020202020202020205351a05d3bb14c20", "id": 123511573, ' +
                    '"createdAt": "2019-11-26T22:38:39", "alternate_sentAt": null, "primary_info": "", ' +
                    '"primary_sentAt": "2019-11-26T22:38:39", "email_name": "order_acknowledgement", "sms_skipped": false, ' +
                    '"primary_sent": true, "primary_email": "test@test.com", "message_error": false, ' +
                    '"alternate_email": "", "alternate_error": false, "phone_number": "", "alternate_sent": false, ' +
                    '"render_skipped": false, "message_skipped": false, "primary_error": false, "sms_error": false, ' +
                    '"sms_sentAt": null, "banner": "saks" ' +
                    '"rendered_messages": "saks/rendered/saks-order_acknowledgement-73108556-a1628244-33be-437e-bd38-ad727cd4a4dd.json", ' +
                    '"primary_skipped": false, "render_error": false, "render_info": "", "render_success": true, ' +
                    '"has_sms": false, "alternate_skipped": false, "alternate_info": "", "order_number": 73108556}]';
        }else if(this.callouttype.equalsIgnoreCase('/resend_rendered_message/')){
            body = '{ "sent": false        }';
        }
        else if(this.callouttype.equalsIgnoreCase('/preview/email')){
            body = '{ "sent": false,        }';
        }

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(this.callouttype.equalsIgnoreCase('/search_log'))
            req.setMethod('GET');
        else
        {
            req.setMethod('POST');
        }
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}