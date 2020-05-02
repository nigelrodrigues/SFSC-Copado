/**
* Created by ytank on 3/27/2020.
*/
@isTest
public with sharing class trac_PurchaseOrderCtrlTest {
    
    @isTest
    public static void getPurchaseOrderLineTest(){
        String businessUnit='SAKS';
        String orderNo='3000011620';
        String docType='0001';
        TLAuraResponse response = new TLAuraResponse(true);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new trac_PurchaseOrderMockCallout());
        response=trac_PurchaseOrderCtrl.getPurchaseOrderLine(businessUnit,orderNo,docType);
        Test.stopTest();
        System.assert(response.returnValuesMap.get('orderResponse')!=null);
        
    }
    @isTest
    public static void purchaseOrderIntegrationError(){
        String businessUnit='null';
        String orderNo='null';
        String docType='null';
        TLAuraResponse response = new TLAuraResponse(true);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new trac_PurchaseOrderFailedMock());
        response=trac_PurchaseOrderCtrl.getPurchaseOrderLine(businessUnit,orderNo,docType);
        Test.stopTest();
        System.assert(response.returnValuesMap.get('orderResponse')==null);
        
    }

    @isTest
    public static void getPurchaseOrderLineTestException(){
        String businessUnit='SAKS';
        String orderNo='3000011620';
        String docType='0001';
        TLAuraResponse response = new TLAuraResponse(true);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new trac_PurchaseOrderErrorMock());
        response=trac_PurchaseOrderCtrl.getPurchaseOrderLine(businessUnit,orderNo,docType);
        Test.stopTest();
        System.assert(response.returnValuesMap.get('orderResponse')==null);

    }
}