/**
 *  @description Tests for trac_PaymentCaptureCtlr
 *  @author      Adam Lowe, Traction on Demand.
 *  @date        04/26/2020
 */
@IsTest
private class trac_PaymentCaptureCtlrTest {

    private static final String ENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Base_Url__c + trac_WS_WebServiceHelper.webServiceSettings.OMS_Order_Payment_Endpoint__c;
    private static final String TOKENENDPOINT = trac_WS_WebServiceHelper.webServiceSettings.Tokenex_Endpoint__c;
    private static final String CREDITRESOURCE = 'trac_OrderPayment';
    private static final String CREDITFRAUDFAILEDCARDAPPROVEDRESOURCE = 'trac_PaymentCaptureCardAuth';
    private static final String CREDITFAILEDFRAUDRESOURCE = 'trac_OrderPaymentFailedFraud';
    private static final String CREDITFAILEDRESOURCE = 'trac_OrderPaymentFailed';
    private static final String CREDITEXCEPTIONRESOURCE = 'trac_OrderPaymentException';
    private static final String GIFTCARDRESOURCE = 'trac_GiftCardBalance';
    private static final String GIFTCARDFAILEDRESOURCE = 'trac_GiftCardBalanceFailed';
    private static final String TOKENIZERESOURCE = 'trac_Tokenize';
    private static final String TOKENIZEFAILEDRESOURCE = 'trac_TokenizeFailed';


    @IsTest static void test_updatePaymentMethod() {

        String paymentJson = '[{}]';

        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, CREDITRESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, myMock);

        TLAuraResponse response = trac_PaymentCaptureCtlr.updatePaymentMethods('Off 5th', '3000030334', paymentJson);
        Test.stopTest();

        trac_PaymentCaptureCtlr.OrderPaymentResponseAsserted responseValues =  (trac_PaymentCaptureCtlr.OrderPaymentResponseAsserted) response.returnValuesMap.get('orderPaymentResponse');

