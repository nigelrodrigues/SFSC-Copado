/**
 *  @description API Class for updating order payments in OMS
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        2/26/2020
 */
public with sharing class trac_WS_OrderPayment {

    public final String ENDPOINT = (trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c != null) ?
            trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.OMS_Order_Payment_Endpoint__c : trac_WS_WebServiceHelper.webServiceSettings.OMS_Order_Payment_Endpoint__c;

    private HttpResponse res = new HttpResponse();

    public OrderPaymentRequest orderPaymentRequest;
    public OrderPaymentResponse orderPaymentResponse;
    public String jsonError;

    public trac_WS_OrderPayment() {
        orderPaymentRequest = new OrderPaymentRequest();
    }

    public Boolean send() {
        res = trac_WS_WebServiceHelper.sendPostRequest(getEndpoint(), orderPaymentRequest);
        if(trac_WS_WebServiceHelper.isValidResponse(res)) {
            orderPaymentResponse = parse(res.getBody());
            return true;
        }
        else {
            try {
                orderPaymentResponse = parse(res.getBody());
            } catch (Exception e) {}
            jsonError = trac_WS_WebServiceHelper.getError(res);
            System.debug('Error: ' + trac_WS_WebServiceHelper.getError(res));
        }
        return false;
    }
    public static OrderPaymentResponse parse(String json) {
        return (OrderPaymentResponse) System.JSON.deserialize(json, OrderPaymentResponse.class);
    }

    private String getEndpoint() {
        String dynamicEndpoint = ENDPOINT;

        if (orderPaymentRequest != null && orderPaymentRequest.Order != null) {

            String businessUnit = trac_WS_OrderUtils.getBusinessUnitFromEnterpriseCode(orderPaymentRequest.Order.EnterpriseCode);

            dynamicEndpoint = trac_WS_OrderUtils.getDynamicEndpoint(dynamicEndpoint, businessUnit);
        }

        return dynamicEndpoint;
    }

    public class OrderPaymentRequest {
        public req_OrderWrapper Order;

        public OrderPaymentRequest() {
            Order = new req_OrderWrapper();
        }
    }

    public class req_OrderWrapper {
        public String OrderNo;
        public String EnterpriseCode;
        public req_PaymentMethodsWrapper PaymentMethods;
        public String DocumentType;

        public req_OrderWrapper() {
            PaymentMethods = new req_PaymentMethodsWrapper();
        }
    }

    public class req_PaymentMethodsWrapper {
        public List<req_PaymentMethodWrapper> PaymentMethod;

        public req_PaymentMethodsWrapper() {
            PaymentMethod = new List<req_PaymentMethodWrapper>();
        }
    }

    public class req_PaymentMethodWrapper {
        public String ChargeType;
        public String PaymentType;
        public String MaxChargeLimit;
        public String CreditCardExpDate;
        public String RequestAmount;
        public String CreditCardType;
        public String CreditCardNo;
        public String SvcNo;
        public req_PersonInfoBillToWrapper PersonInfoBillTo;
        public String RequestedAuthAmount;
        public String DisplayCreditCardNo;
        public String TotalAuthorized;

        public req_PaymentMethodWrapper() {
            PersonInfoBillTo = new req_PersonInfoBillToWrapper();
        }
    }

    public class req_PersonInfoBillToWrapper {
        public String EMailID;
        public String MiddleName;
        public String State;
        public String FirstName;
        public String LastName;
        public String DayPhone;
        public String Country;
        public String ZipCode;
        public String AddressLine1;
        public String City;
        public String AddressLine2;
    }

    public class OrderPaymentResponse {
        @AuraEnabled public String OrderNo;
        @AuraEnabled public String EnterpriseCode;
        @AuraEnabled public String DocumentType;
        @AuraEnabled public String FraudCheckResponseCode;
        @AuraEnabled public FraudCheckResponseMessages FraudCheckResponseMessages;
        @AuraEnabled public String ResponseCode;
        @AuraEnabled public String ResposneMessage;
        @AuraEnabled public res_PaymentMethodsWrapper PaymentMethods;
    }

    public class FraudCheckResponseMessages {
        @AuraEnabled public List<FraudCheckResponseMessage> FraudCheckResponseMessage;
    }

    public class FraudCheckResponseMessage {
        @AuraEnabled public String Text;
    }

    public class res_PaymentMethodsWrapper {
        @AuraEnabled public List<res_PaymentMethodWrapper> PaymentMethod;
    }
    public class res_PaymentMethodWrapper {
        @AuraEnabled public String ChargeType;
        @AuraEnabled public String AuthorizationAmount;
        @AuraEnabled public String AuthReturnCode;
        @AuraEnabled public String AuthorizationID;
        @AuraEnabled public String PaymentType;
        @AuraEnabled public String AuthorizationExpirationDate;
        @AuraEnabled public String RequestAmount;
        @AuraEnabled public String CreditCardType;
        @AuraEnabled public String AuthReturnMessage;
        @AuraEnabled public String ResponseCode;
        @AuraEnabled public String CreditCardNo;
        @AuraEnabled public res_PersonInfoBillToWrapper PersonInfoBillTo;
        @AuraEnabled public String PaymentReference6;
    }
    public class res_PersonInfoBillToWrapper {
        @AuraEnabled public String EMailID;
        @AuraEnabled public String FirstName;
        @AuraEnabled public String LastName;
        @AuraEnabled public String DayPhone;
        @AuraEnabled public String ZipCode;
        @AuraEnabled public String AddressLine1;
        @AuraEnabled public String City;
    }
}