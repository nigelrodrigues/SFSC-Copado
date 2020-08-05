/**
 *  @description Order Utilities Class, contains methods and default values for interacting with OMS API
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        07/04/2019
 */
public without sharing class trac_WS_OrderUtils {

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
    private static final String DEFAULT_GIFT_CARD_ENTRY_MODE = 'KEYED';
    private static final String CREATE_ACTION = 'CREATE';
    private static final String MODIFY_ACTION = 'MODIFY';
    private static final String CANCEL_ACTION = 'CANCEL';

    private static final Map<String, String> IPA_STORE_NUMBER_BY_ENTERPRISE_CODE = new Map<String, String>{
            'BAY'  => '1963',
            'OFF5' => '8669',
            'SAKS' => '7789'
    };

    private static final Map<String, String> IPA_CARD_TYPE_BY_OMS_TYPE = new Map<String, String>{
            'HBGC'               => 'HBGC',
            'LTGC'               => 'LTGC',
            'GIFT_CARD'          => 'EGC',
            'MERCHANDISE_CREDIT' => 'EMC',
            'VIRTUAL_GIFT_CARD'  => 'VGC'
    };

    private static Map<String, Map<String, Reference_Data__mdt>> referenceDataBySystemValueByType = trac_ReferenceData.getReferenceDataMappedByValueByType('OMS', 'System_Value__c');
    private static Map<String, Map<String, Reference_Data__mdt>> referenceDataBySalesforceValueByType = trac_ReferenceData.getReferenceDataMappedByValueByType('OMS', 'Salesforce_Value__c');

    public static void setCaseOrderInformation(Set<Id> caseIds) {
        if (System.isFuture() || System.isBatch()) {
            setCaseOrderInformationSync(caseIds);
        } else {
            setCaseOrderInformationAsync(caseIds);
        }
    }

    @Future(Callout=true)
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

    public static Map<String, Boolean> getOrderLineCancelabilityByStatus(String businessUnit) {
        Map<String,Boolean> retMap = new Map<String,Boolean>();
        Map<String,String> mapBannerToField = new Map<String,String>{
                'Hudson\'s Bay' => 'Banner_Hudson_s_Bay__c',
                'MHF' => 'Banner_MHF__c',
                'Lord + Taylor' => 'Banner_Lord_Taylor__c',
                'Saks' => 'Banner_Saks__c',
                'Off 5th' => 'Banner_Off_5th__c'
        };
        String bannerField = mapBannerToField.get(businessUnit);

        if (String.isEmpty(bannerField)) {
            // no match for business unit
            return retMap;
        }

        String query = 'SELECT Order_Line_Status__c, Banner_Hudson_s_Bay__c, Banner_Lord_Taylor__c, ' +
                            'Banner_MHF__c, Banner_Off_5th__c, Banner_Saks__c, Can_Be_Cancelled__c ' +
                        'FROM Order_Line_Status_Setting__mdt ' +
                        'WHERE ' + bannerField + ' = TRUE ';
        List<Order_Line_Status_Setting__mdt> settings = Database.query(query);
        for (Order_Line_Status_Setting__mdt setting : settings) {
            retMap.put(setting.Order_Line_Status__c, setting.Can_Be_Cancelled__c);
        }

        return retMap;
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

    public static String getBusinessUnitFromEnterpriseCode(String enterpriseCode) {
        String businessUnit;

        if (referenceDataBySalesforceValueByType.containsKey('Enterprise Code')) {
            Map<String, Reference_Data__mdt> referenceDataByValue = referenceDataBySystemValueByType.get('Enterprise Code');

            if (referenceDataByValue.containsKey(enterpriseCode)) {
                businessUnit = referenceDataByValue.get(enterpriseCode).Salesforce_Value__c;
            }
        }

        return businessUnit;
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

    public static String getDynamicEndpoint(String endpoint, String businessUnit) {
        String dynamicEndpoint = endpoint;

        if (businessUnit != null && dynamicEndpoint != null) {
            List<API_Business_Unit_Version_Setting__mdt> apiBusinessUnitVersionSettings = [SELECT Business_Unit__c, OMS_API_Version__c FROM API_Business_Unit_Version_Setting__mdt WHERE Business_Unit__c = :businessUnit];

            if (!apiBusinessUnitVersionSettings.isEmpty() && apiBusinessUnitVersionSettings[0].OMS_API_Version__c != null) {
                dynamicEndpoint = dynamicEndpoint.replace('/orders', apiBusinessUnitVersionSettings[0].OMS_API_Version__c);
            }
        }

        return dynamicEndpoint;
    }

    public static String getGiftCardStoreCodeFromEnterpriseCode(String enterpriseCode) {
        String storeCode;

        if (IPA_STORE_NUMBER_BY_ENTERPRISE_CODE.containsKey(enterpriseCode)) {
            storeCode = IPA_STORE_NUMBER_BY_ENTERPRISE_CODE.get(enterpriseCode);
        }

        return storeCode;
    }

    public static String getGiftCardTypeFromOMSType(String omsCardType) {
        String giftCardType;

        if (IPA_CARD_TYPE_BY_OMS_TYPE.containsKey(omsCardType)) {
            giftCardType = IPA_CARD_TYPE_BY_OMS_TYPE.get(omsCardType);
        }

        return giftCardType;
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

    public static String getGiftCardEntryMode() {
        return DEFAULT_GIFT_CARD_ENTRY_MODE;
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