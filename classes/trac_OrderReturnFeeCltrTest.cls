/**
 * Created by nrodrigues on 4/28/2020.
 */

@IsTest
private class trac_OrderReturnFeeCltrTest {
    static final TLTestFactory factory = new TLTestFactory();

    @IsTest
    static void testUpdateOrderReturnFee() {
        Test.setMock(HttpCalloutMock.class, new MockOrderResponses('/ordereturn'));
        TLAuraResponse response  = trac_OrderReturnFeeCtlr.updateOrderReturnFee('SAKS', '123456', true , true);
        System.assertEquals(true, response.isSuccess);

        response  = trac_OrderReturnFeeCtlr.updateOrderReturnFee('SAKS', '123456', false , true);
        System.assertEquals(true, response.isSuccess);

        response  = trac_OrderReturnFeeCtlr.updateOrderReturnFee('SAKS', '123456', true , false);
        System.assertEquals(true, response.isSuccess);

        response  = trac_OrderReturnFeeCtlr.updateOrderReturnFee('SAKS', '123456', false , false);
        System.assertEquals(true, response.isSuccess);

    }

    @IsTest
    static void testUpdateOrderReturnFeeErrors() {
        Test.setMock(HttpCalloutMock.class, new MockOrderResponsesError('/ordereturn'));
        TLAuraResponse response  = trac_OrderReturnFeeCtlr.updateOrderReturnFee('SAKS', '123456', true , true);
        System.assertEquals(false, response.isSuccess);

        Integration_Error__c error = [SELECT Id, Service__c FROM Integration_Error__c LIMIT 1];
        System.assertEquals('Order Return Service', error.Service__c);
    }
}