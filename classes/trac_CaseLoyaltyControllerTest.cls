@IsTest
public with sharing class trac_CaseLoyaltyControllerTest {
    @IsTest
    static void testGetConversionRate() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseLoyalty('pointValue'));
        trac_WS_LoyaltyPointValue.PointValueResponse res = (trac_WS_LoyaltyPointValue.PointValueResponse) trac_CaseLoyaltyController.getConversionRate().returnValuesMap.get('body');

        System.assert(res.success == true, 'Point Value retrived successfully.');
    }

    @IsTest
    static void testGetConversionRateFail() {
        Test.setMock(HttpCalloutMock.class, null);

        String res = (String) trac_CaseLoyaltyController.getConversionRate().returnValuesMap.get('body');

        System.assert(res == '', 'Loyalty not retrived successfully.');
    }

    @IsTest
    static void testGetConversionRateException() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseLoyalty('customer/show.exception'));

        try{
            String res = (String) trac_CaseLoyaltyController.getConversionRate().message;

        } catch (Exception e) {
            System.assert(e.getMessage() != null, 'exception thrown.');
        }

    }

    @IsTest
    static void testUnsetCustomerLoyaltyId() {
        TLTestFactory factory = new TLTestFactory();
        Case bayCase = (Case) factory.createSObject(
                new Case(
                        RecordTypeId = TLSObj.getRecordTypeIdForName(Case.SObjectType, trac_CaseConstants.RECORD_TYPE_DEVNAME_SUPPORT_CASE),
                        Status = trac_CaseConstants.STATUS_NEW,
                        Customer_Loyalty_Id__c = '1000142'),
                true);

        Test.startTest();

        trac_CaseLoyaltyController.unsetCustomerLoyaltyId(bayCase.Id);

        Test.stopTest();

        Case c = [SELECT Id, Customer_Loyalty_Id__c FROM Case WHERE Id = :bayCase.Id];
        System.assertEquals(null, c.Customer_Loyalty_Id__c);
    }
}