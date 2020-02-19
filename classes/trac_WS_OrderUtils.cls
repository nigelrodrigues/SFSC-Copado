/**
 * Created by jhoran on 7/4/2019.
 */

public with sharing class trac_WS_OrderUtils {

    private static final String DEFAULT_ENTERPRISE_CODE = 'BAY';
    private static final String DEFAULT_ORDER_TYPE = '0001';
    private static final String DEFAULT_ENTRY_TYPE = 'Online';
    private static final String DEFAULT_NEW_ORDER_ENTRY_TYPE = 'Call Center';
    private static final String DEFAULT_LATEST_FIRST = 'Y';
    private static final String DEFAULT_READ_FROM_HISTORY = 'B';
    private static final String DEFAULT_DRAFT_FLAG = 'N';
    private static final String DEFAULT_MAX_RECORDS = '25';
    private static final String DEFAULT_SUB_LINE_NUMBER = '1';
    private static final String DEFAULT_MODIFICATION_CODE = 'HBC_MC_CC_005';
    private static final String CREATE_ACTION = 'CREATE';
    private static final String MODIFY_ACTION = 'MODIFY';
    private static final String CANCEL_ACTION = 'CANCEL';

    private static Map<String, Map<String, Reference_Data__mdt>> referenceDataBySystemValueByType = trac_ReferenceData.getReferenceDataMappedByValueByType('OMS', 'System_Value__c');
    private static Map<String, Map<String, Reference_Data__mdt>> referenceDataBySalesforceValueByType = trac_ReferenceData.getReferenceDataMappedByValueByType('OMS', 'Salesforce_Value__c');

    public static void setCaseOrderInformation(Set<Id> caseIds) {
        if (System.isFuture() || System.isBatch()) {
            setCaseOrderInformationSync(caseIds);
        } else {
            setCaseOrderInformationAsync(caseIds);
        }
    }

    @Future(callout=true)
    private static void setCaseOrderInformationAsync(Set<Id> caseIds) {
        setCaseOrderInformationSync(caseIds);
    }

    private static void setCaseOrderInformationSync(Set<Id> caseIds) {
        List<Case> casesToUpdate = new List<Case>();

        List<Case> cases = getCasesByIds(caseIds);

        for (Case aCase : cases) {
            Case updatedCase = getUpdatedCaseWithOrderInfo(aCase);
            if (updatedCase != null) {
                updatedCase.Id = aCase.Id;
                casesToUpdate.add(updatedCase);
            }
        }

        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }

    private static Case getUpdatedCaseWithOrderInfo(Case aCase) {
        Case updatedCase;

        if (aCase.Business_Unit__c != null && aCase.Order_Number__c != null) {
            trac_WS_GetOrderDetails.GetOrderDetailsResponse getOrderDetailsResponse = getOrderDetailsResponseFromOrderNumber(aCase.Business_Unit__c, aCase.Order_Number__c);

            if (getOrderDetailsResponse != null) {
                updatedCase = getCaseFromOrderDetailsResponse(getOrderDetailsResponse);
            }
        }

        return updatedCase;
    }

    private static Case getCaseFromOrderDetailsResponse(trac_WS_GetOrderDetails.GetOrderDetailsResponse getOrderDetailsResponse) {
        Case caseWithOrderDetails;

        if (getOrderDetailsResponse != null) {
            caseWithOrderDetails = new Case();

            if (getOrderDetailsResponse.OrderDate != null) {
                caseWithOrderDetails.Order_Date__c = getDateFromString(getOrderDetailsResponse.OrderDate);
            }

            if (getOrderDetailsResponse.PaymentMethods != null && getOrderDetailsResponse.PaymentMethods.PaymentMethod != null && !getOrderDetailsResponse.PaymentMethods.PaymentMethod.isEmpty()) {
                caseWithOrderDetails.Payment_Method__c = getOrderDetailsResponse.PaymentMethods.PaymentMethod[0].PaymentType;
            }

            if (getOrderDetailsResponse.OrderLines != null) {
                caseWithOrderDetails.Delivery_Method__c = getDeliveryMethodFromOrderResponse(getOrderDetailsResponse);
            }

            if (getOrderDetailsResponse.PriceInfo != null && getOrderDetailsResponse.PriceInfo.TotalAmount != null) {
                caseWithOrderDetails.Order_Revenue__c = Decimal.valueOf(getOrderDetailsResponse.PriceInfo.TotalAmount);
            }

            if (getOrderDetailsResponse.PersonInfoBillTo != null && getOrderDetailsResponse.PersonInfoBillTo.ZipCode != null) {
                caseWithOrderDetails.Order_Billing_Postal_Code__c = getOrderDetailsResponse.PersonInfoBillTo.ZipCode;
            }
        }

        return caseWithOrderDetails;
    }

    public static trac_WS_GetOrderDetails.GetOrderDetailsResponse getOrderDetailsResponseFromOrderNumber(String businessUnit, String orderNumber) {
        trac_WS_GetOrderDetails orderDetails = new trac_WS_GetOrderDetails();

        trac_WS_GetOrderDetails.req_OrderWrapper reqWrapper = new trac_WS_GetOrderDetails.req_OrderWrapper();
        reqWrapper.EnterpriseCode = trac_WS_OrderUtils.getEnterpriseCodeFromBusinessUnit(businessUnit);
        reqWrapper.DocumentType = trac_WS_OrderUtils.getOrderType();
        reqWrapper.OrderNo = orderNumber;

        trac_WS_GetOrderDetails.GetOrderDetailsRequest req = new trac_WS_GetOrderDetails.GetOrderDetailsRequest();
        req.Order = reqWrapper;

        orderDetails.getOrderDetailsRequest = req;

        orderDetails.send();
        return orderDetails.getOrderDetailsResponse;
    }

    private static String getDeliveryMethodFromOrderResponse(trac_WS_GetOrderDetails.GetOrderDetailsResponse getOrderDetailsResponse) {
        String deliveryMethod;

        if (getOrderDetailsResponse != null && getOrderDetailsResponse.OrderLines != null && getOrderDetailsResponse.OrderLines.OrderLine != null && !getOrderDetailsResponse.OrderLines.OrderLine.isEmpty()) {

            for (trac_WS_GetOrderDetails.res_OrderLineWrapper orderLineWrapper : getOrderDetailsResponse.OrderLines.OrderLine) {

                if (orderLineWrapper.SCAC != null) {

                    if (deliveryMethod == null) {
                        deliveryMethod = orderLineWrapper.SCAC;
                    }

                    if (deliveryMethod != orderLineWrapper.SCAC) {
                        deliveryMethod = null;
                        break;
                    }
                }
            }
        }

        return deliveryMethod;
    }

    public static String getEnterpriseCodeFromBusinessUnit(String businessUnit) {
        String enterpriseCode;

        if (referenceDataBySalesforceValueByType.containsKey('Enterprise Code')) {
            Map<String, Reference_Data__mdt> referenceDataByValue = referenceDataBySalesforceValueByType.get('Enterprise Code');

            if (referenceDataByValue.containsKey(businessUnit)) {
                enterpriseCode = referenceDataByValue.get(businessUnit).System_Value__c;
            }
        }

        if (enterpriseCode == null) {
            enterpriseCode = DEFAULT_ENTERPRISE_CODE;
        }

        return enterpriseCode;
    }

    public static String getFormattedDatetime(Datetime datetimeValue) {
        String datetimeString;

        if (datetimeValue != null) {
            datetimeString = datetimeValue.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        }

        return datetimeString;
    }

    public static Date getDateFromString(String dateString) {
        Date dateValue;

        if (dateString != null) {
            try {
                dateValue = Date.valueOf(dateString);
            } catch (Exception e) {

            }
        }

        return dateValue;
    }

    public static String getOrderType() {
        return DEFAULT_ORDER_TYPE;
    }

    public static String getEntryType() {
        return DEFAULT_ENTRY_TYPE;
    }

    public static String getNewOrderEntryType() {
        return DEFAULT_NEW_ORDER_ENTRY_TYPE;
    }

    public static String getLatestFirst() {
        return DEFAULT_LATEST_FIRST;
    }

    public static String getReadFromHistory() {
        return DEFAULT_READ_FROM_HISTORY;
    }

    public static String getDraftOrderFlag() {
        return DEFAULT_DRAFT_FLAG;
    }

    public static String getMaximumRecords() {
        return DEFAULT_MAX_RECORDS;
    }

    public static String getCreateAction() {
        return CREATE_ACTION;
    }

    public static String getModifyAction() {
        return MODIFY_ACTION;
    }

    public static String getCancelAction() {
        return CANCEL_ACTION;
    }

    public static String getModificationCode() {
        return DEFAULT_MODIFICATION_CODE;
    }

    public static String getSubLineNumber() {
        return DEFAULT_SUB_LINE_NUMBER;
    }

    private static List<Case> getCasesByIds(Set<Id> caseIds) {
        List<Case> cases = [
                SELECT Id, Business_Unit__c, Order_Number__c
                FROM Case
                WHERE Id IN :caseIds
        ];
        return cases;
    }
}