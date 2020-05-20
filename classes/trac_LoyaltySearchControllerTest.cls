@IsTest
public with sharing class trac_LoyaltySearchControllerTest {
    static final TLTestFactory factory = new TLTestFactory();

    @IsTest
    static void testGetLoyalty() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseLoyalty());
        String email = 'MANIRKRISH@OPTONLINE.NET';
        String loyaltyId = null;
        String phoneNum = null;
        trac_WS_GetLoyalty.LoyaltyResponse res = (trac_WS_GetLoyalty.LoyaltyResponse) trac_LoyaltySearchController.getLoyalty(email, loyaltyId, phoneNum).returnValuesMap.get('loyalty');
        System.assert(res != null, 'Loyalty not retrived successfully.');
    }
}