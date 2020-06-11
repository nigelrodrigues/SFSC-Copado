@IsTest
public with sharing class trac_LoyaltySearchControllerTest {
    static final TLTestFactory factory = new TLTestFactory();
    
    @IsTest
    static void testGetLoyalty() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseLoyalty());
        String email = 'wassim1002@hbc.com';
        String loyaltyId = null;
        trac_WS_GetLoyalty.LoyaltyResponse res = (trac_WS_GetLoyalty.LoyaltyResponse) trac_LoyaltySearchController.getLoyalty(email, loyaltyId).returnValuesMap.get('body');
        System.assert(res != null, 'Loyalty retrived successfully.');
    }
    
    @IsTest
    static void testGetLoyaltyFail() {
        Test.setMock(HttpCalloutMock.class, null);
        String email = 'wassim1002@hbc.com';
        String loyaltyId = null;
        String res = (String) trac_LoyaltySearchController.getLoyalty(email, loyaltyId).returnValuesMap.get('body');
        System.assert(res == '', 'Loyalty not retrived successfully.');
    }

    @IsTest
    static void testGetLoyaltyUAD() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseLoyalty('loyaltyUAD'));
        String email = null;
        String loyaltyId = '600294999992297';
        String phoneNum = null;
        trac_WS_GetLoyaltyUAD.LoyaltyUADResponse res = (trac_WS_GetLoyaltyUAD.LoyaltyUADResponse) trac_LoyaltySearchController.getLoyaltyUAD(loyaltyId, email, phoneNum).returnValuesMap.get('body');
        System.assert(res != null, 'LoyaltyUAD retrived successfully.');
    }

    @IsTest
    static void testGetLoyaltyFailUAD() {
        Test.setMock(HttpCalloutMock.class, null);
        String email = null;
        String loyaltyId = '600294999992297';
        String phoneNum = null;
        String res = (String) trac_LoyaltySearchController.getLoyaltyUAD(loyaltyId, email, phoneNum).returnValuesMap.get('body');
        System.assert(res == '', 'LoyaltyUAD not retrived successfully.');
    }
}