        /* Assertions */
        System.assertEquals(true, response.isSuccess);
        System.assertEquals(true, responseValues.isSuccess);
        System.assertEquals('OFF5', responseValues.orderPayResponse.EnterpriseCode);
        System.assertEquals('0001', responseValues.orderPayResponse.DocumentType);
        System.assertEquals('3000030334', responseValues.orderPayResponse.OrderNo);
        System.assertEquals('SUCCESS', responseValues.orderPayResponse.FraudCheckResponseCode);
        System.assertNotEquals(null, responseValues.orderPayResponse.PaymentMethods);

    }

    @IsTest static void test_updatePaymentMethodFraudFailedNoCard() {

        String paymentJson = '[{}]';

        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, CREDITFAILEDFRAUDRESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, myMock);

        TLAuraResponse response = trac_PaymentCaptureCtlr.updatePaymentMethods('Off 5th', '3000030334', paymentJson);
        Test.stopTest();

        trac_PaymentCaptureCtlr.OrderPaymentResponseAsserted responseValues =  (trac_PaymentCaptureCtlr.OrderPaymentResponseAsserted) response.returnValuesMap.get('orderPaymentResponse');

        /* Assertions */
        System.assertEquals(true, response.isSuccess); // Valid POST call
        System.assertEquals(false, responseValues.isSuccess); // Data validation failed
        System.assertEquals('Order is not on Credit Hold', responseValues.orderPayResponse.FraudCheckResponseCode);
        System.assertEquals('1', responseValues.orderPayResponse.ResponseCode);
        System.assertEquals('Payment info failed fraud check, no card info', responseValues.orderPayResponse.ResposneMessage);
    }

    @IsTest static void test_updatePaymentMethodFraudFailedCardApproved() {

        String paymentJson = '[{}]';

        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, CREDITFRAUDFAILEDCARDAPPROVEDRESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, myMock);

        TLAuraResponse response = trac_PaymentCaptureCtlr.updatePaymentMethods('Off 5th', '3000030334', paymentJson);
        Test.stopTest();

        trac_PaymentCaptureCtlr.OrderPaymentResponseAsserted responseValues =  (trac_PaymentCaptureCtlr.OrderPaymentResponseAsserted) response.returnValuesMap.get('orderPaymentResponse');

        /* Assertions */
        System.assertEquals(true, response.isSuccess); // Valid POST call
        System.assertEquals(true, responseValues.isSuccess); // Data validation failed
        System.assertEquals('Order is not on Credit Hold', responseValues.orderPayResponse.FraudCheckResponseCode);
        System.assertEquals('1', responseValues.orderPayResponse.ResponseCode);
        System.assertEquals('Card approved but failed fraud check', responseValues.orderPayResponse.ResposneMessage);
    }

    @IsTest static void test_updatePaymentMethodFailed() {

        String paymentJson = '[{}]';

        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, CREDITFAILEDRESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, myMock);

        TLAuraResponse response = trac_PaymentCaptureCtlr.updatePaymentMethods('Off 5th', '3000030334', paymentJson);
        Test.stopTest();

        trac_PaymentCaptureCtlr.OrderPaymentResponseAsserted responseValues =  (trac_PaymentCaptureCtlr.OrderPaymentResponseAsserted) response.returnValuesMap.get('orderPaymentResponse');

        /* Assertions */
        System.assertEquals(true, response.isSuccess); // Valid POST call
        System.assertEquals(false, responseValues.isSuccess); // Data validation failed
        System.assertEquals('Order is not on Credit Hold', responseValues.orderPayResponse.FraudCheckResponseCode);
        System.assertEquals('1', responseValues.orderPayResponse.ResponseCode);
        System.assertEquals('Payment info failed fraud check, card authentication failure', responseValues.orderPayResponse.ResposneMessage);
    }

    @IsTest static void test_updatePaymentMethod404() {

        String paymentJson = '[{}]';

        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, CREDITFAILEDRESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        myMock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, myMock);

        TLAuraResponse response = trac_PaymentCaptureCtlr.updatePaymentMethods('Off 5th', '3000030334', paymentJson);
        Test.stopTest();

        System.debug(response);

        /* Assertions */
        System.assertEquals(false, response.isSuccess);
    }

    @IsTest static void test_updatePaymentMethodException() {

        String paymentJson = '[{}]';

        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, CREDITEXCEPTIONRESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        myMock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, myMock);

        TLAuraResponse response = trac_PaymentCaptureCtlr.updatePaymentMethods('Off 5th', '3000030334', paymentJson);
        Test.stopTest();

        Integer insertedRows = [SELECT COUNT() FROM Integration_Error__c WHERE Service__c = 'Order Payment'];

        /* Assertions */
        System.assertEquals(false, response.isSuccess);
        System.assert(insertedRows > 0);
    }

    @IsTest static void test_getGiftCardBalance() {

        String giftCardJson = '{}';

        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, GIFTCARDRESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, myMock);

        TLAuraResponse response = trac_PaymentCaptureCtlr.getGiftCardBalance('Off 5th', 'GIFT_CARD', giftCardJson);
        Test.stopTest();

        /* Assertions */
        System.assertEquals(true, response.isSuccess);
        System.assertEquals('0.00', response.returnValuesMap.get('funds_available'));

    }

    @IsTest static void test_getGiftCardBalanceFailed() {

        String giftCardJson = '{}';

        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, GIFTCARDFAILEDRESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        myMock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, myMock);

        TLAuraResponse response = trac_PaymentCaptureCtlr.getGiftCardBalance('Off 5th', 'GIFT_CARD', giftCardJson);
        Test.stopTest();

        /* Assertions */
        System.assertEquals(false, response.isSuccess);
        System.assertEquals('Error', response.message);

    }

    @IsTest static void test_getGiftCardBalanceException() {

        String giftCardJson = '{}';

        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(ENDPOINT, CREDITEXCEPTIONRESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        myMock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, myMock);

        TLAuraResponse response = trac_PaymentCaptureCtlr.getGiftCardBalance('Off 5th', 'GIFT_CARD', giftCardJson);
        Test.stopTest();

        Integer insertedRows = [SELECT COUNT() FROM Integration_Error__c WHERE Service__c = 'Gift Card Balance'];

        /* Assertions */
        System.assertEquals(false, response.isSuccess);
        System.assert(insertedRows > 0);

    }

    @IsTest static void test_tokenizeData() {

        String tokenizeJson = '11111111111111111';

        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(TOKENENDPOINT, TOKENIZERESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, myMock);

        TLAuraResponse response = trac_PaymentCaptureCtlr.tokenizeData(tokenizeJson);
        Test.stopTest();

        String tokenValue =  (String) response.returnValuesMap.get('token');

        /* Assertions */
        System.assertEquals(true, response.isSuccess);
        System.assertEquals('4111117872681111', tokenValue);

    }

    @IsTest static void test_tokenizeDataFailed() {

        String tokenizeJson = '11111111111111111';

        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(TOKENENDPOINT, TOKENIZEFAILEDRESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, myMock);

        TLAuraResponse response = trac_PaymentCaptureCtlr.tokenizeData(tokenizeJson);
        Test.stopTest();

        /* Assertions */
        System.assertEquals(false, response.isSuccess);
        System.assertEquals('Tokenize Failed', response.message);

    }

    @IsTest static void test_tokenizeDataException() {

        String tokenizeJson = '11111111111111111';

        Test.startTest();
        MultiStaticResourceCalloutMock myMock = new MultiStaticResourceCalloutMock ();
        myMock.setStaticResource(TOKENENDPOINT, CREDITEXCEPTIONRESOURCE);
        myMock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, myMock);

        TLAuraResponse response = trac_PaymentCaptureCtlr.tokenizeData(tokenizeJson);
        Test.stopTest();

        Integer insertedRows = [SELECT COUNT() FROM Integration_Error__c WHERE Service__c = 'Tokenize'];

        /* Assertions */
        System.assertEquals(false, response.isSuccess);
        System.assert(insertedRows > 0);

    }

}