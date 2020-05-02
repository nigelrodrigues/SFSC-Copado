/**
 * Created by nrodrigues on 4/29/2020.
 */

@IsTest
global class trac_GetCustomerDetailsResource implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{' +
                '  "customerRecord": [' +
                '    {' +
                '      "firstName": "Jeremy",' +
                '      "middleName": null,' +
                '      "lastName": "Test",' +
                '      "prefix": null,' +
                '      "gender": null,' +
                '      "dateOfBirth": "1991-09-17",' +
                '      "suffix": null,' +
                '      "languagePref": null,' +
                '      "bannerCode": 4,' +
                '      "UCIDNumber": 150716369,' +
                '      "sourceCode": "POS",' +
                '      "externalId": [' +
                '        {' +
                '          "extTypeCode": "CLIENT",' +
                '          "extTypeValue": "XXXX18334XXXX"' +
                '        }' +
                '      ],' +
                '      "contactDetails": {' +
                '        "address1": "372 Saint-Catherine St W",' +
                '        "address2": null,' +
                '        "address3": null,' +
                '        "city": "Montreal",' +
                '        "stateCode": "QC",' +
                '        "postCode": "H3B 0B2",' +
                '        "postalPlusFour": null,' +
                '        "countryCode": "CA",' +
                '        "addressType": null,' +
                '        "emailId": "jhoran@tractionondemand.com",' +
                '        "phoneDetails": {' +
                '          "phoneNumber": "5141234567",' +
                '          "countryCode": 1' +
                '        }' +
                '      },' +
                '      "cardDetails": [' +
                '        {' +
                '          "type": "VISA",' +
                '          "tokenValue": "XXXX0844994XXXXX",' +
                '          "lastFour": "0010",' +
                '          "expiryMonth": "12",' +
                '          "expiryYear": "2018"' +
                '        }' +
                '      ],' +
                '      "primary_cardholder_IND": "SECONDARY"' +
                '    }' +
                '  ]' +
                '}');
        res.setStatusCode(200);
        return res;
    }
}