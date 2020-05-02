@isTest
global class trac_PurchaseOrderFailedMock implements HttpCalloutMock {
// Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
// Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ResponseCode":"404","ResposneMessage":"ERROR"}');
        res.setStatusCode(404);
        return res;
    }
}