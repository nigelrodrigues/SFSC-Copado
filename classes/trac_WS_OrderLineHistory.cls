/**
 *  @description Order Line History web service class
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        1/27/2020
 */
public with sharing class trac_WS_OrderLineHistory {

    public final String ENDPOINT = (trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c != null) ?
            trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.Order_Line_History_Endpoint__c : trac_WS_WebServiceHelper.webServiceSettings.Order_Line_History_Endpoint__c;
    private HttpResponse res = new HttpResponse();
    public OrderLineHistoryRequest orderLineHistoryRequest;
    public OrderLineHistoryResponse orderLineHistoryResponse;
    public String jsonError;

    public trac_WS_OrderLineHistory() {
        orderLineHistoryRequest = new OrderLineHistoryRequest();
    }

    public Boolean send() {
        Boolean success = false;

        res = trac_WS_WebServiceHelper.sendPostRequest(getEndpoint(), orderLineHistoryRequest);
        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            orderLineHistoryResponse = parse(res.getBody());
            success = true;
        }
        else {
            jsonError = trac_WS_WebServiceHelper.getError(res);
        }
        return success;
    }

    public static OrderLineHistoryResponse parse(String json) {
        return (OrderLineHistoryResponse) System.JSON.deserialize(json, OrderLineHistoryResponse.class);
    }

    private String getEndpoint() {
        String dynamicEndpoint = ENDPOINT;

        if (orderLineHistoryRequest != null && orderLineHistoryRequest.Order != null) {

            String businessUnit = trac_WS_OrderUtils.getBusinessUnitFromEnterpriseCode(orderLineHistoryRequest.Order.EnterpriseCode);

            dynamicEndpoint = trac_WS_OrderUtils.getDynamicEndpoint(dynamicEndpoint, businessUnit);
        }

        return dynamicEndpoint;
    }

    public class OrderLineHistoryRequest {
        public req_OrderWrapper Order;

        public OrderLineHistoryRequest() {
            Order = new req_OrderWrapper();
        }
    }

    public class req_OrderWrapper {
        public req_OrderLinesWrapper OrderLines;
        public String OrderNo;
        public String EnterpriseCode;
        public String DocumentType;

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
        public String PrimeLineNo;
        public String SubLineNo;
    }

    public class OrderLineHistoryResponse {
        @AuraEnabled public List<res_LineStatusHistoryWrapper> LineStatusHistory;
    }
    public class res_LineStatusHistoryWrapper {
        @AuraEnabled public String OrderLineKey;
        @AuraEnabled public String PrimeLineNo;
        @AuraEnabled public String ReasonCode;
        @AuraEnabled public String ReasonDescription;
        @AuraEnabled public String Status;
        @AuraEnabled public String StatusDescription;
        @AuraEnabled public String StatusQuantity;
        @AuraEnabled public String SubLineNo;
        @AuraEnabled public String NodeDescription;
        @AuraEnabled public String NodeType;
        @AuraEnabled public String ShipNode;
    }

}