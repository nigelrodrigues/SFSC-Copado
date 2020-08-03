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
           body = '{"LineStatusHistory":[{"Status":"3700","PrimeLineNo":"1","StatusDescription":"Shipped","NodeType":"Store","StatusQuantity":"1","OrderLineKey":"202007131022098579305124","NodeDescription":"NEW YORK","SubLineNo":"1","Createts":"2020-07-13T11:45:42-04:00","ShipNode":"8601"},{"Status":"3200","PrimeLineNo":"1","StatusDescription":"Released","NodeType":"Store","StatusQuantity":"1","OrderLineKey":"202007131022098579305124","NodeDescription":"NEW YORK","SubLineNo":"1","Createts":"2020-07-13T10:50:31-04:00","ShipNode":"8601"},{"Status":"1100","PrimeLineNo":"1","StatusDescription":"Created","ReasonDescription":"Fraud  Review Hold resolved on 07\\/13\\/2020 10:35:39","StatusQuantity":"1","ReasonCode":"HBC_SC_FR_002","OrderLineKey":"202007131022098579305124","SubLineNo":"1","Createts":"2020-07-13T10:35:40-04:00"}],"ResponseCode":"0","ResposneMessage":"Sucess"}';
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