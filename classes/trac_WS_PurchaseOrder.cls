/**
 *  @description Purchase Order (VendorNet) web service class
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        3/16/2020
 */
public without sharing class trac_WS_PurchaseOrder {

    public final String ENDPOINT = (trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c != null) ?
            trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.OMS_Purchase_Order_Endpoint__c : trac_WS_WebServiceHelper.webServiceSettings.OMS_Purchase_Order_Endpoint__c;
    private HttpResponse res = new HttpResponse();
    public PurchaseOrderRequest purchaseOrderRequest;
    public PurchaseOrderResponse purchaseOrderResponse;
    public String jsonError;

    public trac_WS_PurchaseOrder() {
        purchaseOrderRequest = new PurchaseOrderRequest();
    }

    public Boolean send() {
        Boolean success = false;

        res = trac_WS_WebServiceHelper.sendPostRequest(getEndpoint(), purchaseOrderRequest);

        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            purchaseOrderResponse = parse(res.getBody());
            success = true;
        }
        else {
            jsonError = trac_WS_WebServiceHelper.getError(res);
            System.debug('Error: ' + trac_WS_WebServiceHelper.getError(res));
        }
        return success;
    }

    public static PurchaseOrderResponse parse(String json) {
        return (PurchaseOrderResponse) System.JSON.deserialize(json, PurchaseOrderResponse.class);
    }

    private String getEndpoint() {
        String dynamicEndpoint = ENDPOINT;

        if (purchaseOrderRequest != null && purchaseOrderRequest.Order != null) {

            String businessUnit = trac_WS_OrderUtils.getBusinessUnitFromEnterpriseCode(purchaseOrderRequest.Order.EnterpriseCode);

            dynamicEndpoint = trac_WS_OrderUtils.getDynamicEndpoint(dynamicEndpoint, businessUnit);
        }

        return dynamicEndpoint;
    }

    public class PurchaseOrderRequest {
        public req_OrderWrapper Order;

        public PurchaseOrderRequest() {
            Order = new req_OrderWrapper();
        }
    }

    public class req_OrderWrapper {
        public String EnterpriseCode;
        public String DocumentType;
        public String OrderNo;
    }

    public class PurchaseOrderResponse {
        @AuraEnabled public String LastOrderHeaderKey;
        @AuraEnabled public String ReadFromHistory;
        @AuraEnabled public List<res_OrderWrapper> Order;
        @AuraEnabled public String TotalOrderList;
        @AuraEnabled public String LastRecordSet;
    }

    public class res_OrderWrapper {
        @AuraEnabled public String OrderNo;
        @AuraEnabled public String EnterpriseCode;
        @AuraEnabled public res_OrderLinesWrapper OrderLines;
        @AuraEnabled public String DocumentType;
    }

    public class res_OrderLinesWrapper {
        @AuraEnabled public List<res_OrderLineWrapper> OrderLine;
    }

    public class res_OrderLineWrapper {
        @AuraEnabled public String PrimeLineNo;
        @AuraEnabled public res_ChainedFromOrderLineWrapper ChainedFromOrderLine;
        @AuraEnabled public String ChainedFromOrderHeaderKey;
        @AuraEnabled public String ChainedFromOrderLineKey;
        @AuraEnabled public String SubLineNo;
        @AuraEnabled public res_ShipnodeWrapper Shipnode;
    }

    public class res_ChainedFromOrderLineWrapper {
        @AuraEnabled public String PrimeLineNo;
        @AuraEnabled public res_OrderWrapper Order;
        @AuraEnabled public String SubLineNo;
    }

    public class res_ShipnodeWrapper {
        @AuraEnabled public String ShipnodeKey;
        @AuraEnabled public res_ShipNodePersonInfoWrapper ShipNodePersonInfo;
        @AuraEnabled public String OwnerKey;
        @AuraEnabled public String NodeType;
        @AuraEnabled public String ShippingNode;
        @AuraEnabled public String ShipNode;
    }

    public class res_ShipNodePersonInfoWrapper {
        @AuraEnabled public String EMailID;
        @AuraEnabled public String State;
        @AuraEnabled public String FirstName;
        @AuraEnabled public String LastName;
        @AuraEnabled public String DayPhone;
        @AuraEnabled public String Country;
        @AuraEnabled public String ZipCode;
        @AuraEnabled public String AddressLine1;
        @AuraEnabled public String City;
        @AuraEnabled public String AddressLine2;
    }
}