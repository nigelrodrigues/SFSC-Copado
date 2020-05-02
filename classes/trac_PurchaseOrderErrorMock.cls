/**
 * Created by nrodrigues on 4/28/2020.
 */

@isTest
global class trac_PurchaseOrderErrorMock implements HttpCalloutMock {
// Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
// Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"LastOrderHeaderKey":"202003111525107381760465","ReadFromHistory":"""Order":[{"OrderNo":"6027731","EnterpriseCode":"SAKS","OrderLines":{"OrderLine":[{"PrimeLineNo":"1","ChainedFromOrderLine":{"PrimeLineNo":"1","Order":{"OrderNo":"3000011620","EnterpriseCode":"SAKS","DocumentType":"0001"},"SubLineNo":"1"},"SubLineNo":"1","Shipnode":{"ShipNodePersonInfo":{"EMailID":"","State":"FL","FirstName":"SCHOENHUT PIANO CO INC","LastName":"","DayPhone":"","Country":"US","ZipCode":"32095","AddressLine1":"6480-B US 1 NORTH","City":"SAINT AUGUSTINE","AddressLine2":"","AddressLine3":""},"OwnerKey":"VENDOR_SAKS","NodeType":"Vendor","ShippingNode":"Y","ShipNode":"7005425"}}]},"DocumentType":"0005"}],"TotalOrderList":"1","LastRecordSet":"Y","ResponseCode":"0","ResposneMessage":"Sucess"}');
        res.setStatusCode(200);
        return res;
    }
}