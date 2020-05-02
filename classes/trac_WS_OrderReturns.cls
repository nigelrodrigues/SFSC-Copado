/**
 *  @description Return Fee Waiving web service class
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        3/17/2020
 */
public without sharing class trac_WS_OrderReturns {

    public final String ENDPOINT = (trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c != null) ?
            trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.Cancel_Order_Endpoint__c : trac_WS_WebServiceHelper.webServiceSettings.Cancel_Order_Endpoint__c;

    private HttpResponse res = new HttpResponse();
    public OrderReturnsRequest orderReturnsRequest;
    public OrderReturnsResponse orderReturnsResponse;
    public String jsonError;

    public trac_WS_OrderReturns() {
        orderReturnsRequest = new OrderReturnsRequest();
    }

    public Boolean send() {
        res = trac_WS_WebServiceHelper.sendPostRequest(getEndpoint(), orderReturnsRequest);
        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            orderReturnsResponse = parse(res.getBody());
            return true;
        }
        else {
            jsonError = trac_WS_WebServiceHelper.getError(res);
            System.debug('Error: ' + trac_WS_WebServiceHelper.getError(res));
        }
        return false;
    }

    public static OrderReturnsResponse parse(String json) {
        return (OrderReturnsResponse) System.JSON.deserialize(json, OrderReturnsResponse.class);
    }

    private String getEndpoint() {
        String dynamicEndpoint = ENDPOINT;

        if (orderReturnsRequest != null && orderReturnsRequest.Order != null) {

            String businessUnit = trac_WS_OrderUtils.getBusinessUnitFromEnterpriseCode(orderReturnsRequest.Order.EnterpriseCode);

            dynamicEndpoint = trac_WS_OrderUtils.getDynamicEndpoint(dynamicEndpoint, businessUnit);
        }

        return dynamicEndpoint;
    }

    public class OrderReturnsRequest {
        public req_OrderWrapper Order;

        public OrderReturnsRequest() {
            Order = new req_OrderWrapper();
        }
    }

    public class req_OrderWrapper {
        public req_NotesWrapper Notes;
        public req_ExtnWrapper Extn;
        public String OrderNo;
        public String DocumentType;
        public String EnterpriseCode;

        public req_OrderWrapper() {
            Notes = new req_NotesWrapper();
            Extn = new req_ExtnWrapper();
        }
    }

    public class req_NotesWrapper {
        public req_NoteWrapper Note;

        public req_NotesWrapper() {
            Note = new req_NoteWrapper();
        }
    }

    public class req_NoteWrapper {
        public String ContactReference;
        public String ContactType;
        public String NoteText;
        public String ReasonCode;
    }

    public class req_ExtnWrapper {
        public String ExtnChargeShippingLabel;
        public String ExtnRefundShippingCharge;
    }

    public class OrderReturnsResponse {
        public res_OrderWrapper Order;
    }

    public class res_OrderWrapper {
        public String DocumentType;
        public String EnterpriseCode;
        public String MaxOrderStatusDesc;
        public String OrderNo;
        public res_OrderLinesWrapper OrderLines;
        public res_NotesWrapper Notes;
    }

    public class res_OrderLinesWrapper {
        public res_OrderLineWrapper OrderLine;
    }

    public class res_OrderLineWrapper {
        public res_ItemWrapper Item;
        public res_NotesWrapper Notes;
        public String MaxLineStatusDesc;
        public String OrderedQty;
        public String PrimeLineNo;
    }

    public class res_ItemWrapper {
        public String ItemID;
        public String UnitOfMeasure;
    }

    public class res_NotesWrapper {
        public String NumberOfNotes;
    }

    public class res_NoteWrapper {
        public String ContactReference;
        public String ContactType;
        public String NoteText;
        public String ReasonCode;
    }
}