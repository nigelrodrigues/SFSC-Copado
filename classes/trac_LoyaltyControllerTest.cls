@IsTest
public with sharing class trac_LoyaltyControllerTest {

    @IsTest

    static void testUpdateCustomerInfo() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseLoyalty('update_customer_info'));
        String loyaltyId = '1200657659';
        String firstName = 'John';
        String lastName = 'Doe';
        String email = 'johndoe@hbc.com';
        trac_WS_UpdateLoyaltyEvent.UpdateLoyaltyEventResponse res = (trac_WS_UpdateLoyaltyEvent.UpdateLoyaltyEventResponse) trac_LoyaltyController.updateCustomerInfo(loyaltyId, firstName, lastName, email).returnValuesMap.get('body');
        System.assert(res.success == true, 'update loyalty successfully.');
    }

    @IsTest
    static void testUpdateCustomerInfoFail() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseLoyalty('update_customer_info.fail'));
        String loyaltyId = '1200657659';
        String firstName = 'John';
        String lastName = 'Doe';
        String email = 'johndoe@hbc.com';
        String res = (String) trac_LoyaltyController.updateCustomerInfo(loyaltyId, firstName, lastName, email).returnValuesMap.get('body');
        System.assert(res != null, 'failed to update loyalty successfully.');
    }

    @IsTest
    static void testUpdateCustomerInfoException() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseLoyalty('customer/show.exception'));
        String loyaltyId = '1200657659';
        String firstName = 'John';
        String lastName = 'Doe';
        String email = 'johndoe@hbc.com';
        trac_WS_UpdateLoyaltyEvent.UpdateLoyaltyEventResponse res = (trac_WS_UpdateLoyaltyEvent.UpdateLoyaltyEventResponse) trac_LoyaltyController.updateCustomerInfo(loyaltyId, firstName, lastName, email).returnValuesMap.get('body');
        System.assert(res == null, 'could not update loyalty successfully.');
    }

    @IsTest
    static void testLsUpdateProfile() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseLoyalty('lsUpdate'));
        trac_WS_LsUpdateProfile.LsUpdateProfileRequest params = new trac_WS_LsUpdateProfile.LsUpdateProfileRequest();
        params.loyalty_id = '1200657659';
        params.first_name = 'John';
        params.last_name = 'Doe';
        params.email = 'johndoe@hbc.com';
        trac_WS_LsUpdateProfile.LsUpdateProfileResponse res = (trac_WS_LsUpdateProfile.LsUpdateProfileResponse) trac_LoyaltyController.lsUpdateProfile(params).returnValuesMap.get('body');
        System.assert(res.success == true, 'update loyalty successfully.');
    }

    @IsTest
    static void testLsUpdateProfileFail() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseLoyalty('lsUpdate.fail'));
        trac_WS_LsUpdateProfile.LsUpdateProfileRequest params = new trac_WS_LsUpdateProfile.LsUpdateProfileRequest();
        params.loyalty_id = '1200657659';
        params.first_name = 'John';
        params.last_name = 'Doe';
        params.email = 'johndoe@hbc.com';
        String res = (String) trac_LoyaltyController.lsUpdateProfile(params).returnValuesMap.get('body');
        System.assert(res != null, 'failed to update loyalty successfully.');
    }

    @IsTest
    static void testLsUpdateProfileFailId() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseLoyalty('lsUpdate.fail'));
        trac_WS_LsUpdateProfile.LsUpdateProfileRequest params = new trac_WS_LsUpdateProfile.LsUpdateProfileRequest();
        params.loyalty_id = null;
        params.first_name = 'John';
        params.last_name = 'Doe';
        params.email = 'johndoe@hbc.com';
        Boolean res = trac_LoyaltyController.lsUpdateProfile(params).isSuccess;
        System.assert(res == false, 'invalid loyalty id.');
    }

    @IsTest
    static void testLsUpdateProfileFailEmail() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseLoyalty('lsUpdate.fail'));
        trac_WS_LsUpdateProfile.LsUpdateProfileRequest params = new trac_WS_LsUpdateProfile.LsUpdateProfileRequest();
        params.loyalty_id = '1200657659';
        params.first_name = 'John';
        params.last_name = 'Doe';
        params.email = null;
        Boolean res = trac_LoyaltyController.lsUpdateProfile(params).isSuccess;
        System.assert(res == false, 'invalid email.');
    }

    @IsTest
    static void testLsUpdateProfileException() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseLoyalty('customer/show.exception'));
        trac_WS_LsUpdateProfile.LsUpdateProfileRequest params = new trac_WS_LsUpdateProfile.LsUpdateProfileRequest();
        params.loyalty_id = '1200657659';
        params.first_name = 'John';
        params.last_name = 'Doe';
        params.email = 'johndoe@hbc.com';
        try {
            String res = (String) trac_LoyaltyController.lsUpdateProfile(params).message;
        } catch (Exception e) {
            System.assert(e.getMessage() != null, 'exception thrown.');
        }

    }
}