/**
 * Created by ragrawal on 7/15/2019.
 */
@isTest
global class MockHttpResponseContact implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
    // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"firstName":"","lastName":"JACKSON","middleInitial":"","suffix":"","prefix":"Mr.","languagePrefCode":0,"genderType":"M","UCIDNumber":130598487,"dateOfBirth":"1980-09-28","accountDetails":{"emailId":"rajesh.chittineni@hbc.com","phoneDetails":{"phoneNumber":"","countryCode":1,"phoneNumberType":"H"},"contactDetails":{"address1":"698 Lawrence Ave W","address2":"","address3":"","city":"North York","stateCode":"ON","postCode":"M6A 296","postalPlusFour":"","countryCode":"CA","addressType":"O"}},"sourceId":"SFUAD","bannerCode":8,"emailActiveIND":"A","phoneActiveIND":"A","addressActiveIND":"A"}');
        res.setStatusCode(200);
        return res;
    }
}