/**
 * @description Test class for trac_OrderSearchController
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-07-08
 */
@isTest
private class trac_OrderSearchControllerTest {

    static final TLTestFactory factory = new TLTestFactory();
    
    @isTest
    static void testGetOrderDetails() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseOrderDetails());
        String orderNo = '5103639234';
        String businessUnit = '';
        trac_WS_GetOrderDetails.GetOrderDetailsResponse res = (trac_WS_GetOrderDetails.GetOrderDetailsResponse) trac_OrderSearchController.getOrderDetails(businessUnit, orderNo).returnValuesMap.get('orderDetails');
        System.assert(res != null, 'Order Details not retrived successfully.');
        //System.debug('@@@@@res: ' + res);
    }

    @isTest
    static void testGetOrderList() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseOrderList());
        String email = '';
        String businessUnit = '';
        trac_WS_GetOrderList.getOrderListResponse res = (trac_WS_GetOrderList.getOrderListResponse) trac_OrderSearchController.getOrderList(businessUnit, email).returnValuesMap.get('orderList');
        System.assert(res != null, 'Order List not retrived successfully.');
    }

    @isTest
    static void testGetselectOptions() {
        Case cs = new Case();
        List<String> values = new List<String>();
        values = trac_OrderSearchController.getselectOptions(cs, 'Business_Unit__c');
        System.assert(values.size() > 0, 'Picklist Values not populated.');
    }

    @isTest
    static void testUpdateCase() {
        Case test_Case = (Case)factory.createSObject(new Case(), true);
        trac_OrderSearchController.updateCase(test_Case.Id, '123456');
        test_Case = [SELECT Id, Order_Number__c FROM Case LIMIT 1];
        System.assertEquals('123456', test_Case.Order_Number__c, 'Case not updated successfully.');
    }
}