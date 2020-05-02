/**
 *  @description Cancel Order web service class
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        7/15/2019
 */
public with sharing class trac_WS_CancelOrder {

    public final String ENDPOINT = (trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c != null) ?
            trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.Cancel_Order_Endpoint__c : trac_WS_WebServiceHelper.webServiceSettings.Cancel_Order_Endpoint__c;
    private HttpResponse res = new HttpResponse();
    public CancelOrderRequest cancelOrderRequest;
    public CancelOrderResponse cancelOrderResponse;
    public String jsonError;

    public trac_WS_CancelOrder() {
        cancelOrderRequest = new CancelOrderRequest();
    }

    public Boolean send() {
        Boolean success = false;

        res = trac_WS_WebServiceHelper.sendPostRequest(getEndpoint(), cancelOrderRequest);
        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            cancelOrderResponse = parse(res.getBody());
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

        if (cancelOrderRequest != null && cancelOrderRequest.Order != null) {

            String businessUnit = trac_WS_OrderUtils.getBusinessUnitFromEnterpriseCode(cancelOrderRequest.Order.EnterpriseCode);

            dynamicEndpoint = trac_WS_OrderUtils.getDynamicEndpoint(dynamicEndpoint, businessUnit);
        }

        return dynamicEndpoint;
    }

    public static CancelOrderResponse parse(String json) {
        return (CancelOrderResponse) System.JSON.deserialize(json, CancelOrderResponse.class);
    }

    public class CancelOrderRequest {
        public req_OrderWrapper Order;

        public CancelOrderRequest() {
            Order = new req_OrderWrapper();
        }
    }

    public class CancelOrderResponse {
        public res_NotesWrapper Notes;
        public String OrderNo;
        public String EnterpriseCode;
        public res_OrderLinesWrapper OrderLines;
        public String MaxOrderStatusDesc;
        public String DocumentType;
        public String ResponseCode;
        public String ResposneMessage;
    }

    public class req_OrderWrapper {
        public String Action;
        public String ModificationReasonCode;
        public String ModificationReasonText;
        public String OrderNo;
        public String EnterpriseCode;
        public String DocumentType;
        public req_OrderLinesWrapper OrderLines;

        public req_OrderWrapper() {
            OrderLines = new req_OrderLinesWrapper();
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
        public String OrderedQty;
        public String QuantityToCancel;
    }

    public class res_NotesWrapper {
        public String NumberOfNotes;
        public List<res_NoteWrapper> Note;
    }

    public class res_NoteWrapper {
        public String ContactUser;
        public String NoteText;
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

    public class res_ItemWrapper {
        public String ItemID;
        public String UnitOfMeasure;
    }
}