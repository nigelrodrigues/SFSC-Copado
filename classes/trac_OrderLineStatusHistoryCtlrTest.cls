/**
 * Created by nrodrigues on 4/28/2020.
 */

@IsTest
private class trac_OrderLineStatusHistoryCtlrTest {
    static final TLTestFactory factory = new TLTestFactory();

    @IsTest
    static void testGetLineHistory() {
        Test.setMock(HttpCalloutMock.class, new MockOrderResponses('/history'));
        TLAuraResponse response  = trac_OrderLineStatusHistoryCtlr.getLineHistory('SAKS', '12345', '');
        System.assertEquals(true, response.isSuccess);
        System.assertEquals(false,  response.returnValuesMap.get('lineStatusHistory') == null);
    }

    @IsTest
    static void testGetLineHistoryError() {
        Test.setMock(HttpCalloutMock.class, new MockOrderResponsesError('/history'));
        TLAuraResponse response  = trac_OrderLineStatusHistoryCtlr.getLineHistory('SAKS', '12345', '');
        System.assertEquals(false, response.isSuccess);
        System.assertEquals(true,  response.returnValuesMap.get('lineStatusHistory') == null);


    }
}