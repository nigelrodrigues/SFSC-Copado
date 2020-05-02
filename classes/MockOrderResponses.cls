/**
 * Created by nrodrigues on 4/28/2020.
 */

@IsTest
global class MockOrderResponses implements HttpCalloutMock{
    private String callouttype;

    public MockOrderResponses(){
        this.callouttype = 'Order';
    }

    public MockOrderResponses(String reqType){
        this.callouttype = reqType;
    }

    global HTTPResponse respond(HTTPRequest req) {

        String body = null;
        if(this.callouttype.equalsIgnoreCase('/cancel')){
            //Order details by order id
            // BuildMyString.com generated code. Please enjoy your string responsibly.

            body = '{' +
                    '    \'Notes\': {' +
                    '        \'NumberOfNotes\': \'3\',' +
                    '        \'Note\': [' +
                    '            {' +
                    '                \'ContactUser\': \'SYSTEM\',' +
                    '                \'NoteText\': \'test@tw.com\'' +
                    '            },' +
                    '            {' +
                    '                \'ContactUser\': \'SYSTEM\',' +
                    '                \'NoteText\': \'Mad\'' +
                    '            },' +
                    '            {' +
                    '                \'ContactUser\': \'SYSTEM\',' +
                    '                \'NoteText\': \'Murdock\'' +
                    '            }' +
                    '        ]' +
                    '    },' +
                    '    \'OrderNo\': \'49000001260\',' +
                    '    \'EnterpriseCode\': \'BAY\',' +
                    '    \'OrderLines\': {' +
                    '        \'OrderLine\': [' +
                    '            {' +
                    '                \'Notes\': {' +
                    '                    \'NumberOfNotes\': \'0\'' +
                    '                },' +
                    '                \'PrimeLineNo\': \'1\',' +
                    '                \'MaxLineStatusDesc\': \'Cancelled\',' +
                    '                \'Item\': {' +
                    '                    \'ItemID\': \'84362252\',' +
                    '                    \'UnitOfMeasure\': \'EACH\'' +
                    '                },' +
                    '                \'OrderedQty\': \'0\'' +
                    '            }' +
                    '        ]' +
                    '    },' +
                    '    \'MaxOrderStatusDesc\': \'Cancelled\',' +
                    '    \'DocumentType\': \'0001\',' +
                    '    \'ResponseCode\': \'0\',' +
                    '    \'ResposneMessage\': \'Sucess\'' +
                    '}';
        }
        else if(this.callouttype.equalsIgnoreCase('/history'))
        {
           body = '{' +
                   '  "LineStatusHistoryList": {' +
                   '    "LineStatusHistory": [' +
                   '      {' +
                   '        "OrderLineKey": "20200114133607502158840",' +
                   '        "PrimeLineNo": "1",' +
                   '        "ReasonCode": "HBC_SC_FR_001",' +
                   '        "ReasonDescription": "Fraud Hold resolved on 01/14/2020 01:37:29",' +
                   '        "Status": "1300",' +
                   '        "StatusDescription": "FraudHoldResolved",' +
                   '        "StatusQuantity": "1",' +
                   '        "SubLineNo": "1"' +
                   '      },' +
                   '      {' +
                   '        "NodeDescription": "8601 NEW YORK",' +
                   '        "NodeType": "Store",' +
                   '        "OrderLineKey": "20200114133607502158840",' +
                   '        "PrimeLineNo": "1",' +
                   '        "ReasonCode": "HBC_SB_SM_001",' +
                   '        "ReasonDescription": "Backordering the order as no action taken by Store with in targetted duration",' +
                   '        "ShipNode": "8601",' +
                   '        "Status": "1300",' +
                   '        "StatusDescription": "Backordered",' +
                   '        "SubLineNo": "1"' +
                   '      },' +
                   '      {' +
                   '        "NodeDescription": "8601 NEW YORK",' +
                   '        "NodeType": "Store",' +
                   '        "OrderLineKey": "20200114133607502158840",' +
                   '        "PrimeLineNo": "1",' +
                   '        "ShipNode": "8601",' +
                   '        "Status": "3200",' +
                   '        "StatusDescription": "Released",' +
                   '        "StatusQuantity": "1",' +
                   '        "SubLineNo": "1"' +
                   '      },' +
                   '      {' +
                   '        "NodeDescription": "8601 NEW YORK",' +
                   '        "NodeType": "Store",' +
                   '        "OrderLineKey": "20200114133607502158840",' +
                   '        "PrimeLineNo": "1",' +
                   '        "ShipNode": "8601",' +
                   '        "Status": "3200",' +
                   '        "StatusDescription": "Released",' +
                   '        "StatusQuantity": "1",' +
                   '        "SubLineNo": "1"' +
                   '      },' +
                   '      {' +
                   '        "NodeDescription": "8601 NEW YORK",' +
                   '        "NodeType": "Store",' +
                   '        "OrderLineKey": "20200114133607502158840",' +
                   '        "PrimeLineNo": "1",' +
                   '        "ShipNode": "8601",' +
                   '        "Status": "3700",' +
                   '        "StatusDescription": "Shipped",' +
                   '        "StatusQuantity": "1",' +
                   '        "SubLineNo": "1"' +
                   '      }' +
                   '    ]' +
                   '  }' +
                   '}';
        }
        else if(this.callouttype.equalsIgnoreCase('/update'))
        {
            body =  '{' +
            '    "OrderNo": "3000025397",' +
            '    "EnterpriseCode": "SAKS",' +
            '    "OrderLines": {' +
            '        "OrderLine": [' +
            '            {' +
            '                "Notes": {' +
            '                    "NumberOfNotes": "0"' +
            '                },' +
            '                "PrimeLineNo": "1",' +
            '                "MaxLineStatusDesc": "Scheduled",' +
            '                "Item": {' +
            '                    "ItemID": "87505214",' +
            '                    "UnitOfMeasure": "EACH"' +
            '                },' +
            '                "OrderedQty": "10"' +
            '            },' +
            '            {' +
            '                "Notes": {' +
            '                    "NumberOfNotes": "0"' +
            '                },' +
            '                "PrimeLineNo": "4",' +
            '                "MaxLineStatusDesc": "Scheduled",' +
            '                "Item": {' +
            '                    "ItemID": "87505214",' +
            '                    "UnitOfMeasure": "EACH"' +
            '                },' +
            '                "OrderedQty": "1"' +
            '            },' +
            '            {' +
            '                "Notes": {' +
            '                    "NumberOfNotes": "0"' +
            '                },' +
            '                "PrimeLineNo": "5",' +
            '                "MaxLineStatusDesc": "Scheduled",' +
            '                "Item": {' +
            '                    "ItemID": "87505214",' +
            '                    "UnitOfMeasure": "EACH"' +
            '                },' +
            '                "OrderedQty": "1"' +
            '            },' +
            '            {' +
            '                "Notes": {' +
            '                    "NumberOfNotes": "0"' +
            '                },' +
            '                "PrimeLineNo": "7",' +
            '                "MaxLineStatusDesc": "Cancelled",' +
            '                "Item": {' +
            '                    "ItemID": "87505214",' +
            '                    "UnitOfMeasure": "EACH"' +
            '                },' +
            '                "OrderedQty": "0"' +
            '            },' +
            '            {' +
            '                "Notes": {' +
            '                    "NumberOfNotes": "0"' +
            '                },' +
            '                "PrimeLineNo": "8",' +
            '                "MaxLineStatusDesc": "Scheduled",' +
            '                "Item": {' +
            '                    "ItemID": "87505214",' +
            '                    "UnitOfMeasure": "EACH"' +
            '                },' +
            '                "OrderedQty": "1"' +
            '            },' +
            '            {' +
            '                "Notes": {' +
            '                    "NumberOfNotes": "0"' +
            '                },' +
            '                "PrimeLineNo": "6",' +
            '                "MaxLineStatusDesc": "Scheduled",' +
            '                "Item": {' +
            '                    "ItemID": "87505214",' +
            '                    "UnitOfMeasure": "EACH"' +
            '                },' +
            '                "OrderedQty": "7"' +
            '            },' +
            '            {' +
            '                "Notes": {' +
            '                    "NumberOfNotes": "0"' +
            '                },' +
            '                "PrimeLineNo": "3",' +
            '                "MaxLineStatusDesc": "Scheduled",' +
            '                "Item": {' +
            '                    "ItemID": "87505214",' +
            '                    "UnitOfMeasure": "EACH"' +
            '                },' +
            '                "OrderedQty": "4"' +
            '            },' +
            '            {' +
            '                "Notes": {' +
            '                    "NumberOfNotes": "0"' +
            '                },' +
            '                "PrimeLineNo": "2",' +
            '                "MaxLineStatusDesc": "Scheduled",' +
            '                "Item": {' +
            '                    "ItemID": "87505214",' +
            '                    "UnitOfMeasure": "EACH"' +
            '                },' +
            '                "OrderedQty": "1"' +
            '            }' +
            '        ]' +
            '    },' +
            '    "MaxOrderStatusDesc": "Scheduled",' +
            '    "DocumentType": "0001",' +
            '        "Notes": {' +
            '        "NumberOfNotes": "0"' +
            '    }' +
            '}';
        }
        else if(this.callouttype.equalsIgnoreCase('/ordereturn'))
        {
            body = '{' +
            '    "Order": {' +
            '        "DocumentType": "0001",' +
            '        "EnterpriseCode": "BAY",' +
            '        "MaxOrderStatusDesc": "Released",' +
            '        "OrderNo": "2820000150",' +
            '        "OrderLines": {' +
            '            "OrderLine": {' +
            '                "Item": {' +
            '                    "ItemID": "90600548",' +
            '                    "UnitOfMeasure": "EACH"' +
            '                },' +
            '                "Notes": {' +
            '                    "NumberOfNotes": "0"' +
            '                },' +
            '                "MaxLineStatusDesc": "Released",' +
            '                "OrderedQty": "1",' +
            '                "PrimeLineNo": "1"' +
            '            }' +
            '        },' +
            '        "Notes": {' +
            '            "Note": {' +
            '                "ContactReference": "12345",' +
            '                "ContactType": "PHONE",' +
            '                "NoteText": "Adding Refund Ship charge",' +
            '                "ReasonCode": "REFUND_CHARGES"' +
            '            },' +
            '            "NumberOfNotes": "1"' +
            '        }' +
            '    }' +
            '}';
        }

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatusCode(200);
        return res;
    }
}