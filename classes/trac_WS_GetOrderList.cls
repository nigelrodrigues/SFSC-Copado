/**
 *  @description Get Order List web service class
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        6/25/2019
 */
public with sharing class trac_WS_GetOrderList {
    public final String ENDPOINT = (trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c != null) ?
            trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.Get_Order_List_Endpoint__c : trac_WS_WebServiceHelper.webServiceSettings.Get_Order_List_Endpoint__c;
    private HttpResponse res = new HttpResponse();
    public GetOrderListRequest getOrderListRequest;
    public GetOrderListResponse getOrderListResponse;
    public String jsonError;

    public Boolean send() {
        Boolean success = false;

        res = trac_WS_WebServiceHelper.sendPostRequest(getEndpoint(), getOrderListRequest);
        if (trac_WS_WebServiceHelper.isValidResponse(res)) {
            getOrderListResponse = parse(res.getBody());
            success = true;
        } else {
            jsonError = trac_WS_WebServiceHelper.getError(res);
            System.debug('Error: ' + trac_WS_WebServiceHelper.getError(res));
        }

        return success;
    }

    private String getEndpoint() {
        String dynamicEndpoint = ENDPOINT;

        if (getOrderListRequest != null && getOrderListRequest.Order != null) {

            String businessUnit = trac_WS_OrderUtils.getBusinessUnitFromEnterpriseCode(getOrderListRequest.Order.EnterpriseCode);

            dynamicEndpoint = trac_WS_OrderUtils.getDynamicEndpoint(dynamicEndpoint, businessUnit);
        }

        return dynamicEndpoint;
    }

    public static GetOrderListResponse parse(String json) {
        return (GetOrderListResponse) System.JSON.deserialize(json, GetOrderListResponse.class);
    }

    public class req_OrderWrapper {
        public String EntryType;
        public String LatestFirst;
        public String BillToID;
        public String ReadFromHistory;
        public String EnterpriseCode;
        public String DraftOrderFlag;
        public String DocumentType;
        public String MaximumRecords;
        public String FromOrderDate;
        public String ToOrderDate;
        public String CustomerPhoneNo;
        public req_PaymentMethodWrapper PaymentMethod;
        public req_OrderLineWrapper OrderLine;
        public String CustomerEMailID;
        public res_OverallTotalsWrapper OverallTotals;
    }

    public class req_OrderLineWrapper {
        public req_ItemDetailsWrapper ItemDetails;
    }
    public class req_ItemDetailsWrapper {
        public req_ItemAliasListWrapper ItemAliasList;
    }
    public class req_ItemAliasListWrapper {
        public req_ItemAliasWrapper ItemAlias;
    }
    public class req_ItemAliasWrapper {
        public String AliasValue;
    }

    public class req_PaymentMethodWrapper {
        public String DisplayCreditCardNo;
        public String SvcNo;
    }

    public class GetOrderListRequest {
        public req_OrderWrapper Order;
    }
    public class res_OrderWrapper {
        @AuraEnabled public String Status;
        @AuraEnabled public String OrderDate;
        @AuraEnabled public String BillToID;
        @AuraEnabled public res_PriceInfoWrapper PriceInfo;
        @AuraEnabled public String OrderNo;
        @AuraEnabled public String EnterpriseCode;
    }
    public class res_PriceInfoWrapper {
        @AuraEnabled public String TotalAmount;
    }
    public class GetOrderListResponse {
        @AuraEnabled public String LastOrderHeaderKey;
        @AuraEnabled public String ReadFromHistory;
        @AuraEnabled public List<res_OrderWrapper> Order;
        @AuraEnabled public String TotalOrderList;
        @AuraEnabled public String LastRecordSet;
    }
    public class res_OverallTotalsWrapper {
        @AuraEnabled public String SubtotalWithoutTaxes;
        @AuraEnabled public String GrandTax;
        @AuraEnabled public String LineSubTotal;
        @AuraEnabled public String GrandShippingTotal;
        @AuraEnabled public String GrandTotal;
    }
}