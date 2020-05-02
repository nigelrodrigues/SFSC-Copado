/**
 *  @description Lightning controller for trac_OrderReturnFee component
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        3/17/2020
 */
public without sharing class trac_OrderReturnFeeCtlr {

    @AuraEnabled
    public static TLAuraResponse updateOrderReturnFee(String enterpriseCode, String orderNumber, Boolean refundShippingCharge, Boolean chargePrepaidShippingLabel) {
        TLAuraResponse response = new TLAuraResponse(true);

        trac_WS_OrderReturns orderReturns = new trac_WS_OrderReturns();
        try {

            orderReturns.orderReturnsRequest.Order.EnterpriseCode = enterpriseCode;
            orderReturns.orderReturnsRequest.Order.DocumentType = trac_WS_OrderUtils.getOrderType();
            orderReturns.orderReturnsRequest.Order.OrderNo = orderNumber;

            orderReturns.orderReturnsRequest.Order.Notes.Note.ContactReference = UserInfo.getName();
            orderReturns.orderReturnsRequest.Order.Notes.Note.NoteText = getNoteText(refundShippingCharge, chargePrepaidShippingLabel);
            orderReturns.orderReturnsRequest.Order.Notes.Note.ReasonCode = getReasonCode(refundShippingCharge, chargePrepaidShippingLabel);

            orderReturns.orderReturnsRequest.Order.Extn.ExtnRefundShippingCharge = (refundShippingCharge) ? 'Y' : 'N';
            orderReturns.orderReturnsRequest.Order.Extn.ExtnChargeShippingLabel = (chargePrepaidShippingLabel) ? 'Y' : 'N';

            Boolean success = orderReturns.send();

            if (!success) {
                throw new AuraHandledException(orderReturns.jsonError);
            }
        }
        catch (Exception e) {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = orderReturns.ENDPOINT,
                    Request__c = JSON.serializePretty(orderReturns.orderReturnsRequest),
                    Service__c = 'Order Return Service'
            ));
            insert integrationError;

            String errorMessage = trac_WS_WebServiceHelper.DEFAULT_ERROR + integrationError.Id;

            response = new TLAuraResponse(false, errorMessage);
        }

        return response;
    }

    private static String getNoteText(Boolean refundShippingCharge, Boolean chargePrepaidShippingLabel) {
        String noteText;

        if (refundShippingCharge && chargePrepaidShippingLabel) {
            noteText = 'Check Refund Ship and Charge Prepaid Label';
        }
        else if (!refundShippingCharge && chargePrepaidShippingLabel) {
            noteText = 'Charge for Prepaid Label';
        }
        else if (refundShippingCharge && !chargePrepaidShippingLabel) {
            noteText = 'Adding Refund Ship';
        }
        else if (!refundShippingCharge && !chargePrepaidShippingLabel) {
            noteText = 'No Refund and No Charge Prepaid Label';
        }

        return noteText;
    }

    private static String getReasonCode(Boolean refundShippingCharge, Boolean chargePrepaidShippingLabel) {
        String reasonCode;

        if (refundShippingCharge && chargePrepaidShippingLabel) {
            reasonCode = 'REFUND_AND_PREPAID';
        }
        else if (!refundShippingCharge && chargePrepaidShippingLabel) {
            reasonCode = 'PREPAID_CHARGES';
        }
        else if (refundShippingCharge && !chargePrepaidShippingLabel) {
            reasonCode = 'REFUND_CHARGES';
        }
        else if (!refundShippingCharge && !chargePrepaidShippingLabel) {
            reasonCode = 'NO_REFUND_AND_PREPAID';
        }

        return reasonCode;
    }
}