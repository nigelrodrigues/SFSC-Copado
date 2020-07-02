/**
 * Created by nrodrigues on 6/5/2020.
 */



@IsTest
global class MockResponseLoyaltyEvent implements HttpCalloutMock {

    private String callouttype;

    public MockResponseLoyaltyEvent(){
        this.callouttype = 'Loyalty Event History';
    }

    public MockResponseLoyaltyEvent(String reqType){
        this.callouttype = reqType;
    }

    global HTTPResponse respond(HTTPRequest req) {

        String body = null;
        if(this.callouttype.equalsIgnoreCase('uad/customer/events')){
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(404);
            return res;
        }
        if(this.callouttype.equalsIgnoreCase('/customer/events')){

                    body = '{' +
                            '  "data": [' +
                            '    {' +
                            '      "id": 295842026,' +
                            '      "event_id": "3334196300104262020",' +
                            '      "customer_id": 72616085,' +
                            '      "email": "vladanazarubina511@optonline.net",' +
                            '      "event_type": "return",' +
                            '      "status": 2,' +
                            '      "detail": null,' +
                            '      "created_at": "2020-06-04T07:40:06-07:00",' +
                            '      "updated_at": "2020-06-04T07:40:06-07:00",' +
                            '      "value": "-53.11",' +
                            '      "points": -106,' +
                            '      "external_customer_id": "123456999998007",' +
                            '      "channel": null,' +
                            '      "tier_id": 3836,' +
                            '      "display_detail": "Return",' +
                            '      "rule": {' +
                            '        "id": 52632,' +
                            '        "rule_type": "base",' +
                            '        "ledger": [' +
                            '          {' +
                            '            "id": 175912213,' +
                            '            "ledger_type": "base",' +
                            '            "title": "Return - $53",' +
                            '            "points": -53,' +
                            '            "data": {' +
                            '              "operator": "times",' +
                            '              "operator_value": 1,' +
                            '              "original_value": 53,' +
                            '              "rounding_adjustment": "-0.11",' +
                            '              "rounding": "floor"' +
                            '            }' +
                            '          },' +
                            '          {' +
                            '            "id": 175912214,' +
                            '            "ledger_type": "tier",' +
                            '            "title": "Tier - Hudson’s Bay Rewards VIP",' +
                            '            "points": -53,' +
                            '            "data": {' +
                            '              "operator": "times",' +
                            '              "operator_value": 1,' +
                            '              "original_value": 53,' +
                            '              "name": "Hudson’s Bay Rewards VIP"' +
                            '            }' +
                            '          }' +
                            '        ]' +
                            '      }' +
                            '    }], "success":true }';
        }

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}