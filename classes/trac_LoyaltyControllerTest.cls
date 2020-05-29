@IsTest
public with sharing class trac_LoyaltyControllerTest {
    @IsTest
    static void testPauseLoyalty() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseLoyalty('pause'));
        String email = 'wassim1002@hbc.com';
        String loyaltyId = '1200657659';
        trac_WS_PauseLoyalty.PauseResponse res = (trac_WS_PauseLoyalty.PauseResponse) trac_LoyaltyController.pauseLoyalty(loyaltyId, email).returnValuesMap.get('response');
        System.assert(res.success == true, 'paused loyalty successfully.');
        System.assert(res.data == null, 'paused loyalty successfully.');
    }

    @IsTest
    static void testPauseLoyaltyFail() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseLoyalty('pause.fail'));
        String email = 'wassim1002@hbc.com';
        String loyaltyId = '1200657659';
        trac_WS_PauseLoyalty.PauseResponse res = (trac_WS_PauseLoyalty.PauseResponse) trac_LoyaltyController.pauseLoyalty(email, loyaltyId).returnValuesMap.get('response');
        System.assert(res.success == false, 'failed to pause loyalty successfully.');
        System.assert(res.data.code == 201, 'failed to pause loyalty successfully.');
    }
}