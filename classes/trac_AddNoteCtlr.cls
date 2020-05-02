/**
 *  @description Lightning controller for trac_AddNote
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        7/5/2019
 */
public with sharing class trac_AddNoteCtlr {


    @AuraEnabled
    public static TLAuraResponse addNotes(String businessUnit, String orderNumber, String primeLineNumber, String subLineNumber, String notes) {
        TLAuraResponse response = new TLAuraResponse(true);

        try {
            trac_WS_UpdateOrder updateOrder = new trac_WS_UpdateOrder();

            updateOrder.updateOrderRequest.Order.Action = trac_WS_OrderUtils.getModifyAction();
            updateOrder.updateOrderRequest.Order.OrderNo = orderNumber;
            updateOrder.updateOrderRequest.Order.EnterpriseCode = trac_WS_OrderUtils.getEnterpriseCodeFromBusinessUnit(businessUnit);
            updateOrder.updateOrderRequest.Order.DocumentType = trac_WS_OrderUtils.getOrderType();

            if (primeLineNumber != null && !String.isEmpty(primeLineNumber)) {
                updateOrder.updateOrderRequest.Order.OrderLines.OrderLine.Notes = getNotesWrapperFromString(notes);
                updateOrder.updateOrderRequest.Order.OrderLines.OrderLine.PrimeLineNo = primeLineNumber;
                updateOrder.updateOrderRequest.Order.OrderLines.OrderLine.SubLineNo = trac_WS_OrderUtils.getSubLineNumber();
                updateOrder.updateOrderRequest.Order.Notes = null;
            }
            else {
                updateOrder.updateOrderRequest.Order.Notes = getNotesWrapperFromString(notes);
                updateOrder.updateOrderRequest.Order.OrderLines.OrderLine = null;
            }

            Boolean success = updateOrder.send();

            if (!success) {
                Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                        Description__c = updateOrder.jsonError,
                        Endpoint__c = updateOrder.ENDPOINT,
                        Request__c = JSON.serializePretty(updateOrder.updateOrderRequest),
                        Service__c = 'Add Notes To Order'
                ));
                insert integrationError;

                response = new TLAuraResponse(false, 'Looks like there\'s a problem with OMS, give your admin this  error ID: ' + integrationError.Id);
            }

        } catch (Exception e) {
            response = new TLAuraResponse(false, e.getMessage() + '\n' + e.getStackTraceString());
        }

        return response;
    }

    private static trac_WS_UpdateOrder.req_NotesWrapper getNotesWrapperFromString(String notesString) {
        trac_WS_UpdateOrder.req_NotesWrapper notesWrapper = new trac_WS_UpdateOrder.req_NotesWrapper();

        notesWrapper.Note.NoteText = notesString;
        notesWrapper.Note.ContactUser = UserInfo.getName();

        return notesWrapper;
    }
}