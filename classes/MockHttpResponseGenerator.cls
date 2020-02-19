/**
 * Created by ragrawal on 6/17/2019.
 */
@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"customerRecord":[{"firstName":"XXXXX","middleName":null,"lastName":"XXXXX","prefix":null,"gender":null,"dateOfBirth":null,"suffix":null,"languagePref":null,"bannerCode":8,"UCIDNumber":150716369,"sourceCode":"POS","externalId":[{"extTypeCode":"CLIENT","extTypeValue":"XXXX18334XXXX"}],"contactDetails":{"address1":"XXXXXX LOOP APT XX","address2":null,"address3":null,"city":"MOORESVILLE","stateCode":"XX","postCode":"28117","postalPlusFour":null,"countryCode":"US","addressType":null,"emailId":"KAXXX.XXX@HBC.COM","phoneDetails":{"phoneNumber":"5141234567","countryCode":1}},"cardDetails":[{"type":"VISA","tokenValue":"XXXX0844994XXXXX","lastFour":"0010","expiryMonth":"12","expiryYear":"2018"}],"primary_cardholder_IND":"SECONDARY"}]}');
        res.setStatusCode(200);
        return res;
    }
}