@IsTest
public with sharing class trac_LoyaltyControllerTest {

    @IsTest
    static void testUpdateLoyaltyPoints() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseLoyalty('update'));
        String email = 'wassim1002@hbc.com';
        String loyaltyId = '1200657659';
        Integer points = -100;
        String eventType = 'closed_account';
        trac_WS_RecordLoyaltyEvent.RecordLoyaltyEventResponse res = (trac_WS_RecordLoyaltyEvent.RecordLoyaltyEventResponse) trac_LoyaltyController.updateLoyaltyPoints(loyaltyId, email, points, eventType).returnValuesMap.get('response');
        System.assert(res.success == true, 'update loyalty points successfully.');
    }

    @IsTest
    static void testUpdateLoyaltyPointsFail() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseLoyalty('update.fail'));
        String email = 'wassim1002@hbc.com';
        String loyaltyId = '1200657659';
        Integer points = -100;
        String eventType = 'closed_account';
        trac_WS_RecordLoyaltyEvent.RecordLoyaltyEventResponse res = (trac_WS_RecordLoyaltyEvent.RecordLoyaltyEventResponse) trac_LoyaltyController.updateLoyaltyPoints(loyaltyId, email, points, eventType).returnValuesMap.get('response');
        System.assert(res.success == false, 'failed to update loyalty points successfully.');
        System.assert(res.data.code == 601, 'failed to update loyalty points successfully.');
    }

    @IsTest
    static void testUpdateLoyaltyPointsFailRequest() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseLoyalty(null));
        String email = null;
        String loyaltyId = '1200657659';
        Integer points = -100;
        String eventType = 'closed_account';
        trac_WS_RecordLoyaltyEvent.RecordLoyaltyEventResponse res = (trac_WS_RecordLoyaltyEvent.RecordLoyaltyEventResponse) trac_LoyaltyController.updateLoyaltyPoints(loyaltyId, email, points, eventType).returnValuesMap.get('response');
        System.assert(res == null, 'could not update loyalty points successfully.');
    }

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

    @IsTest
    static void testPauseLoyaltyFailRequest() {
        Test.setMock(HttpCalloutMock.class, null);
        String email = 'wassim1002@hbc.com';
        String loyaltyId = '1200657659';
        trac_WS_PauseLoyalty.PauseResponse res = (trac_WS_PauseLoyalty.PauseResponse) trac_LoyaltyController.pauseLoyalty(email, loyaltyId).returnValuesMap.get('response');
        System.assert(res == null, 'failed to send request.');
    }
}