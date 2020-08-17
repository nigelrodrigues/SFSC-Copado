/**
 *  @description Update Order web service class
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        7/3/2019
 */
public with sharing class trac_WS_UpdateOrder {
    public final String ENDPOINT = (trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c != null) ?
            trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.Update_Order_Endpoint__c : trac_WS_WebServiceHelper.webServiceSettings.Update_Order_Endpoint__c;

    private HttpResponse res = new HttpResponse();

    public String jsonError;
    public UpdateOrderRequest updateOrderRequest;
    public UpdateOrderResponse updateOrderResponse;

    public trac_WS_UpdateOrder() {
        updateOrderRequest = new UpdateOrderRequest();
    }

    public Boolean send() {
        Boolean success = false;

        res = trac_WS_WebServiceHelper.sendPutRequest(getEndpoint(), updateOrderRequest);
        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            updateOrderResponse = parse(res.getBody());
            success = true;
        }
        else {
            jsonError = trac_WS_WebServiceHelper.getError(res);
            System.debug('Error: ' + trac_WS_WebServiceHelper.getError(res));
        }
        return success;
    }

    private String getEndpoint() {
        String dynamicEndpoint = ENDPOINT;

        if (updateOrderRequest != null && updateOrderRequest.Order != null) {

            String businessUnit = trac_WS_OrderUtils.getBusinessUnitFromEnterpriseCode(updateOrderRequest.Order.EnterpriseCode);

            dynamicEndpoint = trac_WS_OrderUtils.getDynamicEndpoint(dynamicEndpoint, businessUnit);
        }

        return dynamicEndpoint;
    }

    public static UpdateOrderResponse parse(String json) {
        return (UpdateOrderResponse) System.JSON.deserialize(json, UpdateOrderResponse.class);
    }

    public class UpdateOrderRequest {
        public req_OrderWrapper Order;

        public UpdateOrderRequest() {
            Order = new req_OrderWrapper();
        }
    }

    public class UpdateOrderResponse {
        public String OrderNo;
        public String EnterpriseCode;
        public res_OrderLinesWrapper OrderLines;
        public String MaxOrderStatusDesc;
        public String DocumentType;
        public res_NotesWrapper Notes;
    }

    public class req_OrderWrapper {
        public String Action;
        public String OrderNo;
        public String EnterpriseCode;
        public String DocumentType;
        public String ModificationReasonCode;
        public String ModificationReasonText;
        public req_OrderLinesWrapper OrderLines;
        public req_NotesWrapper Notes;
        public req_OrderHoldTypesWrapper OrderHoldTypes;

        public req_OrderWrapper() {
            OrderLines = new req_OrderLinesWrapper();
            Notes = new req_NotesWrapper();
        }
    }

    public class req_OrderLinesWrapper {
        public req_OrderLineWrapper OrderLine;

        public req_OrderLinesWrapper() {
            OrderLine = new req_OrderLineWrapper();
        }
    }

    public class req_OrderLineWrapper {
        public String Action;
        public String PrimeLineNo;
        public String SubLineNo;
        public req_NotesWrapper Notes;

        public req_OrderLineWrapper() {
            Notes = new req_NotesWrapper();
        }
    }

    public class req_NotesWrapper {
        public req_NoteWrapper Note;

        public req_NotesWrapper() {
            Note = new req_NoteWrapper();
        }
    }

    public class req_NoteWrapper {
        public String NoteText;
        public String ContactUser;
    }

    public class req_OrderHoldTypesWrapper {
        public req_OrderHoldTypeWrapper OrderHoldType;
    }

    public class req_OrderHoldTypeWrapper {
        public String HoldType;
        public String Status;
        public String ReasonText;
    }

    public class res_OrderLinesWrapper {
        public List<res_OrderLineWrapper> OrderLine;
    }

    public class res_OrderLineWrapper {
        public res_NotesWrapper Notes;
        public String PrimeLineNo;
        public String MaxLineStatusDesc;
        public res_ItemWrapper Item;
        public String OrderedQty;
    }

    public class res_NotesWrapper {
        public String NumberOfNotes;
    }

    public class res_ItemWrapper {
        public String ItemID;
        public String UnitOfMeasure;
    }
}