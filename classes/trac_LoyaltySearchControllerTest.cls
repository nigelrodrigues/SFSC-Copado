@IsTest
public with sharing class trac_LoyaltySearchControllerTest {
    static final TLTestFactory factory = new TLTestFactory();
    
    @IsTest
    static void testGetLoyaltyMerkle() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseLoyalty());
        String email = 'wassim1002@hbc.com';
        String loyaltyId = null;
        trac_WS_GetLoyalty.LoyaltyResponse res = (trac_WS_GetLoyalty.LoyaltyResponse) trac_LoyaltySearchController.getLoyaltyMerkle(email, loyaltyId).returnValuesMap.get('loyalty');
        System.assert(res != null, 'Loyalty retrived successfully.');
    }
    
    @IsTest
    static void testGetLoyaltyMerkleFail() {
        Test.setMock(HttpCalloutMock.class, null);
        String email = 'wassim1002@hbc.com';
        String loyaltyId = null;
        trac_WS_GetLoyalty.LoyaltyResponse res = (trac_WS_GetLoyalty.LoyaltyResponse) trac_LoyaltySearchController.getLoyaltyMerkle(email, loyaltyId).returnValuesMap.get('loyalty');
        System.assert(res == null, 'Loyalty not retrived successfully.');
    }
}