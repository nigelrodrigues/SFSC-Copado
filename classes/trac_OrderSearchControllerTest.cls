/**
 * @description Test class for trac_OrderSearchController
 * @author      Rajat Agrawal, Traction on Demand
 * @date        2019-07-08
 */
@IsTest
private class trac_OrderSearchControllerTest {

    static final TLTestFactory factory = new TLTestFactory();
    
    @IsTest
    static void testGetOrderDetails() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseOrderDetails());
        String orderNo = '5103639234';
        String businessUnit = '';
        trac_WS_GetOrderDetails.GetOrderDetailsResponse res = (trac_WS_GetOrderDetails.GetOrderDetailsResponse) trac_OrderSearchController.getOrderDetails(businessUnit, orderNo,'').returnValuesMap.get('orderDetails');
        System.assert(res != null, 'Order Details not retrived successfully.');
    }

    @IsTest
    static void testGetOrderList() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseOrderList());
        String email = '';
        String businessUnit = '';
        String accNum = '';
        trac_WS_GetOrderList.GetOrderListResponse res = (trac_WS_GetOrderList.GetOrderListResponse) trac_OrderSearchController.getOrderList(businessUnit, email,accNum).returnValuesMap.get('orderList');
        System.assert(res != null, 'Order List not retrived successfully.');
    }
    
    @IsTest
    static void testGetOrderListAdv() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseOrderListAdv());
        trac_WS_GetOrderList.GetOrderListResponse res = (trac_WS_GetOrderList.GetOrderListResponse) trac_OrderSearchController.getOrderListadv('saks','test','','','','', '', '','','').returnValuesMap.get('orderList');
    }

    @IsTest
    static void testGetselectOptions() {
        Case cs = new Case();
        List<String> values = new List<String>();
        values = trac_OrderSearchController.getselectOptions(cs, 'Business_Unit__c');
        System.assert(values.size() > 0, 'Picklist Values not populated.');
    }

    @IsTest
    static void testUpdateCase() {
        Case test_Case = (Case)factory.createSObject(new Case(), true);
        trac_OrderSearchController.updateCase(test_Case.Id, '123456', '90210');
        test_Case = [SELECT Id, Order_Number__c FROM Case LIMIT 1];
        System.assertEquals('123456', test_Case.Order_Number__c, 'Case not updated successfully.');
    }

    @IsTest
    static void testGetOrderNumberRange() {
        Test.startTest();
        String result = trac_OrderSearchController.getOrderNumberRange('Digital Blue Martini');
        Test.stopTest();

        System.assert(result != null, 'ranges match');
    }

    @IsTest
    static void testGetBlueMartiniLink() {
        Test.startTest();
        String result = trac_OrderSearchController.getBlueMartiniLink();
        Test.stopTest();

        System.assert(result != null ,'Retrieved linked');
    }
}