/**
 *  @description Apex Controller for Payment Capture and Add Payment Method lightning components
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        01/31/2020
 */
public without sharing class trac_PaymentCaptureCtlr {

    @AuraEnabled
    public static TLAuraResponse updatePaymentMethods(String enterpriseCode, String orderNumber, String paymentMethodJson) {
        TLAuraResponse response = new TLAuraResponse(true);

        trac_WS_OrderPayment orderPayment = new trac_WS_OrderPayment();

        try {
            List<trac_WS_OrderPayment.req_PaymentMethodWrapper> paymentMethodWrappers = (List<trac_WS_OrderPayment.req_PaymentMethodWrapper>) JSON.deserialize(paymentMethodJson, List<trac_WS_OrderPayment.req_PaymentMethodWrapper>.class);

            orderPayment.orderPaymentRequest.Order.OrderNo = orderNumber;
            orderPayment.orderPaymentRequest.Order.EnterpriseCode = enterpriseCode;
            orderPayment.orderPaymentRequest.Order.DocumentType = trac_WS_OrderUtils.getOrderType();
            orderPayment.orderPaymentRequest.Order.PaymentMethods.PaymentMethod = paymentMethodWrappers;
            Boolean success = orderPayment.send();

            if (success) {
                response.returnValuesMap.put('orderPaymentResponse', new OrderPaymentResponseAsserted(orderPayment.orderPaymentResponse));
            } else if (orderPayment.orderPaymentResponse != null && orderPayment.orderPaymentResponse != null && orderPayment.orderPaymentResponse.ResposneMessage != null) {
                response = new TLAuraResponse(false, orderPayment.orderPaymentResponse.ResposneMessage);
            } else {
                throw new trac_PaymentCaptureException(orderPayment.jsonError);
            }

        } catch (Exception e) {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = orderPayment.ENDPOINT,
                    Request__c = JSON.serializePretty(orderPayment.orderPaymentRequest),
                    Service__c = 'Order Payment'
            ));
            insert integrationError;
            response = new TLAuraResponse(false, e.getMessage() + '\n' + e.getStackTraceString());
        }

        return response;
    }

    @AuraEnabled
    public static TLAuraResponse tokenizeData(String dataToTokenize) {
        TLAuraResponse response = new TLAuraResponse(true);

        trac_WS_Tokenize tokenize = new trac_WS_Tokenize();

        try {
            tokenize.tokenizeRequest.APIKey = trac_WS_WebServiceHelper.webServiceSettings.Tokenex_API_Key__c;
            tokenize.tokenizeRequest.TokenExID = trac_WS_WebServiceHelper.webServiceSettings.Tokenex_ID__c;
            tokenize.tokenizeRequest.TokenScheme = Integer.valueOf(trac_WS_WebServiceHelper.webServiceSettings.Tokenex_Token_Scheme__c);
            tokenize.tokenizeRequest.Data = dataToTokenize;

            Boolean success = tokenize.send();
            if (success && tokenize.tokenizeResponse != null && tokenize.tokenizeResponse.Success) {
                response.returnValuesMap.put('token', tokenize.tokenizeResponse.Token);
            } else if (tokenize.tokenizeResponse != null && !tokenize.tokenizeResponse.Success) {
                response = new TLAuraResponse(false, tokenize.tokenizeResponse.Error);
            } else {
                throw new trac_PaymentCaptureException(tokenize.jsonError);
            }

        } catch (Exception e) {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = tokenize.ENDPOINT,
                    Request__c = JSON.serializePretty(tokenize.tokenizeRequest),
                    Service__c = 'Tokenize'
            ));
            insert integrationError;
            response = new TLAuraResponse(false, e.getMessage() + '\n' + e.getStackTraceString());
        }

        return response;
    }

    @AuraEnabled
    public static TLAuraResponse getGiftCardBalance(String enterpriseCode, String cardType, String giftCardJSON) {
        TLAuraResponse response = new TLAuraResponse(true);

        trac_WS_GiftCardBalance giftCardBalance = new trac_WS_GiftCardBalance();

        try {
            giftCardBalance.giftCardBalanceRequest.card = (trac_WS_GiftCardBalance.req_cardWrapper) JSON.deserialize(giftCardJSON, trac_WS_GiftCardBalance.req_cardWrapper.class);
            giftCardBalance.giftCardBalanceRequest.card.entry_mode = trac_WS_OrderUtils.getGiftCardEntryMode();
            giftCardBalance.giftCardBalanceRequest.card.type = trac_WS_OrderUtils.getGiftCardTypeFromOMSType(cardType);

            giftCardBalance.giftCardBalanceRequest.banner_code = enterpriseCode;
            giftCardBalance.giftCardBalanceRequest.store_number = trac_WS_OrderUtils.getGiftCardStoreCodeFromEnterpriseCode(enterpriseCode);

            System.debug('giftCardBalance: ' + giftCardBalance);

            Boolean success = giftCardBalance.send();

            System.debug('giftCardBalance After Send: ' + giftCardBalance);

            if (success && giftCardBalance.giftCardBalanceResponse != null && giftCardBalance.giftCardBalanceResponse.card != null && String.isNotBlank(giftCardBalance.giftCardBalanceResponse.card.funds_available)) {
                response.returnValuesMap.put('funds_available', giftCardBalance.giftCardBalanceResponse.card.funds_available);
            } else {
                if (giftCardBalance.giftCardBalanceResponse != null && giftCardBalance.giftCardBalanceResponse.response_message != null) {
                    response = new TLAuraResponse(false, giftCardBalance.giftCardBalanceResponse.response_message);
                } else {
                    throw new trac_PaymentCaptureException(giftCardBalance.jsonError);
                }
            }

        } catch (Exception e) {
            Integration_Error__c integrationError = trac_IntegrationError.addError(new Integration_Error__c(
                    Description__c = e.getMessage() + '\n' + e.getStackTraceString(),
                    Endpoint__c = giftCardBalance.ENDPOINT,
                    Request__c = JSON.serializePretty(giftCardBalance.giftCardBalanceRequest),
                    Service__c = 'Gift Card Balance'
            ));
            insert integrationError;
            response = new TLAuraResponse(false, e.getMessage() + '\n' + e.getStackTraceString());
        }

        return response;
    }

    public class trac_PaymentCaptureException extends Exception {}


    public class OrderPaymentResponseAsserted {
        @AuraEnabled public trac_WS_OrderPayment.orderPaymentResponse orderPayResponse;
        @AuraEnabled public Boolean isSuccess;

        public OrderPaymentResponseAsserted(trac_WS_OrderPayment.orderPaymentResponse orderPayResponse) {
            checkFraudResponse(orderPayResponse);
        }

        public void checkFraudResponse(trac_WS_OrderPayment.orderPaymentResponse orderPayResponse) {
            System.debug(orderPayResponse);
            if (orderPayResponse != null && orderPayResponse.FraudCheckResponseCode != 'SUCCESS') {
                if (orderPayResponse.PaymentMethods != null && orderPayResponse.PaymentMethods.PaymentMethod != null) {
                    for(Integer i = 0 ; i < orderPayResponse.PaymentMethods.PaymentMethod.size() ; i++) {
                        if (orderPayResponse.PaymentMethods.PaymentMethod[i].AuthReturnMessage == 'Approved' ||
                                orderPayResponse.PaymentMethods.PaymentMethod[i].AuthReturnMessage == 'Success') {
                            isSuccess = true;
                            this.orderPayResponse = orderPayResponse;
                        } else {
                            isSuccess = False;
                            this.orderPayResponse = orderPayResponse;
                        }
                    }
                }else{
                    isSuccess = False;
                    this.orderPayResponse = orderPayResponse;
                }

            } else if(orderPayResponse != null && orderPayResponse.FraudCheckResponseCode == 'SUCCESS') {
                isSuccess = true;
                this.orderPayResponse = orderPayResponse;
            }else{
                isSuccess = False;
                this.orderPayResponse = orderPayResponse;
            }
        }
    }

}