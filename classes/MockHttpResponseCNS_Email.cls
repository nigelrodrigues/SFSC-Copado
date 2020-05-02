/**
 * Created by nrodrigues on 3/23/2020.
 */

@IsTest
global class MockHttpResponseCNS_Email implements HttpCalloutMock {

    private String callouttype;

    public MockHttpResponseCNS_Email(){
        this.callouttype = 'Order';
    }

    public MockHttpResponseCNS_Email(String reqType){
        this.callouttype = reqType;
    }

    global HTTPResponse respond(HTTPRequest req) {

        String body = null;
        if(this.callouttype.equalsIgnoreCase('/search_log')){
            //Order details by order id
            body = '[{"raw_payload": "saks/payload/saks-order_received-73108556-3888e116-ece5-4d4f-9375-e2519ee7f67e.json", ' +
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
                    '"has_sms": false, "alternate_skipped": false, "alternate_info": "", "order_number": 73108556}]';
        }else if(this.callouttype.equalsIgnoreCase('/resend_rendered_message/')){

            body = '{ "sent":1       }';
        }
        else if(this.callouttype.equalsIgnoreCase('/preview/email')){

            body = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> <html xmlns="http://www.w3.org/1999/xhtml"> <head> <meta http-equiv=Content-Type content="text/html; charset=utf-8"/> <!--[if !mso]><!--> <meta http-equiv=X-UA-Compatible content="IE=edge"/> <!--<![endif]--> <meta name=viewport content="width=device-width, initial-scale=1.0"/> <title></title> <!--[if (gte mso 9)&#124;(IE)]><style type="text/css">table {border-collapse: collapse !important;}</style><![endif]--> <style type="text/css">';
            body += '@media screen and (max-width: 400px), screen and (max-width: 600px) {';
            body += '#logo {';
            body += 'float: left;';
        }

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}