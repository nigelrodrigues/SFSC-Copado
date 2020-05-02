/**
 * Created by nrodrigues on 4/28/2020.
 */

@IsTest
global class trac_CustomerDetailsResponse implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{' +
                '      "OrderNo":"12345",' +
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
                '      "PersonInfoBillTo": {' +
                '        "EMailID": "rravi@pfsweb.com",' +
                '        "MiddleName": "",' +
                '        "State": "IL",' +
                '        "FirstName": "Rahul",' +
                '        "LastName": "Ravi",' +
                '        "DayPhone": "3333333333",' +
                '        "Country": "US",' +
                '        "ZipCode": "60707-4018",' +
                '        "AddressLine1": "1706 N Nagle Ave",' +
                '        "City": "Chicago",' +
                '        "AddressLine2": ""' +
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
                '    ' +
                '}');
        res.setStatusCode(200);
        return res;
    }
}