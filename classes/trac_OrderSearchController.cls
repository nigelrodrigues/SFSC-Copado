/**
 * @description Apex controller for trac_OrderSearch lightning component
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-06-26
 */
public with sharing class trac_OrderSearchController {

    @AuraEnabled
    public static TLAuraResponse getOrderDetails(String businessUnit, String orderNo) {
        TLAuraResponse response = new TLAuraResponse(true);

        trac_WS_GetOrderDetails orderDetails = new trac_WS_GetOrderDetails();

        try {
            trac_WS_GetOrderDetails.req_OrderWrapper reqWrapper = new trac_WS_GetOrderDetails.req_OrderWrapper();
            reqWrapper.EnterpriseCode = trac_WS_OrderUtils.getEnterpriseCodeFromBusinessUnit(businessUnit);
            reqWrapper.DocumentType = trac_WS_OrderUtils.getOrderType();
            reqWrapper.IsTrackURLReq = 'Y';
            reqWrapper.OrderNo = orderNo;

            trac_WS_GetOrderDetails.GetOrderDetailsRequest req = new trac_WS_GetOrderDetails.GetOrderDetailsRequest();
            req.Order = reqWrapper;

            orderDetails.getOrderDetailsRequest = req;

            orderDetails.send();

            if (orderDetails.jsonError != null) {
                //throw new OrderSearchException(orderDetails.jsonError);
            }

            response.returnValuesMap.put('orderDetails', orderDetails.getOrderDetailsResponse);
        } catch (Exception e) {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = orderDetails.ENDPOINT,
                    Request__c = JSON.serializePretty(orderDetails.getOrderDetailsRequest),
                    Service__c = 'Order Details'
            ));
            insert integrationError;

            String errorMessage = trac_WS_WebServiceHelper.DEFAULT_ERROR + integrationError.Id;

            response = new TLAuraResponse(false, errorMessage);
        }

        return response;
    }

    @AuraEnabled
    public static TLAuraResponse getOrderList(String businessUnit, String email) {

        TLAuraResponse response = new TLAuraResponse(true);

        trac_WS_GetOrderList orderList = new trac_WS_GetOrderList();
        trac_WS_GetOrderList.req_OrderWrapper reqWrapper = new trac_WS_GetOrderList.req_OrderWrapper();

        try {
            reqWrapper.EnterpriseCode = trac_WS_OrderUtils.getEnterpriseCodeFromBusinessUnit(businessUnit);
            reqWrapper.BillToID = email;

            trac_WS_GetOrderList.GetOrderListResponse res = callGetOrderList(reqWrapper);
            response.returnValuesMap.put('orderList',res);

        } catch (Exception e) {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = orderList.ENDPOINT,
                    Request__c = JSON.serializePretty(reqWrapper),
                    Service__c = 'Order List'
            ));
            insert integrationError;

            String errorMessage = trac_WS_WebServiceHelper.DEFAULT_ERROR + integrationError.Id;

            response = new TLAuraResponse(false, errorMessage);
        }

        return response;
    }

    @AuraEnabled
    public static TLAuraResponse getOrderListAdv(String businessUnit, String email,
            String phone, String archivedOrder, String draftOrder, String creditCard, String upc, String giftCard,
            String fromOrderDate, String toOrderDate) {


        TLAuraResponse response = new TLAuraResponse(true);

        trac_WS_GetOrderList orderList = new trac_WS_GetOrderList();
        trac_WS_GetOrderList.req_OrderWrapper reqWrapper = new trac_WS_GetOrderList.req_OrderWrapper();

        try {
            trac_WS_GetOrderList.req_PaymentMethodWrapper pymtWrapper = new trac_WS_GetOrderList.req_PaymentMethodWrapper();
            pymtWrapper.DisplayCreditCardNo = creditCard;

            trac_WS_GetOrderList.req_OrderLineWrapper orderLineWrapper = new trac_WS_GetOrderList.req_OrderLineWrapper();
            trac_WS_GetOrderList.req_ItemDetailsWrapper itemDetailsWrapper = new trac_WS_GetOrderList.req_ItemDetailsWrapper();
            trac_WS_GetOrderList.req_ItemAliasListWrapper itemAliasListWrapper = new trac_WS_GetOrderList.req_ItemAliasListWrapper();
            trac_WS_GetOrderList.req_ItemAliasWrapper itemAliasWrapper = new trac_WS_GetOrderList.req_ItemAliasWrapper();

            itemAliasWrapper.AliasValue = upc;
            itemAliasListWrapper.ItemAlias = itemAliasWrapper;
            itemDetailsWrapper.ItemAliasList = itemAliasListWrapper;
            orderLineWrapper.ItemDetails = itemDetailsWrapper;

            reqWrapper.EnterpriseCode = trac_WS_OrderUtils.getEnterpriseCodeFromBusinessUnit(businessUnit);
            reqWrapper.BillToID = email;
            reqWrapper.CustomerPhoneNo = phone;
            reqWrapper.FromOrderDate = fromOrderDate;
            reqWrapper.ToOrderDate = toOrderDate;
            reqWrapper.ReadFromHistory = archivedOrder;
            reqWrapper.DraftOrderFlag = draftOrder;
            reqWrapper.PaymentMethod = pymtWrapper;
            reqWrapper.OrderLine = orderLineWrapper;
            reqWrapper.PaymentMethod.SvcNo = giftCard;

            trac_WS_GetOrderList.GetOrderListResponse res = callGetOrderList(reqWrapper);
            response.returnValuesMap.put('orderList',res);

        } catch (Exception e) {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = orderList.ENDPOINT,
                    Request__c = JSON.serializePretty(reqWrapper),
                    Service__c = 'Order List'
            ));
            insert integrationError;

            String errorMessage = trac_WS_WebServiceHelper.DEFAULT_ERROR + integrationError.Id;

            response = new TLAuraResponse(false, errorMessage);
        }

        return response;
    }

    private static trac_WS_GetOrderList.GetOrderListResponse callGetOrderList(trac_WS_GetOrderList.req_OrderWrapper reqWrapper) {
        trac_WS_GetOrderList orderList = new trac_WS_GetOrderList();

        reqWrapper.DocumentType = trac_WS_OrderUtils.getOrderType();
        reqWrapper.ReadFromHistory = trac_WS_OrderUtils.getReadFromHistory();
        reqWrapper.EntryType = trac_WS_OrderUtils.getEntryType();
        reqWrapper.LatestFirst = trac_WS_OrderUtils.getLatestFirst();
        reqWrapper.MaximumRecords = trac_WS_OrderUtils.getMaximumRecords();
        reqWrapper.DraftOrderFlag = trac_WS_OrderUtils.getDraftOrderFlag();

        trac_WS_GetOrderList.GetOrderListRequest req = new trac_WS_GetOrderList.GetOrderListRequest();
        req.Order = reqWrapper;

        orderList.getOrderListRequest = req;

        orderList.send();

        if (orderList.jsonError != null) {
            throw new OrderSearchException(orderList.jsonError);
        }

        return orderList.getOrderListResponse;
    }

    @AuraEnabled
    public static List <String> getselectOptions(SObject objObject, String fld) {
        List <String> allOpts = new List<String> ();
        Schema.SObjectType objType = objObject.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();

        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();

        List<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPicklistValues();

        for (Schema.PicklistEntry a : values) {
            allOpts.add(a.getValue());
        }
        allOpts.sort();
        return allOpts;
    }

    @AuraEnabled
    public static void updateCase(Id caseId, String orderNo) {
        Case cs = new Case(Id = caseId, Order_Number__c = orderNo);
        update cs;
    }

    public class OrderSearchException extends Exception {}
}