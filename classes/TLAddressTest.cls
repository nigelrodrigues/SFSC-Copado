/**
 *  @description Tests for TLAddress
 *  @author      Jeremy Horan, Traction on Demand.
 *  @date        10/30/2018
 */
@IsTest
private class TLAddressTest {

    @IsTest static void test_getFormattedPostalCode() {
        String formattedPostalCode1 = TLAddress.getFormattedPostalCode('h1p2l6');
        System.assertEquals('H1P 2L6', formattedPostalCode1, 'String should be H1P 2L6');

        String formattedPostalCode2 = TLAddress.getFormattedPostalCode('h1p 2l6');
        System.assertEquals('H1P 2L6', formattedPostalCode2, 'String should be H1P 2L6');
    }

    @IsTest static void test_getNumberFromAddressString() {
        String address1 = '123 Fake Street #100';
        System.assertEquals('123', TLAddress.getNumberFromAddressString(address1));

        String address2 = '17A Test Lane';
        System.assertEquals('17A', TLAddress.getNumberFromAddressString(address2));
    }

    @IsTest static void test_getStreetNameFromAddressString() {
        String address1 = '123 Fake Street #100';
        System.assertEquals('Fake Street', TLAddress.getStreetNameFromAddressString(address1));

        String address2 = '17A Test Lane';
        System.assertEquals('Test Lane', TLAddress.getStreetNameFromAddressString(address2));
    }

    @IsTest static void test_getSuiteNumberFromAddressString() {
        String address1 = '123 Fake Street #100';
        System.assertEquals('100', TLAddress.getSuiteNumberFromAddressString(address1));

        String address2 = '17A Test Lane';
        System.assertEquals(null, TLAddress.getSuiteNumberFromAddressString(address2));
    }
}