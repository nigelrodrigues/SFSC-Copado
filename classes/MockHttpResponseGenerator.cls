/**
 * Created by ragrawal on 6/17/2019.
 */
@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {

    private String useCase = 'ucid-search';

    global MockHttpResponseGenerator() {
        // default constructor
    }

    global MockHttpResponseGenerator(String inputUseCase) {
        // non-default constructor
        useCase = inputUseCase;
    }

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        switch on useCase {
            when 'sfcc-search' {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"_v":"20.4","_type":"customer_search_result","count":1,"hits":[{"_type":"customer_search_hit","data":{"_type":"customer","creation_date":"2020-04-15T14:22:48.000Z","credentials":{"_type":"credentials","enabled":true,"locked":false,"login":"SANDEEP92@GMAIL.COM"},"customer_id":"ab5FILqqom62TqbekXe7HXUbGn","customer_no":"00028505","email":"SANDEEP92@GMAIL.COM","first_name":"Sandy","last_login_time":"2020-04-15T14:22:48.000Z","last_modified":"2020-04-15T14:22:49.000Z","last_name":"SG","last_visit_time":"2020-04-15T14:22:48.000Z","previous_login_time":"2020-04-15T14:22:48.000Z","previous_visit_time":"2020-04-15T14:22:48.000Z","c_accountModifiedDate":"2020-04-15T14:22:48.550Z","c_emailOptIn":true,"c_legacyPasswordHash":"291f315d9303116ab10b2ee44cf0006e3ba4a112","c_preferredLanguage":"ENGLISH","c_ucidNo":1.51838313E8,"c_zipCode":"A1A 1A1"},"relevance":8.632575988769531}],"query":{"text_query":{"_type":"text_query","fields":["email"],"search_phrase":"testtest@testtest.com"}},"select":"(**)","start":0,"total":1}');
                res.setStatusCode(200);
            }
            when else {
                // default to ucid-search
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"customerRecord":[{"firstName":"XXXXX","middleName":null,"lastName":"XXXXX","prefix":null,"gender":null,"dateOfBirth":null,"suffix":null,"languagePref":null,"bannerCode":8,"UCIDNumber":150716369,"sourceCode":"POS","externalId":[{"extTypeCode":"CLIENT","extTypeValue":"XXXX18334XXXX"}],"contactDetails":{"address1":"XXXXXX LOOP APT XX","address2":null,"address3":null,"city":"MOORESVILLE","stateCode":"XX","postCode":"28117","postalPlusFour":null,"countryCode":"US","addressType":null,"emailId":"KAXXX.XXX@HBC.COM","phoneDetails":{"phoneNumber":"5141234567","countryCode":1}},"cardDetails":[{"type":"VISA","tokenValue":"XXXX0844994XXXXX","lastFour":"0010","expiryMonth":"12","expiryYear":"2018"}],"primary_cardholder_IND":"SECONDARY"}]}');
                res.setStatusCode(200);
            }
        }
        return res;
    }
}