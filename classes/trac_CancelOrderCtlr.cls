/**
 *  @description Lightning controller for trac_CancelOrder
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        7/17/2019
 */
public without sharing class trac_CancelOrderCtlr {

    private final static String CASE_FAILED_MSG = 'Case update failed.';

    @AuraEnabled
    public static TLAuraResponse cancelOrder(Case caseRecord,
                                            String businessUnit,
                                            String orderNumber,
                                            String primeLineNumber,
                                            String subLineNumber,
                                            String cancelReason,
                                            String cancelReasonCode,
                                            String quantityToCancel)
    {
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

                if (quantityToCancel != null && !String.isEmpty(quantityToCancel)) {
                    cancelOrder.cancelOrderRequest.Order.OrderLines.OrderLine.QuantityToCancel = quantityToCancel;
                }
            }
            else {
                cancelOrder.cancelOrderRequest.Order.OrderLines = null;
                cancelOrder.cancelOrderRequest.Order.Action = trac_WS_OrderUtils.getCancelAction();
            }

            cancelOrder.send();
            updateCase(caseRecord, cancelReason, cancelReasonCode);

        } catch (Exception e) {
            if( !e.getMessage().contains(CASE_FAILED_MSG) ) {
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
        }

        return response;
    }

    public static void updateCase(Case caseRecord, String cancelReason, String cancelReasonCode)
    {
        Map<String, String> cancellationReasonsMap = fetchCancellationReasons();
        for(String cancelReasonField : cancellationReasonsMap.keyset())
        {
            if(cancellationReasonsMap.get(cancelReasonField).equals(cancelReasonCode))
            {
                caseRecord.Cancellation_Type__c = cancelReasonField;
            }
        }
        try {
            caseRecord.Cancellation_Reason__c = cancelReason;
            caseRecord.Order_is_Cancelled__c = true;
            update caseRecord;
        }
        catch(Exception e)
        {
            throw new CustomException(CASE_FAILED_MSG + 'Error: ' + e.getMessage());
        }
    }

    public class CustomException extends Exception{

    }

    /**
     * Fetches the Case Cancellation Reasons and returns it to the Lightning component trac_CancelOrder
     * @author Nigel Rodrigues, Traction on Demand
     * @date 28-Jan-2020
     * @return the map of picklist Cancellation Reason Value picklist
     */
    @AuraEnabled
    public static Map<String, String> fetchCancellationReasons()
    {
        Map<String, String> cancellationPicklistValues = new Map<String, String>();
        Schema.DescribeFieldResult field = Case.Cancellation_Type__c.getDescribe();

        for (Schema.PicklistEntry f : field.getPicklistValues())
            cancellationPicklistValues.put(f.getLabel(), f.getValue());
        return cancellationPicklistValues;
    }
}