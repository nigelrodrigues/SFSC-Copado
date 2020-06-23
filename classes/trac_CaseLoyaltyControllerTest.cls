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
}