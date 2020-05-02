/**
 *  @description Aura controller for trac_OrderLineStatusHistory component
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        2/4/2020
 */
public with sharing class trac_OrderLineStatusHistoryCtlr {


    @AuraEnabled
    public static TLAuraResponse getLineHistory(String businessUnit, String orderNumber, String lineItemNumber) {
        TLAuraResponse response = new TLAuraResponse(true);

        trac_WS_OrderLineHistory orderLineHistory = new trac_WS_OrderLineHistory();
        try {

            trac_WS_OrderLineHistory.req_OrderWrapper reqWrapper = new trac_WS_OrderLineHistory.req_OrderWrapper();
            reqWrapper.EnterpriseCode = trac_WS_OrderUtils.getEnterpriseCodeFromBusinessUnit(businessUnit);
            reqWrapper.DocumentType = trac_WS_OrderUtils.getOrderType();
            reqWrapper.OrderNo = orderNumber;

            if (lineItemNumber != null) {
                trac_WS_OrderLineHistory.req_OrderLineWrapper reqOrderLineWrapper = new trac_WS_OrderLineHistory.req_OrderLineWrapper();
                reqOrderLineWrapper.PrimeLineNo = lineItemNumber;
                reqOrderLineWrapper.SubLineNo = trac_WS_OrderUtils.getSubLineNumber();

                trac_WS_OrderLineHistory.req_OrderLinesWrapper reqOrderLinesWrapper = new trac_WS_OrderLineHistory.req_OrderLinesWrapper();
                reqOrderLinesWrapper.OrderLine = reqOrderLineWrapper;

                reqWrapper.OrderLines = reqOrderLinesWrapper;
            }

            trac_WS_OrderLineHistory.OrderLineHistoryRequest req = new trac_WS_OrderLineHistory.OrderLineHistoryRequest();
            req.Order = reqWrapper;

            orderLineHistory.orderLineHistoryRequest = req;

            orderLineHistory.send();

            response.returnValuesMap.put('lineStatusHistory', orderLineHistory.orderLineHistoryResponse);
        }
        catch (Exception e) {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = orderLineHistory.ENDPOINT,
                    Request__c = JSON.serializePretty(orderLineHistory.orderLineHistoryRequest),
                    Service__c = 'Order Line Status History'
            ));
            insert integrationError;

            String errorMessage = trac_WS_WebServiceHelper.DEFAULT_ERROR + integrationError.Id;

            response = new TLAuraResponse(false, errorMessage);
        }

        return response;
    }
}