@IsTest
private class trac_WS_LoyaltyUtilsTest {
    @IsTest
    static void testGenerateHash() {
        String secretKey = 'testSecretKey';
        Map<String,String> params = new Map<String,String>{'param1' => 'value1', 'param2' => 'value2', 'param3' => 'value3'};
        String hashedSig = trac_WS_LoyaltyUtils.generateHash(secretKey, params);
        //System.debug('hashedSig: ' + hashedSig);
        System.assertEquals('4c8f5a696e4bdd6e1c561c0095cd8d4e', hashedSig);
    }


    @IsTest
    static void testParseDateStringExtendedFormat() {


        String dtString = 'Jul. 04, 2020, 06:31 p.m.';

        Test.startTest();
        Datetime dt = trac_WS_LoyaltyUtils.parseDateString(dtString);
        Test.stopTest();

        System.assertNotEquals(null, dt, 'Datetime string ' + dtString + ' failed to parse.');
        System.assertEquals(2020, dt.year());
        System.assertEquals(7, dt.month());
        System.assertEquals(4, dt.day());


        System.assertEquals(18, dt.hour());
        System.assertEquals(31, dt.minute());
    }

    @IsTest
    static void testParseDateStringStandardFormat() {

        String dtString = '12/31/2020';

        Test.startTest();
        Datetime dt = trac_WS_LoyaltyUtils.parseDateString(dtString);
        Test.stopTest();

        System.assertNotEquals(null, dt, 'Datetime string ' + dtString + ' failed to parse.');
        System.assertEquals(2020, dt.year());
        System.assertEquals(12, dt.month());
        System.assertEquals(31, dt.day());


        String invalidDtString = '12/32/2020';
        dt = trac_WS_LoyaltyUtils.parseDateString(invalidDtString);
        System.assertEquals(null, dt, invalidDtString + ' should be considered as invalid date');

        String invalidLeapYearDtString = '02/29/2019';
        dt = trac_WS_LoyaltyUtils.parseDateString(invalidLeapYearDtString);
        System.assertEquals(null, dt, invalidLeapYearDtString + ' should be considered as invalid leap year');
    }

}