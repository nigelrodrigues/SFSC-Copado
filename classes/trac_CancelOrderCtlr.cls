/**
 *  @description Lightning controller for trac_CancelOrder
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        7/17/2019
 */
public with sharing class trac_CancelOrderCtlr {

    @AuraEnabled
    public static TLAuraResponse cancelOrder(String businessUnit, String orderNumber, String primeLineNumber, String subLineNumber, String cancelReason, String cancelReasonCode) {
        TLAuraResponse response = new TLAuraResponse(true);

        trac_WS_CancelOrder cancelOrder = new trac_WS_CancelOrder();

        try {
            
            cancelOrder.cancelOrderRequest.Order.OrderNo = orderNumber;
            cancelOrder.cancelOrderRequest.Order.EnterpriseCode = trac_WS_OrderUtils.getEnterpriseCodeFromBusinessUnit(businessUnit);
            cancelOrder.cancelOrderRequest.Order.DocumentType = trac_WS_OrderUtils.getOrderType();
            cancelOrder.cancelOrderRequest.Order.ModificationReasonCode = (cancelReasonCode != null) ? cancelReasonCode : trac_WS_OrderUtils.getModificationCode();
            cancelOrder.cancelOrderRequest.Order.ModificationReasonText = cancelReason;

            if (primeLineNumber != null && !String.isEmpty(primeLineNumber)) {
                cancelOrder.cancelOrderRequest.Order.Action = trac_WS_OrderUtils.getModifyAction();
                cancelOrder.cancelOrderRequest.Order.OrderLines.OrderLine.PrimeLineNo = primeLineNumber;
                cancelOrder.cancelOrderRequest.Order.OrderLines.OrderLine.SubLineNo = trac_WS_OrderUtils.getSubLineNumber();
                cancelOrder.cancelOrderRequest.Order.OrderLines.OrderLine.Action = trac_WS_OrderUtils.getCancelAction();
            }
            else {
                cancelOrder.cancelOrderRequest.Order.OrderLines = null;
                cancelOrder.cancelOrderRequest.Order.Action = trac_WS_OrderUtils.getCancelAction();
            }

            cancelOrder.send();

        } catch (Exception e) {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = cancelOrder.ENDPOINT,
                    Request__c = JSON.serializePretty(cancelOrder.cancelOrderRequest),
                    Service__c = 'Cancel Order'
            ));
            insert integrationError;

            String errorMessage = trac_WS_WebServiceHelper.DEFAULT_ERROR + integrationError.Id;

            response = new TLAuraResponse(false, errorMessage);
        }

        return response;
    }
}