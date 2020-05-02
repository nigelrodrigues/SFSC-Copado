/**
* @description Controller for trac_PurchaseOrder
* @author      Abhishek Singh Solanki, Traction on Demand
* @date        2020/03/27
*/

public with sharing class trac_PurchaseOrderCtrl {
    @AuraEnabled
    public static TLAuraResponse getPurchaseOrderLine(String businessUnit, String orderNumber, String DocumentType) {
        TLAuraResponse response = new TLAuraResponse(true);

        trac_WS_PurchaseOrder purchaseOrderLine = new trac_WS_PurchaseOrder();
        try {

            trac_WS_PurchaseOrder.req_OrderWrapper reqWrapper = new trac_WS_PurchaseOrder.req_OrderWrapper();
            reqWrapper.EnterpriseCode = trac_WS_OrderUtils.getEnterpriseCodeFromBusinessUnit(businessUnit);
            reqWrapper.DocumentType = DocumentType;
            reqWrapper.OrderNo = orderNumber;

            trac_WS_PurchaseOrder.purchaseOrderRequest req = new trac_WS_PurchaseOrder.purchaseOrderRequest();
            req.Order = reqWrapper;

            purchaseOrderLine.purchaseOrderRequest = req;

            purchaseOrderLine.send();

            response.returnValuesMap.put('orderResponse', purchaseOrderLine.purchaseOrderResponse);

        } catch (Exception e) {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = purchaseOrderLine.ENDPOINT,
                    Request__c = JSON.serializePretty(purchaseOrderLine.purchaseOrderRequest),
                    Service__c = 'Purchase Order (VendorNet)'
            ));
            insert integrationError;

            String errorMessage = trac_WS_WebServiceHelper.DEFAULT_ERROR + integrationError.Id;

            response = new TLAuraResponse(false, errorMessage);
        }

        return response;
    }

}