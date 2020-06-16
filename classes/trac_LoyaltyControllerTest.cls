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
}